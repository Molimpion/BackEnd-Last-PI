import { spawnSync } from "node:child_process";
import { readFileSync, existsSync, readdirSync, statSync } from "node:fs";
import { join, relative, resolve } from "node:path";

const RAIZ = resolve(import.meta.dirname, "..");
const BASELINE = JSON.parse(readFileSync(join(RAIZ, "quality-baseline.json"), "utf8")) as Baseline;

interface Baseline {
  coberturaMinimaDoDiff: number;
  ocorrenciasDeAny: number;
  ocorrenciasDeAsAny: number;
  supressoesDeTipo: number;
  vulnerabilidadesAceitas: string[];
}

type Situacao = "ok" | "reprovado" | "nao_executou" | "nao_aplicavel";

interface Resultado {
  nome: string;
  situacao: Situacao;
  detalhe: string;
}

class ErroDeExecucao extends Error {}

function executar(comando: string, args: string[]): { codigo: number; saida: string } {
  const r = spawnSync(comando, args, { cwd: RAIZ, encoding: "utf8", maxBuffer: 64 * 1024 * 1024 });

  if (r.error) {
    throw new ErroDeExecucao(`${comando} nao pode ser iniciado: ${r.error.message}`);
  }
  if (r.status === null) {
    throw new ErroDeExecucao(`${comando} foi terminado por sinal ${String(r.signal)}`);
  }

  return { codigo: r.status, saida: `${r.stdout}${r.stderr}` };
}

function arquivosDeCodigo(): string[] {
  const encontrados: string[] = [];

  function percorrer(dir: string): void {
    for (const entrada of readdirSync(dir)) {
      if (entrada === "generated") continue;
      const caminho = join(dir, entrada);
      if (statSync(caminho).isDirectory()) {
        percorrer(caminho);
      } else if (entrada.endsWith(".ts")) {
        encontrados.push(caminho);
      }
    }
  }

  const src = join(RAIZ, "src");
  if (!existsSync(src)) {
    throw new ErroDeExecucao("diretorio src nao encontrado");
  }
  percorrer(src);

  if (encontrados.length === 0) {
    throw new ErroDeExecucao("nenhum arquivo .ts encontrado em src");
  }

  return encontrados;
}

function contarOcorrencias(padrao: RegExp): number {
  let total = 0;
  for (const arquivo of arquivosDeCodigo()) {
    const conteudo = readFileSync(arquivo, "utf8");
    total += conteudo.match(padrao)?.length ?? 0;
  }
  return total;
}

function verificarContagem(nome: string, padrao: RegExp, limite: number): Resultado {
  const atual = contarOcorrencias(padrao);

  if (atual > limite) {
    return {
      nome,
      situacao: "reprovado",
      detalhe: `${String(atual)} ocorrencias, baseline e ${String(limite)}`,
    };
  }

  return { nome, situacao: "ok", detalhe: `${String(atual)} de ${String(limite)} no baseline` };
}

function verificarLint(): Resultado {
  const { codigo, saida } = executar("npx", ["eslint", ".", "--max-warnings", "0"]);

  if (codigo === 0) return { nome: "Lint", situacao: "ok", detalhe: "sem erros nem warnings" };
  if (codigo === 1) return { nome: "Lint", situacao: "reprovado", detalhe: resumir(saida) };

  throw new ErroDeExecucao(`eslint saiu com codigo ${String(codigo)}: ${resumir(saida)}`);
}

function verificarTipos(): Resultado {
  const { codigo, saida } = executar("npm", ["run", "--silent", "typecheck"]);

  if (codigo === 0) return { nome: "Verificacao de tipos", situacao: "ok", detalhe: "sem erros" };
  return { nome: "Verificacao de tipos", situacao: "reprovado", detalhe: resumir(saida) };
}

interface RelatorioAudit {
  vulnerabilities?: Record<string, { severity: string; via: (string | { url?: string })[] }>;
}

