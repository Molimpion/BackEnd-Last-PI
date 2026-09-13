# Changelog

Todas as mudanças relevantes deste projeto são registradas aqui.

O formato segue [Keep a Changelog](https://keepachangelog.com/pt-BR/1.1.0/) e o versionamento
segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

Seções usadas: `Adicionado`, `Alterado`, `Corrigido`, `Removido`, `Segurança`, `Descontinuado`.

## [Não publicado]

### Adicionado

- Configuração inicial do projeto: TypeScript em ESM, Express, Prisma com adapter `pg`, ioredis,
  Vitest, ESLint, Prettier, husky e commitlint.
- Três entrypoints correspondentes aos processos da seção 6.4: `api`, `worker` e `dispatcher`.
- `docker-compose.yml` com PostgreSQL e Redis, e os três processos da aplicação sob o perfil `app`.
- Validação de variáveis de ambiente na subida (`src/infra/env.ts`) — o processo não inicia com
  variável faltando ou inválida.
- Rota `GET /health` e o teste que a cobre.
- Fronteira de camadas aplicada por ESLint: `express` recusado em service e use case,
  `@prisma/client` recusado fora do repository.
- Dois perfis de empacotamento para IA: `npm run context` (código e convenções) e
  `npm run context:full` (tudo, incluindo requisitos e ADRs).
- `docs/sumario.md`, descrevendo o que cada arquivo do repositório faz.
- Pipeline de CI em GitHub Actions (job `quality`), com PostgreSQL e Redis como serviços do runner.
- `CONTRIBUTING.md` com fluxo de branches, checklist de PR e regras de qualidade.
- ADR 0001, registrando o contexto da gestão de segredos — decisão ainda pendente.
- Portão de qualidade (`npm run quality`) com as sete verificações da seção 9.4, baseline em
  `quality-baseline.json` e cobertura do diff com mínimo de 70%.
- `docs/perguntas-frequentes.md`, com as dúvidas levantadas durante a configuração e o motivo de
  cada escolha.
- Geração de rascunho de changelog a partir dos commits (`npm run changelog:draft`, via git-cliff).
- `CLAUDE.md` com as convenções do repositório e as decisões que não se reabrem sem ADR, e
  `CONTEXT.md` com o estado verificado e o próximo passo.
- `docs/modelagem.md` com a proposta de modelo de dados e os oito pontos em aberto que bloqueiam a
  primeira migration.
- ADRs 0002 a 0022, cobrindo todas as decisões com alternativa recusada identificadas no documento
  de projeto, agrupadas por tema em `docs/adr/README.md`.
- Template de pull request.
- Revisão automática por CodeRabbit nos PRs para `dev` e `release`, com as regras do projeto por
  diretório. Complementa a revisão humana exigida pelo RNF06, não substitui.

### Segurança

- `multer-storage-cloudinary` removido por prender o `cloudinary` na 1.x, afetada pelo advisory
  GHSA-g4mf-96x5-5m2c.
- `overrides` forçando `mysql2` e `deepmerge-ts` para as versões corrigidas. O Prisma fixa as duas em
  versão exata e as fixadas têm advisory `high`. A árvore de produção passa a ter zero
  vulnerabilidades, e o baseline do portão fica vazio.
