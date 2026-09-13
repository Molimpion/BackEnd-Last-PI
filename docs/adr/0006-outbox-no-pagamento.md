# ADR 0006 — Padrão outbox no fluxo de pagamento

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF17, RNF07, RNF10

## Contexto

Ao receber a confirmação de pagamento do gateway, o sistema precisa fazer duas coisas que vivem em
tecnologias diferentes:

1. Gravar o fato no PostgreSQL.
2. Enfileirar o trabalho decorrente no Redis — liberar o plano, notificar o usuário.

**Não existe transação que abranja as duas.** Se a gravação no banco tiver sucesso e o enfileiramento
falhar, o pagamento consta como confirmado e ninguém libera o plano. A falha é silenciosa: o gateway
recebeu resposta de sucesso e não vai reenviar, o usuário pagou, e nada no sistema indica que algo
quebrou.

Esse é o pior tipo de falha de um produto que cobra assinatura — ela aparece como reclamação de
usuário, dias depois, sem rastro.

## Decisão

Na **mesma transação do banco**, grava-se o evento de pagamento e uma linha de trabalho pendente com
`enfileiradoEm IS NULL`.

O processo _dispatcher_ varre essa tabela, reserva as linhas com `FOR UPDATE ... SKIP LOCKED` —
o que permite múltiplas instâncias sem coordenação entre elas — enfileira no BullMQ e marca como
enfileirado. Se o Redis estiver indisponível, o trabalho permanece registrado no banco e é retomado
depois.

**Escopo: apenas o fluxo de pagamento.**

Três defesas de idempotência, conscientemente redundantes:

1. Restrição de unicidade no ID do evento do gateway, com `ON CONFLICT DO NOTHING`.
2. `jobId` do BullMQ derivado do identificador do trabalho — job repetido é descartado pela fila.
3. Verificação de estado antes de aplicar o efeito — plano já liberado não é liberado de novo.

## Alternativas recusadas

**Confiar no reenvio de webhook do gateway.** Recusado como defesa principal, porque o problema não é
o webhook não chegar — ele chegou e foi respondido com sucesso. O reenvio não cobre falha que
acontece depois do `200`. Continua relevante para o caso em que o endpoint está fora do ar no
primeiro envio, situação em que não existe transação local para proteger nada.

**Enfileirar primeiro e gravar depois.** Recusado: inverte o problema. O worker poderia processar um
pagamento que nunca foi gravado.

**Aplicar outbox em todo o sistema.** Recusado por custo sem retorno. Notificação perdida é
incômodo; confirmação de pagamento perdida é dinheiro e é reclamação. A complexidade se paga em um
lugar só.

**Liberar o plano pelo retorno de navegação do usuário.** Recusado e proibido pelo RF17. O retorno de
navegação é controlado pelo cliente e pode ser forjado; a liberação ocorre exclusivamente por webhook
com assinatura validada.

## Consequências

- O dispatcher deixa de ser opcional: sem ele, nada sai do outbox. Ele precisa existir em produção,
  não só a API.
- Existe latência entre a confirmação e o efeito, limitada pelo intervalo de varredura.
- A tabela de trabalho pendente precisa de índice em `enfileiradoEm` e de uma política de limpeza —
  ela cresce indefinidamente se ninguém remover o que já foi processado.
- Webhook validado antes de qualquer processamento: endpoint isento de CSRF não é endpoint isento de
  autenticação.
- O fluxo de assinatura e webhook é um dos cinco fluxos críticos do RNF07 — teste de integração
  obrigatório, cobrindo webhook duplicado e Redis indisponível.