function verificarVulnerabilidades(): Resultado {
  const { codigo, saida } = executar("npm", ["audit", "--omit=dev", "--json"]);

  if (codigo !== 0 && codigo !== 1) {
    throw new ErroDeExecucao(`npm audit saiu com codigo ${String(codigo)}: ${resumir(saida)}`);
  }

  let relatorio: RelatorioAudit;
  try {
    relatorio = JSON.parse(saida) as RelatorioAudit;
  } catch {
    throw new ErroDeExecucao("npm audit nao produziu JSON valido");
  }

  if (relatorio.vulnerabilities === undefined) {
    throw new ErroDeExecucao("npm audit nao trouxe o campo vulnerabilities");
  }

  const criticas: string[] = [];
  const naoAceitas: string[] = [];

  for (const [pacote, dados] of Object.entries(relatorio.vulnerabilities)) {
    const ids = dados.via
      .filter((v): v is { url?: string } => typeof v === "object")
      .map((v) => v.url?.split("/").pop())
      .filter((id): id is string => id !== undefined);

    if (dados.severity === "critical") {
      criticas.push(`${pacote} (${ids.join(", ")})`);
      continue;
    }

    for (const id of ids) {
      if (!BASELINE.vulnerabilidadesAceitas.includes(id)) {
        naoAceitas.push(`${pacote}: ${id}`);
      }
    }
  }

  if (criticas.length > 0) {
    return {
      nome: "Vulnerabilidades",
      situacao: "reprovado",
      detalhe: `critica e bloqueio absoluto, sem baseline: ${criticas.join("; ")}`,
    };
  }

  if (naoAceitas.length > 0) {
    return {
      nome: "Vulnerabilidades",
      situacao: "reprovado",
      detalhe: `fora do baseline: ${naoAceitas.join("; ")}`,
    };
  }

  return {
    nome: "Vulnerabilidades",
    situacao: "ok",
    detalhe: `nenhuma critica; ${String(BASELINE.vulnerabilidadesAceitas.length)} aceitas no baseline`,
  };
}

function verificarTestes(): Resultado {
  const { codigo, saida } = executar("npm", ["run", "--silent", "test:coverage"]);

  if (codigo === 0) return { nome: "Testes", situacao: "ok", detalhe: "suite passou" };
  return { nome: "Testes", situacao: "reprovado", detalhe: resumir(saida) };
}

function linhasCobertas(): Map<string, Map<number, number>> {
  const lcov = join(RAIZ, "coverage", "lcov.info");
  if (!existsSync(lcov)) {
    throw new ErroDeExecucao("coverage/lcov.info nao foi gerado");
  }

  const porArquivo = new Map<string, Map<number, number>>();
  let atual: Map<number, number> | undefined;

  for (const linha of readFileSync(lcov, "utf8").split("\n")) {
    if (linha.startsWith("SF:")) {
      atual = new Map();
      porArquivo.set(relative(RAIZ, resolve(RAIZ, linha.slice(3).trim())), atual);
    } else if (linha.startsWith("DA:") && atual !== undefined) {
      const [numero, execucoes] = linha.slice(3).split(",");
      if (numero !== undefined && execucoes !== undefined) {
        atual.set(Number(numero), Number(execucoes));
      }
    }
  }

  if (porArquivo.size === 0) {
    throw new ErroDeExecucao("coverage/lcov.info nao listou nenhum arquivo");
  }

  return porArquivo;
}

function linhasAdicionadas(base: string): Map<string, Set<number>> {
  const { codigo, saida } = executar("git", [
    "diff",
    "--unified=0",
    "--diff-filter=AM",
    `${base}...HEAD`,
    "--",
    "src",
  ]);

  if (codigo !== 0) {
    throw new ErroDeExecucao(`git diff contra ${base} falhou: ${resumir(saida)}`);
  }

  const porArquivo = new Map<string, Set<number>>();
  let arquivo: string | undefined;

  for (const linha of saida.split("\n")) {
    if (linha.startsWith("+++ b/")) {
      arquivo = linha.slice(6).trim();
      porArquivo.set(arquivo, new Set());
      continue;
    }

    const hunk = /^@@ -\d+(?:,\d+)? \+(\d+)(?:,(\d+))? @@/.exec(linha);
    if (hunk?.[1] !== undefined && arquivo !== undefined) {
      const inicio = Number(hunk[1]);
      const quantidade = hunk[2] === undefined ? 1 : Number(hunk[2]);
      const alvo = porArquivo.get(arquivo);
      for (let i = 0; i < quantidade; i += 1) alvo?.add(inicio + i);
    }
  }

  return porArquivo;
}

