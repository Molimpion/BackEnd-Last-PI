# ADR 0031 — Mentor também pode pedir acesso ao perfil completo

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF13, RF04, RNF10

## Contexto

O RF13 descreve o fluxo de autorização a partir do investidor: ele pede acesso ao perfil completo
(Canvas integral, tração, números), a startup aprova ou nega, e pode revogar a qualquer momento.

O mentor não é citado. Mas o mentor orienta a startup, e orientar sem ver o Canvas se limita ao que
está no perfil público: nome, segmento, estágio e descrição curta.

## Decisão

**Investidor e mentor podem pedir acesso ao perfil completo.** A autorização grava o papel de quem
pediu, e a startup vê se o pedido veio de investidor ou de mentor antes de decidir.

**No máximo um pedido pendente por startup, pessoa e papel**, com índice único parcial. Negativa não
bloqueia novo pedido, como o RF13 exige.

## Alternativas recusadas

**Só investidor, literal do RF13.** Recusado porque deixaria a mentoria restrita ao perfil público,
esvaziando a natureza de busca `MENTORIA` do RF01.

**Acesso automático para mentor após solicitação aceita.** Recusado porque o RF04 exige autorização
**expressa** para dado protegido. Aceitar conversar não é o mesmo que abrir os números.

## Consequências

- A startup decide com mais informação: pode liberar para o mentor e negar para o investidor, ou o
  contrário.
- Pessoa com os dois papéis que pede pelos dois lados gera dois registros, e a revogação é por
  registro.
- Todo acesso a dado protegido continua gerando registro de auditoria, independentemente do papel.
