# ADR 0026 — Sobreposição de segmentos no score é tudo ou nada

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF01, RF02, RF03

## Contexto

A startup pode declarar **até dois** segmentos, e o investidor declara quantos segmentos de
interesse quiser. Com isso, o pedaço do score correspondente a segmento deixou de ser "igual ou
diferente" e passou a admitir acerto parcial:

```
Startup:    HEALTHTECH, FINTECH
Investidor: FINTECH, EDTECH
```

Há um segmento em comum de dois declarados. Quanto isso vale?

A conta é sempre sobre **os segmentos da startup**, nunca sobre os do investidor. Se fosse sobre os
do investidor, quem declara oito setores de interesse teria "1 de 8" com todo mundo e tiraria nota
baixa sempre — punindo quem investe de forma ampla, que é comportamento legítimo e não um defeito de
perfil.

## Decisão

**Tudo ou nada.** Pelo menos um segmento em comum concede a pontuação cheia do critério de segmento.
Nenhum em comum concede zero.

## Alternativas recusadas

**Proporcional ao número de segmentos da startup.** Parece mais justo, e é a armadilha desta
decisão. Com segmento valendo 40 pontos:

|                                      | Acertos | Pontos |
| ------------------------------------ | ------- | ------ |
| Startup A — `HEALTHTECH`             | 1 de 1  | 40     |
| Startup B — `HEALTHTECH` + `FINTECH` | 1 de 2  | 20     |

Contra um investidor que busca `HEALTHTECH`, as duas são **igualmente** healthtech. A B apenas
também atua em fintech — e leva metade da pontuação por ter declarado isso.

O efeito previsível é que as startups aprendem a declarar **um segmento só**, porque rende mais
match. A permissão de marcar dois vira letra morta, e o investidor perde informação que existia e foi
escondida para melhorar o score. A regra criaria incentivo contra a própria qualidade do dado.

**Proporcional com piso** (um acerto garante 60%, o segundo completa). Ameniza o problema sem
eliminá-lo: a startup B ainda tiraria 24 contra 40 da A, e o incentivo a esconder o segundo segmento
continua, apenas menor. Custa uma regra a mais para documentar, testar e explicar, sem resolver o
que motivou recusar a proporcional.

**Contar sobre os segmentos do investidor.** Recusado pelo motivo descrito no contexto: penaliza tese
ampla, que é legítima.

## Consequências

- **Declarar o segundo segmento passa a ser informação sem custo.** A startup não perde nada por ser
  precisa sobre o que faz, que é o comportamento que o produto quer incentivar.
- A justificativa em linguagem natural do RF03 fica direta: _"compatível em fintech"_. Não há
  percentual de segmento para explicar.
- O critério de segmento vira booleano no cálculo. Simples de implementar e de testar por igualdade,
  o que serve ao requisito de determinismo do [ADR 0003](./0003-score-deterministico.md).
- **Perde-se granularidade.** Uma startup que bate nos dois segmentos do investidor pontua igual a
  uma que bate em um. Se a base crescer a ponto de o score de segmento deixar de diferenciar
  ninguém, esta decisão deve ser reavaliada — e o caminho é um ADR novo, não editar este.
- O limite de dois segmentos por startup é o que torna a perda aceitável. Se esse limite subir, o
  argumento enfraquece: com cinco segmentos permitidos, "acertou um" e "acertou cinco" seriam
  diferenças grandes demais para tratar igual.

**Pendente:** quantos dos 100 pontos cabem ao segmento. Faz parte dos pesos do RF03, que continuam
indefinidos (seção 11, item 7).
