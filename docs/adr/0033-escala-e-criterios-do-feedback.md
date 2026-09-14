# ADR 0033 — Escala e critérios do feedback

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF10, RF08

## Contexto

O RF10 exige nota e campos estruturados e cita os critérios de dois lados:

- A startup avalia a **qualidade da conversa** e a **utilidade da orientação**.
- O investidor avalia a **preparação da startup** e a **aderência à sua tese**.

A escala ficou pendente no [ADR 0012](./0012-visibilidade-assimetrica-do-feedback.md), como dúvida
3 da matriz CSD. E o mentor avaliando a startup não foi previsto: mentor não tem tese de
investimento, então "aderência à tese" não se aplica a ele.

## Decisão

**Nota de 1 a 5 por critério.** Texto livre é opcional e complementa, nunca substitui.

| Quem avalia          | Critérios                                        |
| -------------------- | ------------------------------------------------ |
| Startup → pessoa     | Qualidade da conversa, utilidade da orientação   |
| Investidor → startup | Preparação da startup, aderência à tese          |
| Mentor → startup     | Preparação da startup, **abertura à orientação** |

"Abertura à orientação" é critério novo: avalia se a startup recebeu e aproveitou a mentoria.

**A nota geral é derivada** da média dos critérios, não gravada.

## Alternativas recusadas

**Nota geral informada pela pessoa, além dos critérios.** Recusado porque pode divergir da média dos
critérios, e aí ninguém sabe qual das duas vale.

**Escala de 0 a 10.** Mais granular, mas a diferença entre 7 e 8 é menos consistente entre pessoas do
que a diferença entre 3 e 4 estrelas.

**Mentor avalia só a preparação.** Recusado pelo grupo em favor de um segundo critério que meça o que
é específico da mentoria.

**Mentor usa os critérios do investidor.** Recusado porque "aderência à tese" obrigaria o mentor a
interpretar um conceito que não é dele, e a nota perderia comparabilidade.

## Consequências

- A escala ainda deve ser validada na rodada beta (RNF04). Mudar a escala depois exige converter as
  notas já gravadas.
- A nota pública da startup mistura avaliações de investidores e de mentores com um critério em
  comum e um diferente. A exibição precisa decidir se mostra por critério ou só a média.
- O critério "abertura à orientação" não está no `Projeto_Matchmaking.md` e precisa ser refletido lá
  pelo responsável técnico.
- O `feedbackDetalhado` do [ADR 0028](./0028-plano-por-publico-em-tres-niveis.md) é o que dá ao
  mentor pagante a visão por critério.
