# Perguntas frequentes

Dúvidas levantadas durante a configuração do repositório, com a resposta e o motivo da escolha.
São as perguntas que mais provavelmente aparecem de novo — se a sua não está aqui, adicione.

O racional completo de cada decisão de projeto está em
[`Projeto_Matchmaking.md`](../Projeto_Matchmaking.md); aqui fica a versão curta.

---

## ESM ou CommonJS? Por que `"type": "module"`?

São os dois sistemas de módulo do Node. CommonJS é o antigo (`require()` / `module.exports`), ESM é
o padrão da linguagem (`import` / `export`). Como escrevemos TypeScript com `import`, o código-fonte
parece igual nos dois; a diferença está no que sai compilado em `dist/` e em como o Node carrega.

Escolhemos ESM porque é para onde o ecossistema foi e o Node 22 suporta nativamente.

Os dois custos, para não te pegar de surpresa:

- `__dirname` e `__filename` não existem. Use `import.meta.dirname`.
- Pacote antigo publicado só em CommonJS às vezes exige `import x from "pacote"` em vez de
  `import { y } from "pacote"`.

## Por que três entrypoints? `api.ts` é o `server.ts`?

`api.ts` é o que em outros projetos se chamaria `server.ts` — é o arquivo que o Node executa.

São três porque o backend não é um processo único (seção 6.4): `api.ts` responde HTTP e WebSocket,
`worker.ts` consome as filas do BullMQ, `dispatcher.ts` varre o outbox e roda as rotinas periódicas.
Os três compartilham todo o código de `src/features/` e `src/infra/`; só o ponto de entrada muda. No
Render isso vira três serviços apontando para o mesmo repositório com comandos de start diferentes.

O nome `api.ts` em vez de `server.ts` é proposital: os três são "server" no sentido de processo de
longa duração, então o nome precisa dizer o papel.

## Por que `app.ts` é separado de `api.ts`?

`app.ts` monta o Express e devolve o objeto — middlewares, rotas, tratador de erro. Não abre porta.
`api.ts` pega esse objeto, cria o servidor HTTP, chama `listen()` e trata o encerramento gracioso.

O motivo é teste. Em `tests/health.test.ts` o supertest recebe o app e sobe um servidor efêmero numa
porta aleatória. Se os dois fossem o mesmo arquivo, importar o app no teste já dispararia o
`listen()` na porta 3333 — dois testes em paralelo brigariam pela porta e a suíte não terminaria
sozinha, porque teria um servidor vivo segurando o processo.

## O que é a pasta `src/generated/`?

É o Prisma escrevendo o código de banco por nós. Não é código nosso, é saída do gerador.

A gente descreve o banco uma vez, no `prisma/schema.prisma`. O comando `prisma generate` lê esse
arquivo e escreve duas coisas:

1. **Os tipos.** O TypeScript passa a saber que `Startup` tem `nome`, `cidade`, `cnpj`, e que
   `statusDeModeracao` só aceita `PENDENTE`, `APROVADO` ou `REPROVADO`. Quem digitar
   `startup.nomee` vê o erro no editor, não em produção.
2. **As funções.** `prisma.startup.findMany()`, `prisma.solicitacao.create()`, já tipadas: o
   `where` só aceita colunas que existem, e o resultado vem com o tipo certo, inclusive com as
   relações pedidas em `include`.

A tradução é direta:

| No schema                     | No TypeScript gerado          |
| ----------------------------- | ----------------------------- |
| `String`                      | `string`                      |
| `String?`                     | `string \| null`              |
| `DateTime`                    | `Date`                        |
| `Segmento[]`                  | `Segmento[]`                  |
| `Canvas?` (relação 1–1)       | `canvas: Canvas \| null`      |
| `Solicitacao[]` (relação 1–N) | `solicitacoes: Solicitacao[]` |

Analogia: o `schema.prisma` é a planta da casa e o `generated/` é o manual impresso a partir dela.
Mudou a planta, imprime o manual de novo. Ninguém corrige o manual à caneta.

**Três regras:**

- **Não edite nada aí dentro.** O próximo `generate` apaga a edição.
- **Não vai para o git.** O diretório está no `.gitignore` e é regerado pelo `postinstall` a cada
  `npm ci`. Versionado, dois PRs que mexem no schema dariam conflito em milhares de linhas geradas.
- **Mudou o `schema.prisma`, rode `npm run db:generate`.** Senão os tipos ficam desatualizados.

**Isso é novo?** A geração existe desde o Prisma 2 (2020). O que mudou foi o lugar: até o Prisma 6,
o gerador `prisma-client-js` escrevia em `node_modules/.prisma/client`, escondido — você importava
`@prisma/client` e não via de onde vinham os tipos. No Prisma 7, o gerador `prisma-client` escreve
TypeScript ESM na pasta definida em `output` (aqui, `src/generated/prisma`). É o mesmo mecanismo,
agora visível.

