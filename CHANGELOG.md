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
- `CODEOWNERS` pedindo revisão automaticamente, com dono explícito nos caminhos sensíveis: baseline
  do portão, workflows, ADRs, schema e os arquivos mantidos pelo responsável técnico.
- Modelo de dados completo no `prisma/schema.prisma`: 25 entidades e 21 enums, cobrindo identidade,
  perfis, vitrine, conexão, matchmaking, assinatura, pagamento e governança.
- Primeira migration (`modelagem_inicial`), com índices únicos parciais que impedem solicitação
  pendente duplicada, pedido de acesso pendente duplicado e duas reuniões ativas na mesma
  solicitação.
- Teste de integração contra o PostgreSQL real cobrindo esses três índices.
- ADRs 0028 a 0036: planos por público em três níveis, destaque pago do mentor na busca,
  solicitação a investidor e mentor com cota mensal, acesso do mentor ao perfil completo, estados da
  reunião, escala e critérios do feedback, notificações de segurança e reconciliação periódica com o
  gateway de pagamento, e enums do domínio como cópia verificada por teste.
- Perguntas frequentes sobre a pasta `src/generated/` e sobre a relação entre migration e geração do
  cliente.

### Alterado

- `docs/modelagem.md` deixa de ser proposta e passa a descrever o modelo decidido, com o ADR de cada
  decisão e os valores de negócio ainda em aberto.
- `Projeto_Matchmaking.md` reflete as decisões dos ADRs 0028 a 0035 nos RF05, RF10, RF13, RF15 e
  RF17.
- A liberação de plano passa a ocorrer por confirmação do gateway — webhook validado ou consulta do
  servidor —, e não mais exclusivamente por webhook.
- `npm run db:migrate` passa a regerar o cliente Prisma depois de aplicar a migration.

### Corrigido

- A fronteira de camadas no ESLint não barrava o acesso ao banco fora do repository: a regra só
  recusava `@prisma/client`, que ninguém importa no Prisma 7. Passa a recusar também `infra/db.js`
  e `generated/prisma` em controller, service e use case.

### Removido

- `docs/proposta-listas-fechadas.md`, substituído pelos enums no schema.

### Segurança

- `multer-storage-cloudinary` removido por prender o `cloudinary` na 1.x, afetada pelo advisory
  GHSA-g4mf-96x5-5m2c.
- `overrides` forçando `mysql2` e `deepmerge-ts` para as versões corrigidas. O Prisma fixa as duas em
  versão exata e as fixadas têm advisory `high`. A árvore de produção passa a ter zero
  vulnerabilidades, e o baseline do portão fica vazio.
