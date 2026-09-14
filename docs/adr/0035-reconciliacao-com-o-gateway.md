# ADR 0035 — Reconciliação periódica com o gateway de pagamento

**Status:** Aceito, condicionado à confirmação de que a API da AbacatePay permite consultar cobranças.
Substitui parcialmente o [ADR 0006](./0006-outbox-no-pagamento.md) e a regra "liberação de plano só
por webhook validado".
**Data:** 2026-09-14
**Requisito:** RF17, RNF07, RNF10, seção 8.2, seção 8.4

## Contexto

O [ADR 0006](./0006-outbox-no-pagamento.md) protege o pagamento **depois** que o webhook chega: o
fato é gravado junto do trabalho pendente, e nada se perde se o Redis cair. Ele não protege o caso em
que o webhook **nunca chega**:

1. A pessoa paga.
2. O gateway envia o webhook.
3. A API está fora do ar — o Render gratuito hiberna sem tráfego (seção 8.2).
4. Nenhuma linha é gravada. A pessoa pagou e continua no plano gratuito, e nada no sistema indica
   falha.

A única defesa hoje é o reenvio do gateway, cuja política ainda não foi confirmada (seção 11,
pendência 2).

A regra "liberação só por webhook validado" existe para impedir que o plano seja liberado pelo
**retorno de navegação** do usuário, que é controlado pelo cliente e pode ser forjado. Uma consulta
feita pelo servidor à API do gateway, autenticada com a chave secreta da plataforma, não tem esse
problema.

## Decisão

**O plano é liberado por confirmação do gateway — recebida por webhook validado ou consultada pelo
servidor.** Nunca pelo retorno de navegação.

Uma rotina periódica do **dispatcher** consulta no gateway as cobranças recentes e compara com a
tabela `Cobranca`. Cobrança paga no gateway e não paga no banco é divergência.

**A reconciliação não libera o plano.** Ela grava um `EventoDoGateway` com `origem = RECONCILIACAO`
e segue o **mesmo caminho** do webhook: mesma transação com o outbox, mesmo worker, mesmo código de
efeito. Existe um único lugar que libera plano.

**A proteção contra efeito duplicado é a transição da cobrança.** A passagem de `PENDENTE` para
`PAGA` é uma atualização condicional (`WHERE status <> 'PAGA'`). Se o webhook atrasado e a
reconciliação processarem a mesma cobrança, o segundo não altera linha nenhuma e não produz efeito.

**A associação entre cobrança do gateway e conta é feita pelo ID da cobrança**, gravado quando o
checkout é iniciado. Nunca por e-mail, nome ou valor.

## Alternativas recusadas

**Reconciliação apenas alerta o administrador, que reprocessa manualmente.** Respeitava a regra
original sem mudança. Recusado porque o custo cai sobre quem pagou: um webhook perdido na sexta à
noite deixa a pessoa sem o plano até alguém olhar na segunda.

**Reconciliação com código próprio de liberação.** Recusado porque dois caminhos que fazem a mesma
coisa divergem com o tempo — um bug corrigido num deles continua no outro.

**Não reconciliar e confiar no reenvio do gateway.** Recusado porque deixa o caso do servidor fora
do ar dependendo de um comportamento de terceiro que ninguém confirmou.

**Deduplicar pelo ID do evento, como o ADR 0006.** Insuficiente sozinho: o evento da reconciliação
não tem o ID do webhook, e os dois passariam pela restrição de unicidade. O ID do evento continua
deduplicando webhook repetido; a transição condicional da cobrança deduplica entre origens.

## Consequências

- **Dependência externa não confirmada.** Se a API da AbacatePay não permitir consultar cobranças,
  esta decisão não é implementável e o sistema volta a depender só do reenvio. Confirmar antes de
  implementar o RF17.
- `EventoDeWebhook` passa a se chamar `EventoDoGateway`, com o campo `origem` (`WEBHOOK`,
  `RECONCILIACAO`). O nome antigo mentiria sobre metade das linhas.
- A defesa 3 do ADR 0006 ("verificação de estado antes de aplicar o efeito") deixa de ser só
  redundância e passa a ser a proteção principal entre origens. Precisa ser atualização condicional
  no banco, não leitura seguida de escrita — duas execuções simultâneas passariam na leitura.
- O teste de integração do fluxo de pagamento (RNF07) ganha dois casos: reconciliação encontra
  cobrança perdida e libera; webhook atrasado chega depois da reconciliação e não produz efeito.
- A consulta ao gateway precisa de timeout e não pode derrubar o dispatcher, pelo mesmo motivo do
  RNF11.
- O intervalo da rotina e a janela de cobranças consultadas não estão definidos.
- A regra correspondente no `CLAUDE.md` e o critério do RF17 no `Projeto_Matchmaking.md` mudam de
  "só por webhook validado" para "só por confirmação do gateway".