## A migration atualiza o `src/generated/`?

**Não.** No Prisma 7, `prisma migrate dev` só altera o banco; não chama mais o `generate`, como
fazia até o Prisma 6. São dois produtos do mesmo arquivo, e por isso dois comandos:

```
schema.prisma ──migrate──→ banco (tabelas)
      │
      └──────generate──→ src/generated/ (tipos e funções)
```

Por isso o script `npm run db:migrate` roda os dois em sequência (`prisma migrate dev && prisma
generate`). Depois de mudar o schema, basta ele.

Quem chamar `npx prisma migrate dev` direto, sem o script, precisa rodar `npm run db:generate` em
seguida. Esquecer produz o sintoma mais confuso: a tabela nova existe no banco, mas o TypeScript diz
que `prisma.tabelaNova` não existe.

## Por que existe um `tsconfig.test.json` separado?

Porque testes e scripts precisam de opções diferentes do código de produção — hoje, `types` incluindo
os globais do Vitest e `exactOptionalPropertyTypes` relaxado, que é o que costuma brigar na hora de
montar um mock parcial.

Os três configs:

| Arquivo               | Para quê                                     |
| --------------------- | -------------------------------------------- |
| `tsconfig.json`       | Base. É o que o editor e o ESLint enxergam   |
| `tsconfig.build.json` | Só `src/`, é o único que emite para `dist/`  |
| `tsconfig.test.json`  | `tests/`, `scripts/` e os arquivos de config |

`npm run typecheck` roda os dois últimos, então nada fica sem verificação de tipo.

## Precisamos de uma biblioteca de mock?

Não, e provavelmente não é o que você quer.

- **Massa de dados falsos** → `@faker-js/faker`, já instalado. É o que gera as 1.000 startups e 200
  investidores do RNF05.
- **Mock de função ou módulo** → o Vitest já traz nativo: `vi.fn()`, `vi.mock()`, `vi.spyOn()`.

O alerta importante: o RNF07 **proíbe** mock nos cinco fluxos críticos. Nas palavras do documento,
"Redis mockado não comprova que a sessão funciona; repositório mockado não comprova que a consulta
está correta". Nesses cinco, o teste roda contra PostgreSQL e Redis de verdade — é para isso que a
pipeline sobe os dois como serviço do runner.

## Por que `npm ci` e não `npm install`?

`npm install` resolve as versões de novo e pode atualizar o `package-lock.json`. `npm ci` instala
exatamente o que está no lockfile, sem negociar.

Consequência prática: o lockfile é versionado e todo mundo — pessoas e CI — roda `npm ci`. É o que
garante que a máquina de quem revisa o PR tem as mesmas versões da máquina de quem escreveu.

## Como gero e onde guardo os segredos?

Resposta completa no [ADR 0001](./adr/0001-gestao-de-segredos.md), incluindo as perguntas ainda em
aberto. O resumo:

- Só o `SESSION_SECRET` é **gerado** por nós (`openssl rand -hex 32`). Os demais são **emitidos**
  pelo fornecedor e precisam bater com o que ele tem — gerar valor aleatório não adianta.
- Local vai no `.env` (que está no `.gitignore`); CI vai em GitHub Secrets; produção vai nas
  Environment Variables do Render, replicadas nos **três** serviços.
- Para criar: `gh secret set NOME --repo Molimpion/BackEnd-Last-PI`, que pede o valor sem ecoar.
  Nunca use `--body "valor"`, que deixa o segredo no histórico do shell.

A pipeline atual **não consome nenhum segredo** — PostgreSQL e Redis sobem como serviço do runner e
o `SESSION_SECRET` é gerado efêmero a cada execução.

## O que é o portão de qualidade?

Um script (`npm run quality`) que coleta métricas do repositório e decide se o PR pode ser mesclado.
Quatro coisas o diferenciam de rodar os comandos soltos:

1. **Não curto-circuita.** Roda as sete verificações e reporta tudo junto, em vez de parar na
   primeira — você não descobre os problemas um por push.
2. **Catraca em vez de meta fixa.** Os números ficam congelados em `quality-baseline.json`.
   Estritamente maior reprova, igual passa. A dívida técnica só pode diminuir, sem travar o projeto
   para zerá-la.
3. **Cobertura sobre o diff, não sobre o projeto.** Só as linhas que o PR adicionou entram na conta,
   com mínimo de 70%. Percentual global congelado barraria PR por diluição, o que pune contribuição
   legítima. É por isso que o workflow usa `fetch-depth: 0`: sem histórico completo o git não acha o
   ancestral comum.
4. **Falha fechado.** Verificação que não conseguiu executar **reprova**. Se o `npm audit` quebrar
   por falha de rede e a saída vier vazia, contar zero críticas e aprovar faria a verificação
   desaparecer sem sinal vermelho (seção 9.5).

