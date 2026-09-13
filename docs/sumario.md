# Sumário do repositório

O que cada arquivo faz. Arquivo novo entra aqui no mesmo PR que o cria.

## Por onde começar

| Se você quer                             | Leia                                                   |
| ---------------------------------------- | ------------------------------------------------------ |
| Subir o projeto                          | [`README.md`](../README.md)                            |
| Saber o que já existe e o que não existe | [`CONTEXT.md`](../CONTEXT.md)                          |
| Escrever código seguindo as convenções   | [`CLAUDE.md`](../CLAUDE.md)                            |
| Abrir um PR                              | [`CONTRIBUTING.md`](../CONTRIBUTING.md)                |
| Entender um requisito                    | [`Projeto_Matchmaking.md`](../Projeto_Matchmaking.md)  |
| Saber por que uma decisão foi tomada     | [`docs/adr/`](./adr/)                                  |
| Tirar uma dúvida de configuração         | [`perguntas-frequentes.md`](./perguntas-frequentes.md) |

## Documentação

| Arquivo                            | O que é                                                                                                 |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `Projeto_Matchmaking.md`           | Requisitos, personas, arquitetura e racional. Fonte da verdade sobre **o que** o sistema faz            |
| `CLAUDE.md`                        | Convenções de código, fronteira de camadas e o que não se decide sozinho. Lido por pessoas e por IAs    |
| `CONTEXT.md`                       | Estado atual, decisões de configuração e próximo passo. A seção "Onde estamos" é do responsável técnico |
| `CONTRIBUTING.md`                  | Fluxo de branches, padrão de commit e checklist de PR                                                   |
| `CHANGELOG.md`                     | Histórico de mudanças. **Só o responsável técnico edita**                                               |
| `README.md`                        | Como executar o projeto                                                                                 |
| `docs/sumario.md`                  | Este arquivo                                                                                            |
| `docs/modelagem.md`                | Modelo de dados proposto e os oito pontos em aberto, três dos quais bloqueiam a primeira migration      |
| `docs/proposta-listas-fechadas.md` | Valores propostos para os três bloqueantes, aguardando decisão do grupo. Some depois de virar ADR       |
| `docs/perguntas-frequentes.md`     | Dúvidas recorrentes sobre a configuração, com o motivo de cada escolha                                  |
| `docs/adr/README.md`               | Índice dos ADRs, agrupado por tema                                                                      |
| `docs/adr/0001` a `0023`           | Uma decisão arquitetural por arquivo, com as alternativas recusadas                                     |
| `LICENSE`                          | Licença MIT                                                                                             |

## Código

| Arquivo                   | O que faz                                                                                                                                                                        |
| ------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `src/api.ts`              | Entrypoint do processo **API**. Cria o servidor HTTP, escuta a porta e trata o encerramento gracioso                                                                             |
| `src/worker.ts`           | Entrypoint do processo **worker**. Consumirá as filas do BullMQ                                                                                                                  |
| `src/dispatcher.ts`       | Entrypoint do processo **dispatcher**. Varrerá o outbox e rodará as rotinas periódicas                                                                                           |
| `src/app.ts`              | Monta o Express: helmet, CORS com credenciais, log de requisição, parser JSON, `/health` e tratador de erros. **Não abre porta** — é o que permite testar sem servidor pendurado |
| `src/infra/env.ts`        | Valida as variáveis de ambiente com Zod na subida. O processo não inicia com variável faltando                                                                                   |
| `src/infra/db.ts`         | Cliente Prisma com adapter `pg`                                                                                                                                                  |
| `src/infra/redis.ts`      | Cliente ioredis                                                                                                                                                                  |
| `src/infra/logger.ts`     | Log estruturado com pino, com redaction de cookie, senha e token                                                                                                                 |
| `src/infra/errors.ts`     | `AppError`, os erros nomeados e o middleware que traduz erro em resposta HTTP                                                                                                    |
| `src/generated/`          | Cliente Prisma **gerado**. Não versionado, não editar                                                                                                                            |
| `tests/health.test.ts`    | Verifica que `GET /health` responde 200                                                                                                                                          |
| `tests/errors.test.ts`    | Cobre os erros nomeados e o tratador, incluindo que a mensagem original do erro nao tratado nao vaza para o cliente                                                              |
| `scripts/quality-gate.ts` | O portão de qualidade. Sete verificações, sem curto-circuito, falhando fechado                                                                                                   |

