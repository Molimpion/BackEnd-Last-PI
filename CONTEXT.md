# CONTEXT.md — BackEnd-Last-PI

Estado atual, decisões vigentes e próximo passo. Atualize a cada entrega.

Este arquivo vai junto no pacote gerado por `npm run context`, então é o que uma IA sem acesso ao
repositório lê primeiro. **Escreva só o que foi verificado.** Documentação otimista aqui produz
código errado com aparência de correto — o precedente do grupo está registrado na seção 8.6.

- Requisitos e racional: [`Projeto_Matchmaking.md`](./Projeto_Matchmaking.md)
- Convenções e regras de trabalho: [`CLAUDE.md`](./CLAUDE.md)
- Decisões individuais: [`docs/adr/`](./docs/adr/)

## Onde estamos

> **Esta seção é mantida pelo responsável técnico.** Não edite em PR. Se o seu PR implementa algo
> listado abaixo como inexistente, diga isso na descrição do PR — a atualização acontece na revisão.

**Repositório configurado. Nenhuma feature implementada.**

Verificado rodando:

- `npm ci` do zero, com `postinstall` gerando o cliente Prisma.
- `npm run quality` aprovando as sete verificações. Testado também que reprova: arquivo com `any`,
  `as any` e `@ts-expect-error` derrubou cinco verificações de uma vez, sem curto-circuito, e base
  de comparação inexistente reprovou como `NAO EXECUTOU`.
- `npm run build`, `typecheck`, `lint`, `format:check` e a suíte (1 teste).
- `npm run context` empacotando o repositório, com security check limpo e sem `.env` no pacote.
- `npm run changelog:draft` agrupando commits convencionais por tipo.

**Nunca executado:** o `docker-compose.yml` e o workflow de CI. Não há Docker neste devcontainer até
o rebuild com a feature `docker-in-docker`, e Actions não roda localmente.

**Não existe ainda:** model no `prisma/schema.prisma`, migration, `src/features/`, sessão,
autenticação, especificação OpenAPI.

`docs/modelagem.md` existe como **proposta** — nenhum model foi escrito no schema, e três listas
fechadas que ela depende continuam indefinidas.

O que existe de código é `src/app.ts` (helmet, CORS com credenciais, pino-http, JSON, `/health`,
tratador de erros), os três entrypoints e `src/infra/` com env validado por Zod, Prisma com adapter
`pg`, ioredis, logger com redaction e os erros de aplicação. `worker.ts` e `dispatcher.ts` são só
bootstrap e encerramento gracioso — sem fila e sem rotina.

## Decisões vigentes

As decisões de produto estão no `CLAUDE.md`. Aqui ficam as de configuração, tomadas nesta fase:

| Decisão                                                          | Razão                                                                                                                                  |
| ---------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ESM, Node 22                                                     | Padrão da linguagem, suporte nativo                                                                                                    |
| `app.ts` separado de `api.ts`                                    | `app.ts` não abre porta, o que permite testar com supertest sem servidor pendurado                                                     |
| TypeScript fixado em 5.x                                         | `typescript-eslint` declara peer `typescript <6.1.0`; TS 7 deixaria o lint sem suporte                                                 |
| Prisma CLI fixado em 7.x                                         | O `latest` do npm aponta para `8.0.0-rc`                                                                                               |
| URL do banco via `process.env` direto em `prisma.config.ts`      | O helper `env()` resolve ao carregar o config e quebraria `npm ci` sem `.env`                                                          |
| `multer-storage-cloudinary` removido                             | Prendia o `cloudinary` na 1.x (GHSA-g4mf-96x5-5m2c). Upload será `multer` memoryStorage + `upload_stream`                              |
| Fronteira de camadas aplicada por ESLint                         | `no-restricted-imports` recusa `express` em service/usecase e `@prisma/client` fora do repository                                      |
| Vulnerabilidade no baseline por **ID de advisory**, não contagem | Contagem deixa passar advisory novo quando outro sai no mesmo PR                                                                       |
| Portão roda os testes ele mesmo                                  | Se o workflow rodasse a suíte antes, uma falha impediria as outras seis verificações — o curto-circuito voltaria pela porta dos fundos |
| Changelog escrito à mão, rascunho gerado                         | Commit descreve o que o dev fez; changelog descreve o que mudou para quem usa                                                          |

## Dívidas e riscos conhecidos

- **`overrides` no `package.json` forçando `mysql2` e `deepmerge-ts`.** O Prisma fixa os dois em
  versão exata, e as fixadas têm advisory `high`. Os overrides sobem para as versões corrigidas e o
  `npm audit` fica limpo. A contrapartida é que `deepmerge-ts` subiu de major dentro do
  `@prisma/config` — funciona hoje (verificado com `generate`, `validate` e `migrate status`), mas
  precisa ser reconferido a cada atualização do Prisma. Ver
  [ADR 0023](./docs/adr/0023-overrides-para-dependencias-transitivas.md).
- **A aritmética da cobertura do diff nunca foi exercitada.** Com `src/` ainda untracked, o
  `git diff` não retorna nada e a verificação cai em `N/A`. O primeiro PR é o teste real.
- **O passo `Aplicar migrations` do CI é o candidato a quebrar na primeira rodada**, porque roda
  `prisma migrate deploy` sem existir nenhuma migration.
- **O nome do job `quality` é contrato com a proteção de branch.** Renomear não gera erro: o GitHub
  fica esperando um check que nunca chega.
- **Rodar o portão e falhar não impede merge** enquanto o job não for _required status check_ nas
  três branches (seção 9.6).
- `SESSION_SECRET` exige 32 caracteres (`src/infra/env.ts`) — limite escolhido na configuração, não
  especificado no documento.
- Prettier não consta na tabela 6.3, que lista a ferramenta apenas para o front-end.

## Próximo passo

**Modelagem de dados:** models do `prisma/schema.prisma`, primeira migration e `docs/modelagem.md`.

Antes ou em paralelo, três coisas da seção 11 que são de primeira semana e não dependem de código:

1. Rebuild do devcontainer e `docker compose up` funcionando.
2. Validar o fluxo de cookie entre domínios (seção 8.1) — é o que se disfarça de bug de
   autenticação se for descoberto na integração final.
3. Tornar os três repositórios públicos e configurar a proteção de `main`, `release` e `dev`, com o
   job `quality` como _required status check_.

Registrar como ADR as decisões já tomadas que ainda não têm arquivo: sessão opaca em vez de JWT,
score determinístico, cota com devolução, anonimização, Express em vez de Nest, outbox no pagamento,
casos de uso restritos a domínios pesados.
