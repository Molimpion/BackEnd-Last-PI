# ADR 0004 — Cota de solicitações com débito no envio e devolução

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF05, RF17

## Contexto

O investidor é o lado escasso do marketplace, e sua atenção é o recurso disputado. A dor que ele
relata é exatamente essa: recebe centenas de abordagens sem padrão e perde tempo com startups fora
da sua tese.

Ao mesmo tempo, o produto não pode tirar da startup a agência de iniciar contato — é ela quem precisa
captar.

A cota é também o mecanismo que diferencia plano gratuito de plano pago (RF17), então a mesma regra
serve a dois propósitos.

## Decisão

A startup tem um número de solicitações por período, definido pelo plano contratado.

- A cota é **debitada no envio**.
- A cota é **devolvida** quando a solicitação é recusada pelo investidor ou quando expira.
- A solicitação expira automaticamente em **15 dias** sem resposta, por rotina do dispatcher.

Estados: `PENDENTE` → `ACEITA` | `RECUSADA` | `EXPIRADA`. A devolução ocorre nas transições para
`RECUSADA` e `EXPIRADA`.

## Alternativas recusadas

**Debitar apenas no aceite.** Recusado porque esvazia o propósito da cota. Se recusa é gratuita, o
custo de disparar para todo mundo é zero — e o ruído que a regra existe para conter volta
integralmente, agora com o selo da plataforma.

**Debitar sem devolver.** Recusado por punir a startup pela decisão de outra pessoa. A startup enviou
uma solicitação pertinente; o investidor recusou por motivo próprio, ou simplesmente não respondeu.
Consumir a cota nesses casos transforma um limite anti-ruído em penalidade arbitrária.

**Não ter cota, e conter o ruído só pelo limiar de afinidade.** Recusado porque o limiar filtra por
compatibilidade, não por volume. Uma startup compatível com cinquenta investidores poderia abordar os
cinquenta.

## Consequências

- **A cota fica bloqueada enquanto a solicitação está pendente.** É isso que produz o efeito
  anti-ruído: a startup precisa escolher para quem enviar, porque cada envio ocupa um lugar até ser
  resolvido.
- O dispatcher precisa de uma rotina periódica varrendo solicitações vencidas — a expiração não pode
  depender de alguém abrir a tela.
- `expiraEm` é gravado na criação, não calculado na leitura: a varredura precisa de índice, e mudar a
  regra depois não pode alterar o prazo de solicitações já enviadas.
- Rebaixamento de plano precisa decidir o que acontece com solicitações pendentes acima da nova cota.
- O controle de cota é um dos cinco fluxos críticos do RNF07: teste de integração obrigatório,
  cobrindo especialmente os caminhos de devolução.

**Pendente:** os valores de cota por plano não foram definidos (seção 11, item 8).
