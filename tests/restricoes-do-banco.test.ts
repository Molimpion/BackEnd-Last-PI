import { randomUUID } from "node:crypto";
import { afterAll, afterEach, describe, expect, it } from "vitest";
import { desconectarBanco, prisma } from "../src/infra/db.js";

const contasCriadas: string[] = [];

async function criarStartup(): Promise<{ id: string }> {
  const conta = await prisma.conta.create({
    data: {
      email: `startup-${randomUUID()}@teste.local`,
      senhaHash: "hash",
      tipo: "STARTUP",
      startup: {
        create: {
          nome: "Startup de teste",
          segmentos: ["FINTECH"],
          estagio: "VALIDACAO",
          cidade: "Recife",
          descricaoCurta: "Descricao",
          capitalMinimo: 100_000,
          capitalMaximo: 500_000,
          naturezaDaBusca: "CAPITAL",
        },
      },
    },
    select: { id: true, startup: { select: { id: true } } },
  });
  contasCriadas.push(conta.id);
  if (!conta.startup) throw new Error("startup nao criada");
  return conta.startup;
}

async function criarPessoa(): Promise<{ id: string }> {
  const conta = await prisma.conta.create({
    data: {
      email: `pessoa-${randomUUID()}@teste.local`,
      senhaHash: "hash",
      tipo: "PESSOA",
      pessoa: {
        create: {
          nome: "Pessoa de teste",
          cidade: "Recife",
          linkedin: "https://linkedin.com/in/teste",
          empresaOuAtuacao: "Empresa",
        },
      },
    },
    select: { id: true, pessoa: { select: { id: true } } },
  });
  contasCriadas.push(conta.id);
  if (!conta.pessoa) throw new Error("pessoa nao criada");
  return conta.pessoa;
}

function dadosDeSolicitacao(startupId: string, pessoaId: string, papel: "INVESTIDOR" | "MENTOR") {
  return {
    startupId,
    pessoaId,
    papelDoDestinatario: papel,
    pauta: "Pauta",
    expiraEm: new Date(Date.now() + 15 * 24 * 60 * 60 * 1000),
  };
}

afterEach(async () => {
  const contas = contasCriadas.splice(0);
  const filtroStartup = { startup: { contaId: { in: contas } } };
  const filtroPessoa = { pessoa: { contaId: { in: contas } } };
  await prisma.reuniao.deleteMany({ where: { solicitacao: filtroStartup } });
  await prisma.solicitacao.deleteMany({ where: { OR: [filtroStartup, filtroPessoa] } });
  await prisma.autorizacaoDeAcesso.deleteMany({ where: { OR: [filtroStartup, filtroPessoa] } });
  await prisma.startup.deleteMany({ where: { contaId: { in: contas } } });
  await prisma.pessoa.deleteMany({ where: { contaId: { in: contas } } });
  await prisma.conta.deleteMany({ where: { id: { in: contas } } });
});

afterAll(async () => {
  await desconectarBanco();
});

describe("solicitacao pendente", () => {
  it("recusa segunda solicitacao pendente da mesma startup para a mesma pessoa pelo mesmo papel", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    await prisma.solicitacao.create({
      data: dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR"),
    });

    await expect(
      prisma.solicitacao.create({ data: dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR") }),
    ).rejects.toMatchObject({ code: "P2002" });
  });

  it("aceita solicitacao pendente para a mesma pessoa por outro papel", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    await prisma.solicitacao.create({
      data: dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR"),
    });

    await expect(
      prisma.solicitacao.create({ data: dadosDeSolicitacao(startup.id, pessoa.id, "MENTOR") }),
    ).resolves.toMatchObject({ status: "PENDENTE" });
  });

  it("aceita nova solicitacao depois que a anterior foi recusada", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    await prisma.solicitacao.create({
      data: { ...dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR"), status: "RECUSADA" },
    });

    await expect(
      prisma.solicitacao.create({ data: dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR") }),
    ).resolves.toMatchObject({ status: "PENDENTE" });
  });
});

describe("pedido de acesso ao perfil completo pendente", () => {
  it("recusa segundo pedido pendente da mesma pessoa pelo mesmo papel para a mesma startup", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    const dados = {
      startupId: startup.id,
      pessoaId: pessoa.id,
      papelDoSolicitante: "INVESTIDOR" as const,
    };
    await prisma.autorizacaoDeAcesso.create({ data: dados });

    await expect(prisma.autorizacaoDeAcesso.create({ data: dados })).rejects.toMatchObject({
      code: "P2002",
    });
  });

  it("aceita novo pedido depois que o anterior foi negado", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    const dados = {
      startupId: startup.id,
      pessoaId: pessoa.id,
      papelDoSolicitante: "MENTOR" as const,
    };
    await prisma.autorizacaoDeAcesso.create({ data: { ...dados, status: "NEGADA" } });

    await expect(prisma.autorizacaoDeAcesso.create({ data: dados })).resolves.toMatchObject({
      status: "PENDENTE",
    });
  });
});

describe("reuniao ativa", () => {
  it("recusa segunda reuniao ativa na mesma solicitacao", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    const solicitacao = await prisma.solicitacao.create({
      data: { ...dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR"), status: "ACEITA" },
    });
    await prisma.reuniao.create({
      data: { solicitacaoId: solicitacao.id, pauta: "Pauta", status: "CONFIRMADA" },
    });

    await expect(
      prisma.reuniao.create({ data: { solicitacaoId: solicitacao.id, pauta: "Outra pauta" } }),
    ).rejects.toMatchObject({ code: "P2002" });
  });

  it("aceita nova reuniao depois que a anterior foi realizada", async () => {
    const startup = await criarStartup();
    const pessoa = await criarPessoa();
    const solicitacao = await prisma.solicitacao.create({
      data: { ...dadosDeSolicitacao(startup.id, pessoa.id, "INVESTIDOR"), status: "ACEITA" },
    });
    await prisma.reuniao.create({
      data: { solicitacaoId: solicitacao.id, pauta: "Pauta", status: "REALIZADA" },
    });

    await expect(
      prisma.reuniao.create({ data: { solicitacaoId: solicitacao.id, pauta: "Outra pauta" } }),
    ).resolves.toMatchObject({ status: "PROPOSTA" });
  });
});
