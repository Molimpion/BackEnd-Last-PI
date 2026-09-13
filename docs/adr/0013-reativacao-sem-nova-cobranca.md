# ADR 0013 — Reativação dentro do período vigente, sem nova cobrança

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF17

## Contexto

Quando o usuário cancela a assinatura, ele já pagou pelo período corrente. Cancelar não é pedir
reembolso — é dizer "não renove". O acesso continua até o fim do período pago, no estado
`CANCELADA_VIGENTE`.

A pergunta é o que acontece se ele mudar de ideia antes desse fim. É um caso frequente: a pessoa
cancela no impulso, ou por dúvida sobre o valor, e volta atrás dias depois.

## Decisão

Em `CANCELADA_VIGENTE`, a reativação **desfaz a marcação de "não renovar"**. É imediata e **não
envolve cobrança** — o período já está pago.

Depois que a assinatura chega a `ENCERRADA`, não há mais nada vigente a reativar: o caminho passa a
ser contratação nova, com pagamento.

Isso adiciona a transição `CANCELADA_VIGENTE` → `ATIVA` à tabela do RF17.

## Alternativas recusadas

**Obrigar a recontratar, mesmo dentro do período vigente.** Recusado por duas razões. Cria fricção
desnecessária — cobrar de novo por um período que já foi pago é, na percepção do usuário, cobrança
duplicada, independentemente do que aconteça no backend. E abre risco técnico real: se o gateway
iniciar uma nova assinatura enquanto a anterior ainda vige, há dois ciclos de cobrança sobrepostos,
e desfazer isso envolve suporte manual e estorno.

**Cancelamento com efeito imediato, cortando o acesso na hora.** Recusado porque o usuário pagou
pelo período. Cortar antes é reter valor sem entregar serviço, e geraria pedido de reembolso — que a
plataforma não está preparada para processar.

**Tratar `CANCELADA_VIGENTE` como estado terminal.** Recusado: é ele que representa "pago, ativo,
mas não renova". Terminal é `ENCERRADA`.

## Consequências

- A máquina de estados do RF17 é a única referência válida. **Nenhuma transição fora dela é
  válida** — nem a de reativação, que precisou ser adicionada explicitamente.
- O cancelamento é uma marcação (`renovaEm` ou equivalente), não a destruição da assinatura. O
  rebaixamento é feito por rotina agendada no fim da vigência, não no ato do cancelamento.
- O dispatcher precisa da rotina que leva `CANCELADA_VIGENTE` para `ENCERRADA` ao fim do período —
  sem ela o usuário nunca é rebaixado.
- A reativação não toca o gateway. É operação puramente local, o que também a torna simples de
  testar.
- O fluxo de assinatura é um dos cinco fluxos críticos do RNF07, e este caminho precisa de teste de
  integração.

**Pendente:** se o cancelamento é permitido durante `INADIMPLENTE_EM_TOLERANCIA` e qual o efeito
(seção 11, item 14). Esse caso não está coberto por este ADR.
