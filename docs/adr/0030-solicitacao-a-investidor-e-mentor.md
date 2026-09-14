# ADR 0030 — Solicitação a investidor e mentor, com cota mensal e sem duplicata pendente

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF05, RF01, RF17

## Contexto

O [ADR 0004](./0004-cota-com-devolucao.md) descreve a cota como proteção do investidor e fala em
"número de solicitações por período" sem dizer qual período. Três lacunas apareceram ao modelar a
`Solicitacao`:

- O RF01 permite à startup buscar `MENTORIA`, mas o RF05 só descreve solicitação ao investidor.
- "Por período" não define quando a cota volta.
- Nada impede a startup de enviar uma segunda solicitação à mesma pessoa enquanto a primeira está
  pendente. A cota seria debitada duas vezes e a pessoa receberia duas notificações iguais.

## Decisão

**A startup pode enviar solicitação a investidor ou a mentor, e as duas consomem cota.** A
solicitação grava o papel do destinatário, porque a mesma pessoa pode ter os dois papéis e a
startup pode abordá-la por qualquer um deles.

**O período da cota é o mês calendário.** A cota volta no dia 1.

**No máximo uma solicitação pendente por startup, pessoa e papel**, garantido por índice único
parcial no banco. Depois de recusada ou expirada, a startup pode enviar de novo.

## Alternativas recusadas

**Solicitação só a investidor.** Recusado porque a natureza de busca `MENTORIA` do RF01 ficaria sem
fluxo de conexão.

**Mentoria sem cota.** Recusado porque o mentor também é atenção escassa. Sem cota, o disparo em
massa que o ADR 0004 contém migraria para os mentores.

**Período igual ao ciclo da assinatura.** Justo para o pagante, mas o plano gratuito não tem ciclo de
cobrança e precisaria de uma segunda regra.

**Bloquear duplicata só no caso de uso.** Recusado porque duas requisições simultâneas passam pela
checagem antes de qualquer uma gravar. Índice único é a única garantia que não depende de ordem de
chegada.

## Consequências

- O ADR 0004 continua valendo, e a devolução de cota vale também para recusa ou expiração de
  solicitação ao mentor.
- A contagem da cota é derivada: solicitações enviadas no mês corrente, menos as devolvidas. Não
  existe tabela de saldo.
- O índice parcial não é expressável no `schema.prisma` e vive no SQL da migration. Quem regerar a
  migration do zero precisa recolocá-lo; o teste de integração é o que denuncia a ausência.
- A `Solicitacao` guarda `enviadaEm`, e a contagem mensal usa esse campo, não `criadoEm`, para que o
  critério fique explícito na consulta.
