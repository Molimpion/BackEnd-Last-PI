# ADR 0027 — Valor monetário guardado em centavos e exibido como faixa

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF01, RF02, RF03, RNF04

## Contexto

A startup declara quanto busca e o investidor declara seu ticket. Os dois campos são faixas
(`minimo` e `maximo`) e existem para um único fim: alimentar o critério de ticket do motor de
afinidade. **Nenhum valor é cobrado, transferido ou custodiado** — o
[ADR 0009](./0009-plataforma-de-conexao-nao-de-intermediacao.md) é explícito quanto a isso.

Duas questões separadas precisavam de resposta: como guardar e como mostrar.

**Guardar.** Valor com casa decimal em ponto flutuante acumula erro de arredondamento. `0.1 + 0.2`
não resulta em `0.3`, e somar `0.1` dez vezes não resulta em `1`. Numa operação isolada ninguém
percebe; em soma, média e comparação o erro aparece como centavo a mais ou a menos, impossível de
explicar depois.

**Mostrar.** Número exato dá precisão à justificativa do RF03 ("ticket 20% acima da sua faixa"), mas
um valor cru na tela é mais difícil de ler de relance — e o cartão de afinidade existe para ser lido
em segundos.

## Decisão

**Guardar em centavos, como inteiro.** `R$ 1.500,50` vira `150050`. Inteiro não tem erro de
arredondamento.

**Exibir agrupado como faixa:** `R$ 100 mil – R$ 500 mil`. Decisão do time de front-end.

O front multiplica por 100 ao enviar e formata na exibição. O backend nunca devolve string
formatada — devolve o inteiro, e a formatação é responsabilidade de quem apresenta.

Regras de preenchimento já decididas, registradas aqui para não se perderem:

- **O teto é obrigatório.** Ninguém deixa em branco, o que evita caso especial na regra do score ao
  custo de obrigar quem não tem limite a declarar um valor alto.
- **Valor mínimo aceito: R$ 1.000.** Barra cadastro de teste e erro de digitação — alguém digita
  `500` querendo dizer quinhentos mil.
- **Há compatibilidade quando os intervalos se sobrepõem** em qualquer ponto.
- O cartão indica **se o ticket está acima ou abaixo** do que a outra parte busca, visível aos dois
  lados.

## Alternativas recusadas

**Guardar em reais com casa decimal.** Recusado pelo erro de ponto flutuante descrito no contexto.
Centavos em inteiro é o padrão da indústria justamente porque o problema é conhecido e não tem
contorno elegante.

**Usar `Decimal` do Prisma.** Mais correto para valores monetários arbitrários, mas traz um tipo que
atravessa serialização com atrito e complica o contrato com o front. Para faixa de investimento,
inteiro em centavos basta com folga.

**Guardar faixas nomeadas em vez de números** (`ATE_50K`, `DE_50K_A_200K`, …). Preenchimento mais
rápido e zero casos de borda. Recusado porque inviabiliza a justificativa precisa: com enum, o máximo
que o sistema consegue dizer é "faixa adjacente à sua", e o RF03 usa "20% acima" como exemplo do que
se espera. Trocar de números para faixas depois é simples; o caminho inverso exige migração de dado,
então começar com números preserva a opção.

**Exibir o número cru.** Recusado pelo front: `R$ 100 mil – R$ 500 mil` é mais rápido de ler que
`R$ 100.000 – R$ 500.000`, e o cartão de afinidade precisa ser legível de relance (RNF04).

**Devolver o valor já formatado pela API.** Recusado: formatação é apresentação. Backend devolvendo
string pronta impede o front de exibir diferente em contextos diferentes e vaza decisão de interface
para dentro da regra de negócio.

## Consequências

- Todo valor monetário no banco é `Int` em centavos. Nenhuma exceção — regra única evita a pergunta
  "esse campo aqui é em reais ou centavos?".
- A conversão vive na borda: o front multiplica ao enviar, divide ao exibir. Duas linhas, uma em
  cada ponta.
- O DTO de entrada valida o mínimo de R$ 1.000 e que `minimo` não seja maior que `maximo`.
- A regra de agrupamento na exibição é do front e pode mudar sem tocar no backend — é o benefício de
  guardar o número exato.
- O mesmo padrão vale para o preço dos planos do RF17, quando ele for definido.
