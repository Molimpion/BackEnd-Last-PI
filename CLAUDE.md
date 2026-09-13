# CLAUDE.md — BackEnd-Last-PI

API do Projeto Matchmaking: plataforma de conexão entre startups e investidores anjo do Porto
Digital. **Não intermedeia investimento** — não processa aporte, não custodia valor, não formaliza
participação societária. A jornada termina na reunião realizada e no feedback.

## Onde procurar cada coisa

| Preciso de                                          | Vá em                                                            |
| --------------------------------------------------- | ---------------------------------------------------------------- |
| Requisito, critério de aceitação, racional          | [`Projeto_Matchmaking.md`](./Projeto_Matchmaking.md)             |
| Estado atual e próximo passo                        | [`CONTEXT.md`](./CONTEXT.md)                                     |
| Por que uma decisão foi tomada e o que foi recusado | [`docs/adr/`](./docs/adr/)                                       |
| Fluxo de branches, checklist de PR                  | [`CONTRIBUTING.md`](./CONTRIBUTING.md)                           |
| Dúvida recorrente sobre a configuração              | [`docs/perguntas-frequentes.md`](./docs/perguntas-frequentes.md) |
| O que um arquivo específico faz                     | [`docs/sumario.md`](./docs/sumario.md)                           |

Não transcreva requisito para cá. Cite a seção (`RF03`, `RNF07`, `seção 8.4`) e siga.

## Comandos

```bash
npm run dev                       # API em watch
npm run dev:worker                # worker
npm run dev:dispatcher            # dispatcher
npm run quality                   # portão: testes, lint, tipos, vulnerabilidades, any, cobertura
npm run quality -- --base=origin/dev
npm run db:migrate                # cria e aplica migration
```

**Antes de considerar qualquer task pronta, rode `npm run quality`.** "Deve funcionar" não conta.

## Arquitetura

Três processos, não um (seção 6.4): `src/api.ts` responde HTTP e WebSocket, `src/worker.ts` consome
as filas do BullMQ, `src/dispatcher.ts` varre o outbox e roda as rotinas periódicas. Requisição HTTP
nunca executa trabalho demorado — a API registra a intenção e responde.

Código organizado **por feature**, não por categoria técnica. O transversal mora em `src/infra/`,
com nome que diz o que é. **Não existe `utils/` nem `types.ts` global.**

### A dependência aponta para dentro

```
controller  →  usecase | service  →  repository
```

| Camada                 | Restrição                                                                  |
| ---------------------- | -------------------------------------------------------------------------- |
| `controller`           | Única que conhece HTTP. Sem regra de negócio                               |
| `dto`                  | Valida com Zod **na borda**. Abaixo dele o dado é confiável — não revalide |
| `service` / `usecases` | Regra pura. Não conhece `request`/`response`                               |
| `repository`           | Única que conhece Prisma. Sem regra de negócio                             |

O ESLint recusa os imports que violam isso. Se a regra barrou, mova o código — não contorne.

### Use case ou service?

- **Use case** se a operação tem mais de um passo, toca mais de uma tabela ou tem decisão
  condicional relevante. Domínios: auth, match, solicitações, assinatura, moderação, autorização de
  dados protegidos. Nesses, o controller chama o caso de uso **direto** — não existe service
  intermediário.
- **Service** se é ler e devolver. Domínios: cadastros, canvas, perfis, reuniões, auditoria,
  notificações.

Não é coincidência que os domínios com use case sejam os cinco fluxos críticos do RNF07.

## Convenções de código

- **ESM.** Import relativo sempre com extensão `.js`, inclusive apontando para `.ts`.
  `import { env } from "./infra/env.js"`.
- **Sem comentário.** O "porquê" vai na resposta, no ADR ou no `CONTEXT.md`. `TODO` com motivo é a
  única exceção.
- **Identificadores em português, sem acento.** `criarApp`, `desconectarBanco`, `tratadorDeErros`,
  `naoEncontrado`. Nomes que espelham conceito de framework mantêm o original (`AppError`,
  `Logger`).