function verificarCoberturaDoDiff(base: string | undefined): Resultado {
  const nome = "Cobertura das linhas novas";

  if (base === undefined) {
    return {
      nome,
      situacao: "nao_aplicavel",
      detalhe: "sem base de comparacao; a verificacao so roda em pull request",
    };
  }

  const cobertura = linhasCobertas();
  const adicionadas = linhasAdicionadas(base);

  let total = 0;
  let cobertas = 0;
  const descobertas: string[] = [];

  for (const [arquivo, linhas] of adicionadas) {
    const daCobertura = cobertura.get(arquivo);
    if (daCobertura === undefined) continue;

    for (const linha of linhas) {
      const execucoes = daCobertura.get(linha);
      if (execucoes === undefined) continue;
      total += 1;
      if (execucoes > 0) cobertas += 1;
      else descobertas.push(`${arquivo}:${String(linha)}`);
    }
  }

  if (total === 0) {
    return { nome, situacao: "nao_aplicavel", detalhe: "o diff nao adicionou linha executavel" };
  }

  const percentual = (cobertas / total) * 100;
  const resumo = `${percentual.toFixed(1)}% (${String(cobertas)}/${String(total)}), minimo ${String(BASELINE.coberturaMinimaDoDiff)}%`;

  if (percentual < BASELINE.coberturaMinimaDoDiff) {
    return {
      nome,
      situacao: "reprovado",
      detalhe: `${resumo}. Descobertas: ${descobertas.slice(0, 10).join(", ")}`,
    };
  }

  return { nome, situacao: "ok", detalhe: resumo };
}

function resumir(texto: string): string {
  const linhas = texto.trim().split("\n").filter(Boolean);
  return linhas.slice(-6).join(" | ").slice(0, 500);
}

function baseDeComparacao(): string | undefined {
  const argumento = process.argv.find((a) => a.startsWith("--base="));
  if (argumento !== undefined) return argumento.slice(7);

  const doGitHub = process.env.GITHUB_BASE_REF;
  if (doGitHub !== undefined && doGitHub !== "") return `origin/${doGitHub}`;

  return undefined;
}

function executarVerificacao(fn: () => Resultado, nome: string): Resultado {
  try {
    return fn();
  } catch (erro) {
    const mensagem = erro instanceof Error ? erro.message : String(erro);
    return { nome, situacao: "nao_executou", detalhe: mensagem };
  }
}

const base = baseDeComparacao();

const resultados: Resultado[] = [
  executarVerificacao(verificarTestes, "Testes"),
  executarVerificacao(verificarLint, "Lint"),
  executarVerificacao(verificarVulnerabilidades, "Vulnerabilidades"),
  executarVerificacao(verificarTipos, "Verificacao de tipos"),
  executarVerificacao(
    () =>
      verificarContagem(
        "Ocorrencias de any",
        /:\s*any\b|<any>|\bany\[\]/g,
        BASELINE.ocorrenciasDeAny,
      ),
    "Ocorrencias de any",
  ),
  executarVerificacao(
    () => verificarContagem("Ocorrencias de as any", /\bas\s+any\b/g, BASELINE.ocorrenciasDeAsAny),
    "Ocorrencias de as any",
  ),
  executarVerificacao(
    () =>
      verificarContagem(
        "Supressoes de tipo",
        /@ts-(?:ignore|expect-error|nocheck)/g,
        BASELINE.supressoesDeTipo,
      ),
    "Supressoes de tipo",
  ),
  executarVerificacao(() => verificarCoberturaDoDiff(base), "Cobertura das linhas novas"),
];

const simbolo: Record<Situacao, string> = {
  ok: "PASSOU",
  reprovado: "REPROVOU",
  nao_executou: "NAO EXECUTOU",
  nao_aplicavel: "N/A",
};

console.log("\nPortao de qualidade\n");
for (const r of resultados) {
  console.log(`  [${simbolo[r.situacao]}] ${r.nome}`);
  console.log(`           ${r.detalhe}\n`);
}

const bloqueantes = resultados.filter(
  (r) => r.situacao === "reprovado" || r.situacao === "nao_executou",
);

if (bloqueantes.length > 0) {
  console.error(`Portao reprovou em ${String(bloqueantes.length)} verificacao(oes).`);
  process.exit(1);
}

console.log("Portao aprovou.");