## Configuração

| Arquivo                                | O que faz                                                             |
| -------------------------------------- | --------------------------------------------------------------------- |
| `package.json`                         | Dependências e scripts                                                |
| `package-lock.json`                    | Versões exatas. É o que faz `npm ci` reproduzir a mesma instalação    |
| `tsconfig.json`                        | Base do TypeScript. É o que o editor e o ESLint enxergam              |
| `tsconfig.build.json`                  | Só `src/`. O único que emite para `dist/`                             |
| `tsconfig.test.json`                   | `tests/`, `scripts/` e os arquivos de config                          |
| `eslint.config.js`                     | Lint e as regras que recusam import cruzando a fronteira de camadas   |
| `.prettierrc.json` / `.prettierignore` | Formatação                                                            |
| `vitest.config.ts`                     | Testes e cobertura                                                    |
| `quality-baseline.json`                | Números congelados do portão. Alterar exige aprovação de outra pessoa |
| `commitlint.config.js`                 | Valida Conventional Commits                                           |
| `cliff.toml`                           | Regras do rascunho de changelog                                       |
| `.husky/pre-commit`                    | Roda formatação e tipos antes do commit                               |
| `.husky/commit-msg`                    | Roda o commitlint na mensagem                                         |
| `.env.example`                         | Todas as variáveis necessárias, sem nenhum valor real                 |
| `prisma/schema.prisma`                 | Modelo de dados. Ainda sem nenhum model                               |
| `prisma.config.ts`                     | Configuração do Prisma 7, incluindo a URL do banco                    |

## Infraestrutura e CI

| Arquivo                            | O que faz                                                                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------ |
| `docker-compose.yml`               | PostgreSQL e Redis por padrão; os três processos da aplicação sob o perfil `app`                       |
| `Dockerfile`                       | Imagem de produção, em múltiplos estágios                                                              |
| `.dockerignore`                    | O que não entra na imagem                                                                              |
| `.github/workflows/ci.yml`         | Job `quality`. Roda em PR e push para `dev`, `release` e `main`                                        |
| `.github/pull_request_template.md` | Checklist que aparece na descrição de todo PR                                                          |
| `.coderabbit.yaml`                 | Revisão automática por bot nos PRs para `dev` e `release`. Complementa a revisão humana, não substitui |
| `.github/CODEOWNERS`               | Quem é pedido para revisar conforme os arquivos tocados. Caminhos sensíveis têm dono explícito         |
| `.gitignore`                       | O que não é versionado                                                                                 |

## Empacotar o repositório para uma IA

Quem não usa Claude Code gera um XML do projeto e cola em qualquer modelo. São dois perfis, porque
"necessário" depende da pergunta.

```bash
npm run context        # codigo e convencoes  — ~19k tokens, 24 arquivos
npm run context:full   # tudo, com requisitos — ~67k tokens, 55 arquivos
```

| Perfil         | Arquivo gerado                | Config                | O que entra                                                                                   |
| -------------- | ----------------------------- | --------------------- | --------------------------------------------------------------------------------------------- |
| `context`      | `repomix-output.xml`          | `repomix.config.json` | `src/`, `tests/`, `scripts/`, schema, configs, `CLAUDE.md`, `modelagem.md` e o índice de ADRs |
| `context:full` | `repomix-output-completo.xml` | `repomix.full.json`   | Tudo acima mais `Projeto_Matchmaking.md`, os 22 ADRs, o FAQ, `CONTRIBUTING.md` e o changelog  |

Use `context` para **escrever código** e `context:full` para **entender o projeto** ou discutir
requisito. O perfil padrão existe porque a documentação é 77% do repositório hoje — mandar tudo
gasta a janela de contexto do modelo lendo requisito em vez de raciocinar sobre implementação.

O `CONTEXT.md` vai junto nos dois como instrução. É ele que diz à IA o que **ainda não existe**, e é
o que a impede de gerar código assumindo autenticação ou model que não foram escritos.

Três cuidados:

- **Regere antes de usar.** Os arquivos de saída não são versionados e pacote velho descreve um
  repositório que não existe mais.
- **O `.env` nunca entra**, porque `useGitignore` está ligado. Só o `.env.example`.
- **O security check está ligado** nos dois perfis, e avisa se algum arquivo parecer conter segredo.