A limitação que o documento assume: o baseline é editável por quem está sendo medido. O que resolve
não é código, é a revisão obrigatória — mexer no baseline vira uma linha de diff que outra pessoa
precisa aprovar.

## Por que o backend é integrado antes do front, com o OpenAPI no mesmo PR?

O backend descreve suas rotas numa especificação OpenAPI. O front **não escreve** o código que chama
a API — ele roda o Kubb, que lê essa especificação e _gera_ os tipos, os schemas Zod e os hooks de
React Query. A especificação não é documentação que alguém lê: é entrada de um gerador de código.

Daí as duas regras:

- **Backend primeiro.** Se o front for integrado antes, o Kubb roda contra uma especificação que
  ainda não tem o endpoint, o código gerado não compila, e a `dev` do front quebra para o grupo
  inteiro.
- **No mesmo PR.** A especificação é escrita à mão, então pode divergir do código. Atualizar depois
  cria uma janela em que o Kubb gera um cliente que não corresponde à API real — e o erro aparece no
  front, em runtime, longe de onde foi causado.

Na prática, seu PR do backend tem três coisas juntas: a rota, o DTO Zod e a anotação OpenAPI.

## O CodeRabbit revisou meu PR. Isso conta como revisão?

Não. O RNF06 exige revisão por outro **membro** do grupo, e bot não é membro. O CodeRabbit é
complemento: ele pega o que passa despercebido, mas não aprova nada em nome de ninguém.

Ele é configurado em `.coderabbit.yaml` e revisa automaticamente PRs direcionados a `dev` e
`release`. Isso precisou ser configurado: por padrão ele só revisa PRs para a branch padrão (`main`),
e como todo PR de feature vai para `dev`, ele nunca revisaria nada sozinho.

O arquivo também ensina ao bot as regras deste repositório, por diretório — a fronteira de camadas
em `src/features/`, a proibição de `any`, a exigência de teste de integração nos cinco fluxos
críticos, e a instrução para sinalizar quando alguém escreve um número de negócio que ainda não foi
decidido.

Para pedir uma revisão manual, comente `@coderabbitai review` no PR.

Discordar de uma sugestão dele é legítimo. Discorde com argumento, no próprio PR — é o que fica
registrado para quem ler depois.

## Por que `CONTRIBUTING.md` e não um `GITFLOW.md`?

O fluxo de branches já está na seção 9.1 do documento de projeto. Um arquivo repetindo aquilo cria
duas fontes de verdade que divergem na primeira mudança — exatamente o problema que a seção 8.6
registra como precedente do grupo.

O `CONTRIBUTING.md` resolve outra coisa: o GitHub o exibe automaticamente quando alguém abre PR ou
issue. É onde cabe o que o documento não detalha — o checklist de revisão, a ordem entre repositórios
e como rodar a verificação local.

E vale lembrar: o que impede push errado em `main` não é arquivo nenhum, é a proteção de branch da
seção 9.6.

## O CI está funcionando?

**Não sabemos.** Ele foi escrito e nunca executado — a primeira execução real é no primeiro push.

O ponto a vigiar é o passo `Aplicar migrations`: ele roda `prisma migrate deploy` e ainda não existe
nenhuma migration. Se der vermelho na primeira rodada, é isso, e a correção é remover o passo até a
primeira migration existir.

Duas armadilhas silenciosas do CI:

- **O nome do job (`quality`) é contrato com a configuração do repositório.** A proteção de branch
  referencia o job pelo nome. Renomear não gera erro: o GitHub simplesmente fica esperando um check
  que nunca chega.
- **Rodar e falhar não impede merge por si só.** Enquanto o job não for marcado como _required status
  check_ nas três branches (seção 9.6), o portão é um aviso vermelho que dá para ignorar.

## O que ainda vai mudar no CI?

| Quando                                           | O que muda                                                           |
| ------------------------------------------------ | -------------------------------------------------------------------- |
| Primeira migration existir                       | Validar o passo `Aplicar migrations`                                 |
| Primeira integração externa (RF12, RF17, upload) | Entram `${{ secrets.NOME }}`, o que exige resolver o ADR 0001 antes  |
| A função da IA for definida                      | Job novo rodando a suíte com o serviço de IA derrubado (RNF11)       |
| For medir o RNF01                                | Workflow separado para o teste de carga com k6 — não roda em todo PR |
| Houver deploy                                    | Workflow de deploy disparando os **três** serviços do Render         |

Uma decisão em aberto: em evento de `push`, a cobertura do diff não é medida, porque a base de
comparação vem do `GITHUB_BASE_REF`, que só existe em pull request. É defensável (o código já passou
pelo PR), mas se quisermos cobrir push direto, dá para usar `github.event.before` como base.
