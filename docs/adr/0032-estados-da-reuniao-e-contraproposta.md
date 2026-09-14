# ADR 0032 — Estados da reunião e contraproposta como histórico

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF05, RF09, RF10

## Contexto

O RF05 descreve o agendamento: a startup propõe data, hora e pauta; a outra parte aceita, recusa ou
contrapropõe horário; o sistema registra a reunião e seu desfecho. Não fecha a lista de estados.

Dois pontos ficaram abertos: se contraproposta é estado ou evento, e quantas reuniões uma solicitação
aceita pode ter.

## Decisão

**Estados:** `PROPOSTA`, `CONFIRMADA`, `RECUSADA`, `REALIZADA`, `NAO_REALIZADA`.

**Contraproposta não é estado.** Cada proposta de horário é uma linha em `PropostaDeHorario`, com
autor e data/hora. A reunião continua em `PROPOSTA`, e o horário vigente é o da proposta mais recente.

**Uma solicitação aceita pode originar várias reuniões, com no máximo uma ativa por vez.** Ativa é
`PROPOSTA` ou `CONFIRMADA`. Depois de `RECUSADA`, `REALIZADA` ou `NAO_REALIZADA`, as partes podem
marcar outra.

## Alternativas recusadas

**Estado `CONTRAPROPOSTA`.** Recusado porque a negociação pode ir e voltar várias vezes, e um estado
só registra que houve contraproposta, não quantas nem de quem.

**Sobrescrever data e hora na reunião.** Recusado por apagar a negociação, contrariando a regra de
não excluir registro de interação.

**Sem `NAO_REALIZADA`.** Reunião confirmada que não aconteceu ficaria presa em `CONFIRMADA`. O desfecho
do RF05 e o caso do investidor que não aparece, citado no ADR 0012, precisam de onde ficar.

**Uma reunião por solicitação.** Recusado porque um desencontro obrigaria a startup a gastar nova
cota para voltar a falar com quem já aceitou.

## Consequências

- "Uma ativa por vez" é índice único parcial no SQL da migration, pelo mesmo motivo do
  [ADR 0030](./0030-solicitacao-a-investidor-e-mentor.md).
- Só reunião `REALIZADA` libera o feedback do RF10.
- Não existe cancelamento de reunião confirmada. Se o grupo quiser permitir, é estado novo e ADR novo.
- Quem marca `REALIZADA` ou `NAO_REALIZADA`, e o que acontece quando as partes discordam do
  desfecho, não está decidido.