- **Sem `any`.** O portão conta ocorrências e reprova acima do baseline.
- **Entidade de persistência nunca cruza para o transporte.** Request e response separados da
  entidade — é o que impede hash de senha e campo interno vazarem numa serialização automática.
- **Nome de teste descreve comportamento**, não implementação: "responde 400 quando falta a pauta",
  não "testa o superRefine".

## Decisões que não se reabrem sem ADR

| Decisão                                                      | Por quê                                                                                            |
| ------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| Sessão opaca em Redis, **nunca JWT**                         | O produto exige revogação imediata: moderação reprova, assinatura vence, conta é suspensa          |
| Score de matchmaking **determinístico**                      | Explicabilidade exigida por V&V. Mesmo par de perfis, mesmo score, verificável em teste            |
| Exibição por **limiar**, não corte eliminatório              | Corte rígido produz tela vazia na partida a frio                                                   |
| Cota debitada no **envio**, devolvida em recusa ou expiração | Debitar só no aceite incentiva disparo em massa; não devolver pune a startup por recusa alheia     |
| Exclusão por **anonimização**, não remoção                   | Chat contém dado de terceiro e as métricas dependem dos registros de interação                     |
| **Outbox** só no fluxo de pagamento                          | Não existe transação entre PostgreSQL e Redis. Aplicar a todo o sistema seria overhead sem retorno |
| Liberação de plano **só por webhook validado**               | Nunca pelo retorno de navegação do usuário                                                         |

## Armadilhas já mapeadas

- **Cookie entre domínios** (seção 8.1). Front na Vercel, back no Render: `SameSite=None` mais
  `Secure`, e CORS com origem explícita e credenciais. O sintoma se disfarça de bug de autenticação
  — o login parece funcionar e a requisição seguinte dá "não autenticado".
- **OpenAPI é contrato executável** (seção 8.6). O front gera o cliente com Kubb a partir dela.
  Endpoint, DTO e especificação mudam **no mesmo PR**.
- **RBAC calculado por requisição.** Permissão vem dos papéis **ativos agora**, nunca de valor
  copiado na criação da sessão.
- **Serviço de IA não pode derrubar a plataforma** (RNF11). Toda chamada com timeout e degradação
  graciosa.

## Pare e pergunte

Estes números **não estão definidos** (seção 11). Escrever qualquer um deles é inventar regra de
negócio:

- Pesos exatos do score de afinidade e o valor do limiar (RF03).
- Valores das cotas por plano e preço dos planos (RF17).
- Prazo da janela de tolerância por inadimplência — sem ele a transição não é testável.
- Se cancelamento é permitido durante `INADIMPLENTE_EM_TOLERANCIA` e qual o efeito.
- Qual a função da IA no produto. O repositório pode ser descartado.

Também pare ao escrever qualquer condição, validação, limite ou valor padrão que mude o que o
sistema faz do ponto de vista de quem usa e que não esteja no documento. Mecânica de linguagem
(null check, guarda de lista vazia) não conta.

## Não faça

- **Não edite `CHANGELOG.md`.** É mantido pelo responsável técnico a partir dos commits.
- **Não edite a seção "Onde estamos" do `CONTEXT.md`.** Também é do responsável técnico. Se o
  trabalho implementou algo que ela lista como inexistente, informe na resposta do turno e na
  descrição do PR — não atualize por conta própria.
- **Não edite `src/generated/`.** É saída do `prisma generate`, regerada a cada `npm ci`.
- **Não use `--no-verify`, `--force` nem `git reset --hard`.** Hook que barrou se conserta no
  código.
- **Não mocke Redis, PostgreSQL ou repositório nos cinco fluxos críticos** do RNF07. Eles falham em
  configuração, não em lógica isolada — suíte 100% unitária atende o requisito no papel e não na
  prática.
- **Não apague nem pule teste que falha.** `.skip` e `.only` são proibidos.
- **Não altere `.env` nem escreva segredo em arquivo versionado.** Variável nova entra no
  `.env.example` no mesmo PR.
- **Não suba o baseline do portão** para fazer um PR passar sem justificativa explícita.
