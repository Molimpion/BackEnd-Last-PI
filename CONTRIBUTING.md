# Como contribuir

Regras de fluxo e qualidade deste repositório. O racional de cada decisão está em
[`Projeto_Matchmaking.md`](./Projeto_Matchmaking.md) — aqui fica só o que você precisa fazer.

## Antes de começar

```bash
cp .env.example .env
docker compose up -d
npm ci
npm run db:migrate
```

Se algum passo falhar seguindo só este arquivo e o `README.md`, isso é um bug de documentação
(RNF09). Abra issue em vez de perguntar no grupo — a próxima pessoa vai tropeçar no mesmo lugar.

## Fluxo de branches

```
feature/<nome>  →  dev  →  release  →  main
```

- Sua branch nasce da `dev`, nunca da `main`.
- Push direto em `main`, `release` ou `dev` é bloqueado.
- Merge em `release` e `main` é só do responsável técnico.
- Todo PR precisa de revisão de outra pessoa antes do merge (RNF06).

Detalhes em Projeto_Matchmaking.md, seção 9.1.

## Commits

Conventional Commits, validados pelo commitlint no hook `commit-msg`:

```
feat(match): calcula score de afinidade por segmento e estagio
fix(auth): invalida sessao quando a conta e suspensa
docs(adr): registra a decisao de sessao opaca em Redis
```

Um commit por mudança lógica. Se a mensagem precisa de "e", provavelmente são dois commits.

### Sua mensagem de commit vira o changelog

**Não edite o `CHANGELOG.md`.** Ele é mantido pelo responsável técnico, a partir dos commits.

O rascunho é gerado com `npm run changelog:draft`, que lê o histórico e agrupa por tipo — `feat`
vira _Adicionado_, `fix` vira _Corrigido_, `refactor` e `perf` viram _Alterado_, e `chore`, `docs`,
`test`, `ci`, `build` e `style` ficam de fora. O rascunho sai em `CHANGELOG.draft.md`, que não é
versionado, e é reescrito à mão antes de virar entrada de verdade.

A consequência prática para você: commit mal descrito não some, vira buraco no changelog. Escreva a
mensagem pensando em quem vai ler o release, não em quem vai ler o diff.

## Antes de abrir o PR

```bash
npm run format:check
npm run lint
npm run typecheck
npm test
```

O hook de `pre-commit` roda formatação e tipos, mas hooks podem ser ignorados — a garantia é o CI.
**Nunca use `--no-verify`.** Se o hook barrou, o conserto é o código.

## Checklist do PR

- [ ] Endpoint, DTO e especificação OpenAPI alterados **no mesmo PR**. O front gera o cliente a
      partir do OpenAPI com Kubb; especificação divergente produz código errado com aparência de
      correto (seção 8.6).
- [ ] Variável de ambiente nova adicionada ao `.env.example` **no mesmo PR** (seção 7.2).
- [ ] Mensagem de commit descrevendo o **comportamento**, não o arquivo mexido — ela é a fonte do
      changelog. `feat(auth): exige MFA para administrador` serve; `feat(auth): mexe no middleware`
      não.
- [ ] Se o PR implementa algo que o `CONTEXT.md` lista como inexistente, **diga na descrição do
      PR**. Não edite o arquivo: quem atualiza é o responsável técnico, na revisão. Essa lista é o
      que impede alguém — pessoa ou IA — de escrever código assumindo que já existe autenticação,
      model ou endpoint que ainda não existe.
- [ ] Decisão arquitetural relevante registrada como ADR em `docs/adr/` (seção 6.4).
- [ ] Teste cobrindo o comportamento novo. Nos cinco fluxos críticos do RNF07, teste de
      **integração**, não unitário com dependência mockada.

## Quem revisa o seu PR

Duas coisas acontecem quando você abre um PR, e elas não se substituem.

**O CodeRabbit revisa automaticamente.** É um bot, configurado em
[`.coderabbit.yaml`](./.coderabbit.yaml), que conhece as regras deste repositório — fronteira de
camadas, proibição de `any`, exigência de teste de integração nos cinco fluxos críticos — e sinaliza
quando alguém escreve um número de negócio que ainda não foi decidido (peso de score, valor de cota,
preço de plano, prazo de tolerância).

Ele comenta em PRs direcionados a `dev` e `release`. Para pedir uma revisão manual, comente
`@coderabbitai review` no PR.

**O CodeRabbit não conta como a revisão que o RNF06 exige.** O requisito pede revisão por outro
**membro** do grupo. O bot é complemento: ele pega o que passa despercebido, mas não aprova nada em
nome de ninguém. Sugestão dele que você discordar, você discorda — com argumento, no próprio PR.

## O que o CI barra

O job `quality` roda em PR para `dev`, `release` e `main`, e é _required status check_ nas três
branches. PR com o job vermelho não é mesclado — **nem pelo responsável técnico**, porque a proteção
está com `enforce_admins` ligado.

Ele roda formatação, build e o **portão de qualidade** (`npm run quality`), que verifica sete coisas
de uma vez: testes, lint, vulnerabilidades de produção, tipos, ocorrências de `any`, de `as any`, de
supressão de tipo, e cobertura das linhas que o PR adicionou.

O portão não para na primeira falha — ele coleta tudo e reporta junto, para você não descobrir os
problemas um por push. Rode antes de abrir o PR:

```bash
npm run quality -- --base=origin/dev
```

Três comportamentos dele que valem saber:

- **Verificação que não consegue executar reprova.** Ferramenta que quebrou não é ferramenta que
  achou zero problema (seção 9.5).
- **Vulnerabilidade crítica é bloqueio absoluto**, sem entrada no baseline. As demais valem contra
  a lista de advisories aceitos em `quality-baseline.json`.
- **Cobertura é medida só sobre as linhas novas**, com mínimo de 70%. Código antigo descoberto não
  barra o seu PR; código novo sem teste barra.

## Regras que não são negociáveis

- **Teste que falha se conserta.** `.skip`, `.only` e ajustar asserção para passar são proibidos.
  Se o teste está errado, explique por quê no PR antes de mudá-lo.
- **Baseline do portão de qualidade é mudança visível.** Alterar o baseline precisa de aprovação de
  outra pessoa, com justificativa no PR. É isso que separa portão de lembrete (seção 9.5).
- **Nenhum segredo em arquivo versionado.** Nem senha de desenvolvimento, nem valor de exemplo que
  pareça real. Segredo vive em variável de ambiente e em GitHub Secrets.
- **Fronteira de camadas.** `controller` é a única camada que conhece HTTP; `repository` é a única
  que conhece Prisma. O ESLint recusa os imports que violam isso — não contorne a regra, mova o
  código.

## Mudança que atravessa repositórios

Funcionalidade que altera o contrato da API vive em dois PRs, sem merge atômico entre repositórios.
A ordem é fixa (seção 9.2):

1. `BackEnd-Last-PI` primeiro, com o OpenAPI atualizado no mesmo PR.
2. `FrontEnd-Last-PI` em seguida, regenerando o cliente.

A ordem inversa quebra a `dev` do front-end.
