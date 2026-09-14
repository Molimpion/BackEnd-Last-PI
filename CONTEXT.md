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

**Repositório configurado e modelo de dados escrito. Nenhuma feature implementada.**

Verificado rodando:

- `npm ci` do zero, com `postinstall` gerando o cliente Prisma.
- `npm run quality` aprovando as sete verificações. Testado também que reprova: arquivo com `any`,
  `as any` e `@ts-expect-error` derrubou cinco verificações de uma vez, sem curto-circuito, e base
  de comparação inexistente reprovou como `NAO EXECUTOU`.
- `npm run build`, `typecheck`, `lint`, `format:check` e a suíte (16 testes).
- **Migration `modelagem_inicial` aplicada no Postgres local** do compose: 25 tabelas e os três
  índices únicos parciais escritos à mão no SQL. O teste `tests/restricoes-do-banco.test.ts` foi
  conferido nos dois sentidos — com os índices removidos, os três testes de recusa falharam; com os
  índices recriados, passaram.
- `npm run db:migrate` rodando `migrate dev` e `generate` em sequência.
- **Fronteira de camadas no ESLint conferida por sonda:** controller, service e use case importando
  `infra/db.js` ou `generated/prisma` reprovam; repository passa.
- `npm run context` empacotando o repositório, com security check limpo e sem `.env` no pacote.
- `npm run changelog:draft` agrupando commits convencionais por tipo.
- **O CI rodou no GitHub Actions e passou**, em PR para `dev`, `release` e `main`. Dois fatos que
  eram incerteza viraram evidência: `prisma migrate deploy` sai com código 0 quando não existe
  migration, e a cobertura do diff mede corretamente — reprovou a 46,5% e aprovou a 81,4% depois dos
  testes de `errors.ts`.
