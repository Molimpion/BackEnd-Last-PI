# ADR 0028 — Plano por público, em três níveis

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF17, RF05, RF09, RF15

## Contexto

O RF17 descreve dois planos, gratuito e pago, e uma tabela de recursos que mistura os dois lados do
marketplace:

| Recurso                            | Quem usa   |
| ---------------------------------- | ---------- |
| Cota de solicitações               | Startup    |
| Matches visíveis                   | Investidor |
| Busca com filtro avançado          | Todos      |
| Métricas de visualização de perfil | Todos      |
| Exportação de relatórios           | Todos      |

Três perguntas ficaram sem resposta ao escrever o schema: quantos planos existem, se um plano vale
para qualquer conta, e como os limites ficam guardados.

A segunda esbarra no [ADR 0010](./0010-tipo-de-conta-e-papeis-acumulaveis.md). `INVESTIDOR` e
`MENTOR` são papéis acumuláveis dentro de `PESSOA`, não tipos de conta. Um plano "de pessoa" não
consegue diferenciar o que o investidor e o mentor ganham pagando.

## Decisão

**O plano tem público e nível.** Público: `STARTUP`, `INVESTIDOR`, `MENTOR`. Nível: `GRATUITO`,
`PRO`, `PREMIUM`. São nove planos, um por combinação.

**O gratuito é uma linha da tabela**, não a ausência de plano. O estado `SEM_PLANO` do RF17 continua
existindo na assinatura, mas os limites aplicados vêm da linha `GRATUITO` do público correspondente.
Todo limite é lido do mesmo lugar.

**Um limite por coluna**, não um documento JSON:

| Coluna                     | Público    |
| -------------------------- | ---------- |
| `precoEmCentavos`          | Todos      |
| `cotaMensalDeSolicitacoes` | Startup    |
| `limiteDeMatchesVisiveis`  | Investidor |
| `limiteMensalDeAceites`    | Mentor     |
| `feedbackDetalhado`        | Mentor     |
| `destaqueNaBusca`          | Mentor     |
| `buscaAvancada`            | Todos      |
| `metricasDeVisualizacao`   | Todos      |
| `exportacaoDeRelatorios`   | Todos      |

Limite numérico nulo significa sem limite. Coluna que não se aplica ao público do plano é ignorada.

**A assinatura é por conta e público.** Uma pessoa que é investidora e mentora pode ter duas
assinaturas independentes, cada uma com seu estado, cobrança e janela de tolerância.

**Cobranças ficam em tabela própria**, com os estados `PENDENTE`, `PAGA`, `FALHOU` e `ESTORNADA`. É o
que sustenta a funcionalidade "consultar histórico de cobranças" do RF17.

### Recursos exclusivos do mentor

Nenhuma linha do RF17 é do mentor. Sem recurso próprio, o plano pago dele seria o do investidor com
outro nome. Três recursos foram criados:

- **`feedbackDetalhado`** — todo mentor vê a nota geral recebida; o plano pago vê a nota por critério
  e a evolução ao longo do tempo.
- **`limiteMensalDeAceites`** — quantas solicitações o mentor aceita por mês.
- **`destaqueNaBusca`** — prioridade na busca manual. Decisão com tensão própria, registrada no
  [ADR 0029](./0029-destaque-pago-do-mentor-na-busca.md).

## Alternativas recusadas

**Dois planos, como o RF17 descreve.** Recusado pelo grupo em favor de três níveis. O RF17 fixa a
existência de gratuito e pago, não o número de degraus.

**Plano único para qualquer conta.** Recusado porque a startup poderia contratar um plano cujo
recurso principal é do investidor, e a tela de contratação precisaria explicar colunas que não
servem para quem está lendo.

**Público `STARTUP` e `PESSOA`.** Recusado porque investidor e mentor ganham coisas diferentes pagando,
e o tipo de conta não distingue os dois.

**Limites num campo JSON.** Acrescentaria recurso sem migration, mas o banco e o Prisma deixam de
verificar o tipo. O código do matchmaking passaria a interpretar um documento em vez de ler
`plano.buscaAvancada`.

**Gratuito como ausência de plano.** Recusado porque os limites do gratuito ficariam no código e os
do pago no banco. Cada leitura de limite precisaria de um desvio para o caso sem plano.

**Uma assinatura por conta.** Recusado como consequência do público por papel: a pessoa com os dois
papéis teria de escolher de qual lado paga.

## Consequências

- A tabela `Plano` nasce **sem seed**. Preços e limites continuam em aberto (seção 11), e popular a
  tabela com números inventados seria decidir por quem não decidiu.
- O nível intermediário `PRO` não está descrito em nenhum documento. Os valores das suas colunas são
  decisão de produto pendente.
- Pessoa com os dois papéis tem dois fluxos de pagamento em paralelo. Webhook, outbox e rotina de
  tolerância operam por assinatura, nunca por conta.
- A assinatura só pode apontar para plano do mesmo público. O banco não expressa essa restrição entre
  tabelas; ela vive no caso de uso de assinatura.
- Quem perde o papel perde o efeito da assinatura daquele público na requisição seguinte, pela mesma
  regra de RBAC do ADR 0010. O que acontece com a cobrança nesse caso não está decidido.
- **Pendente:** o comportamento de `limiteMensalDeAceites` quando o mentor atinge o limite — se as
  solicitações pendentes ficam bloqueadas até o mês seguinte, expiram, ou se a startup é impedida de
  enviar.
