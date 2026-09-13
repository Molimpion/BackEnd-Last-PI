# BackEnd-Last-PI

API do Projeto Matchmaking — plataforma de conexão entre startups e investidores anjo.

Requisitos e decisões de projeto: [`Projeto_Matchmaking.md`](./Projeto_Matchmaking.md).

## Pré-requisitos

- Node.js 22+
- Docker e Docker Compose

## Como executar

```bash
cp .env.example .env       # ajuste os valores; sem .env nada sobe
docker compose up -d       # PostgreSQL e Redis
npm ci                     # instala as versões exatas do package-lock.json
npm run db:migrate         # aplica as migrations
npm run dev                # API em http://localhost:3333
```

Os outros dois processos rodam em terminais separados:

```bash
npm run dev:worker
npm run dev:dispatcher
```

Para subir tudo em container, incluindo os três processos da aplicação:

```bash
docker compose --profile app up --build
```

## Processos

O backend não é um processo único (seção 6.4 do documento de projeto):

| Processo   | Comando                    | Papel                                       |
| ---------- | -------------------------- | ------------------------------------------- |
| API        | `npm start`                | HTTP e WebSocket                            |
| Worker     | `npm run start:worker`     | Consome as filas do BullMQ                  |
| Dispatcher | `npm run start:dispatcher` | Varre o outbox e roda as rotinas periódicas |

## Scripts

| Comando                 | O que faz                                  |
| ----------------------- | ------------------------------------------ |
| `npm run dev`           | API em modo watch                          |
| `npm run build`         | Compila para `dist/`                       |
| `npm run typecheck`     | Verifica tipos de `src/` e de `tests/`     |
| `npm run lint`          | ESLint                                     |
| `npm test`              | Vitest                                     |
| `npm run test:coverage` | Vitest com relatório de cobertura          |
| `npm run db:migrate`    | Cria e aplica migration em desenvolvimento |
| `npm run db:deploy`     | Aplica migrations pendentes (produção)     |
| `npm run db:studio`     | Prisma Studio                              |
| `npm run context`       | Empacota o repositório em XML para uma IA  |
| `npm run context:full`  | O mesmo, com requisitos e ADRs completos   |

## Empacotar o repositório para uma IA

Quem não usa Claude Code pode gerar um XML do projeto e colar em qualquer modelo.

- **`npm run context`** gera `repomix-output.xml` com o código, as configurações, o `CLAUDE.md`, a
  modelagem e o índice de ADRs. É o pacote para **escrever código**.
- **`npm run context:full`** gera `repomix-output-completo.xml` com tudo, incluindo o
  `Projeto_Matchmaking.md` e os ADRs completos. É o pacote para **entender o projeto** ou discutir
  requisito.

O `CONTEXT.md` vai junto nos dois, como instrução — é o que diz à IA o que **ainda não existe**, e é
o que a impede de gerar código assumindo autenticação ou model que não foram escritos.

Os dois arquivos de saída não são versionados. Regere antes de usar: pacote velho descreve um
repositório que não existe mais.

## Estrutura

```
src/
  api.ts          entrypoint da API
  worker.ts       entrypoint do worker
  dispatcher.ts   entrypoint do dispatcher
  app.ts          montagem do Express
  features/       um diretório por domínio
  infra/          banco, redis, log, erros e integrações externas
  generated/      cliente Prisma (gerado, não versionado)
prisma/
  schema.prisma   modelo de dados
tests/            testes de integração
```

A dependência aponta para dentro: `controller` → `usecase`/`service` → `repository`. O `controller` é a única camada que conhece HTTP; o `repository` é a única que conhece Prisma. O ESLint recusa os imports que violam essa fronteira.

## Variáveis de ambiente

Todas as variáveis estão em [`.env.example`](./.env.example) e são validadas na subida por `src/infra/env.ts` — o processo não inicia com variável faltando ou inválida.

Variável nova introduzida no código entra no `.env.example` no mesmo pull request.