- **O fluxo `feature → dev → release → main` foi percorrido inteiro** (PRs #1, #2 e #3), com a
  proteção de branch já ativa.

**Executado em parte:** o `docker-compose.yml`. Os serviços `postgres` e `redis` sobem saudáveis e
foram usados para a migration e os testes. **Nunca executado:** o perfil `app` (API, worker e
dispatcher em contêiner).

**Ainda não verificado no CI:** a primeira migration real. Até aqui o `db:deploy` do workflow só
rodou sem migration nenhuma; o teste de restrições depende dele aplicar a migration antes do portão.

**Configuração do repositório:** público, com proteção em `main`, `release` e `dev` — job `quality`
como _required status check_, `strict` ligado, `enforce_admins` ligado, sem force push e sem
deleção. Revisão obrigatória está em **zero aprovações**, porque o GitHub não permite aprovar o
próprio PR e hoje há um único revisor.

**Não existe ainda:** `src/features/`, repository, sessão, autenticação, especificação OpenAPI,
seed de `Plano`.

O schema tem as 25 entidades descritas em `docs/modelagem.md`, com as decisões nos ADRs 0024 a 0035.
Nenhuma regra de negócio está implementada sobre ele.

O que existe de código é `src/app.ts` (helmet, CORS com credenciais, pino-http, JSON, `/health`,
tratador de erros), os três entrypoints e `src/infra/` com env validado por Zod, Prisma com adapter
`pg`, ioredis, logger com redaction e os erros de aplicação. `worker.ts` e `dispatcher.ts` são só
bootstrap e encerramento gracioso — sem fila e sem rotina.

## Decisões vigentes

As decisões de produto estão no `CLAUDE.md`. Aqui ficam as de configuração, tomadas nesta fase:

| Decisão                                                          | Razão                                                                                                                                     |
| ---------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------- |
| ESM, Node 22                                                     | Padrão da linguagem, suporte nativo                                                                                                       |
| `app.ts` separado de `api.ts`                                    | `app.ts` não abre porta, o que permite testar com supertest sem servidor pendurado                                                        |
| TypeScript fixado em 5.x                                         | `typescript-eslint` declara peer `typescript <6.1.0`; TS 7 deixaria o lint sem suporte                                                    |
| Prisma CLI fixado em 7.x                                         | O `latest` do npm aponta para `8.0.0-rc`                                                                                                  |
| URL do banco via `process.env` direto em `prisma.config.ts`      | O helper `env()` resolve ao carregar o config e quebraria `npm ci` sem `.env`                                                             |
| `multer-storage-cloudinary` removido                             | Prendia o `cloudinary` na 1.x (GHSA-g4mf-96x5-5m2c). Upload será `multer` memoryStorage + `upload_stream`                                 |
| Fronteira de camadas aplicada por ESLint                         | `no-restricted-imports` recusa `express` em service/usecase e, fora do repository, `@prisma/client`, `infra/db.js` e `generated/prisma`   |
| Vulnerabilidade no baseline por **ID de advisory**, não contagem | Contagem deixa passar advisory novo quando outro sai no mesmo PR                                                                          |
| Portão roda os testes ele mesmo                                  | Se o workflow rodasse a suíte antes, uma falha impediria as outras seis verificações — o curto-circuito voltaria pela porta dos fundos    |
| Changelog escrito à mão, rascunho gerado                         | Commit descreve o que o dev fez; changelog descreve o que mudou para quem usa                                                             |
| CodeRabbit revisando PRs para `dev` e `release`                  | Por padrão ele só revisa PRs para a branch padrão; como toda feature vai para `dev`, nunca revisaria nada. Não substitui o RNF06          |
| Perfil do investidor visível às startups                         | O RF04 define o perfil público só da startup; sem o outro lado, a descoberta funcionaria em um sentido só e o RF15 não teria o que buscar |
| Moderação com critérios próprios por tipo de conta               | Os três critérios do RF08 são sobre startup. Sem critério escrito para `PESSOA`, o selo do RF16 não teria contra o quê ser conferido      |

## Dívidas e riscos conhecidos

- **`overrides` no `package.json` forçando `mysql2` e `deepmerge-ts`.** O Prisma fixa os dois em
  versão exata, e as fixadas têm advisory `high`. Os overrides sobem para as versões corrigidas e o
  `npm audit` fica limpo. A contrapartida é que `deepmerge-ts` subiu de major dentro do
  `@prisma/config` — funciona hoje (verificado com `generate`, `validate` e `migrate status`), mas
  precisa ser reconferido a cada atualização do Prisma. Ver
  [ADR 0023](./docs/adr/0023-overrides-para-dependencias-transitivas.md).
- **O nome do job `quality` é contrato com a proteção de branch.** Renomear não gera erro: o GitHub
  simplesmente fica esperando um check que nunca chega, e o merge trava.
- **O `CODEOWNERS` pede revisão, mas não obriga.** Falta `require_code_owner_reviews` na proteção — e
  ele não pode ser ligado enquanto houver um único dono, porque travaria o responsável técnico nos
  próprios PRs. Adicionar os handles dos outros integrantes é o que destrava isso e transforma o
  RNF06 em barreira técnica em vez de acordo.
- **`db.ts`, `redis.ts` e o caminho de falha do `env.ts` seguem sem cobertura.** São instanciação de
  cliente de terceiro e um `process.exit` em carga de módulo, que não é coberto em processo. Não
  foram excluídos da medição: se algum PR futuro mexer neles, a cobertura do diff vai cobrar.
- **O repositório foi aberto para habilitar a proteção de branch** ([ADR 0017](./docs/adr/0017-repositorios-publicos.md)).
  Se o GitHub Education ativar o plano Pro, o fundamento daquele ADR deixa de valer e ele precisa ser
  reavaliado — o argumento de portfólio sustenta a escolha sozinho, mas é outro argumento e precisa
  ser dito.
- `SESSION_SECRET` exige 32 caracteres (`src/infra/env.ts`) — limite escolhido na configuração, não
  especificado no documento.
- Prettier não consta na tabela 6.3, que lista a ferramenta apenas para o front-end.
- **Os três índices únicos parciais vivem só no SQL da migration inicial.** O `schema.prisma` não
  os expressa. Regerar as migrations do zero os apaga sem erro; quem denuncia é o
  `tests/restricoes-do-banco.test.ts`.
- **Enum do schema usado na regra de negócio existe em dois lugares**: no schema e na cópia em
  `src/features/<feature>/enums.ts` ([ADR 0036](./docs/adr/0036-enums-do-dominio-como-copia-verificada.md)).
  O `enums.test.ts` da feature impede a divergência, mas só se for escrito junto com a cópia — o
  revisor precisa cobrar.
- **O teste de restrições grava e apaga linhas no banco apontado por `DATABASE_URL`.** Localmente é o
  mesmo banco de desenvolvimento. Limpa o que cria, mas não isola de dado que já esteja lá.
- **`mfaSegredo` precisa de chave de criptografia** em variável de ambiente, ainda não criada. Entra
  no `.env.example` no PR do fluxo de MFA.

## Próximo passo

**Modelagem de dados escrita.** O `prisma/schema.prisma` tem as 25 entidades e a migration
`modelagem_inicial` foi aplicada no Postgres local. Decisões e presunções em
[`docs/modelagem.md`](./docs/modelagem.md), racional nos ADRs 0024 a 0035.

As restrições que o Prisma não expressa — os três índices únicos parciais — estão cobertas por
`tests/restricoes-do-banco.test.ts`. Confirmar no CI do PR que a migration é aplicada antes do portão.

Próxima frente: a primeira feature sobre o schema. A escolha de qual é do grupo.

Os valores de negócio que continuam em aberto não bloqueiam o schema, mas bloqueiam a regra
correspondente. A lista está no fim da `docs/modelagem.md`.

Em paralelo, duas coisas de primeira semana que não dependem de código:

- `docker compose up` do perfil `app` (API, worker e dispatcher). Os serviços `postgres` e `redis`
  já sobem e foram usados para gerar a migration.
- Validar o fluxo de cookie entre domínios ([ADR 0015](./docs/adr/0015-cookie-entre-dominios-distintos.md)) —
  é o que se disfarça de bug de autenticação se for descoberto só na integração final.

E, quando os outros integrantes tiverem acesso: adicionar os handles ao `CODEOWNERS` e ligar
`require_code_owner_reviews`.
