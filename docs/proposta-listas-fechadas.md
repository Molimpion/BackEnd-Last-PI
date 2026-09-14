# As três listas fechadas — decididas

**Status:** decidido. Este arquivo será apagado assim que os enums entrarem no
`prisma/schema.prisma`.

Eram os três pontos que bloqueavam a primeira migration: o `Projeto_Matchmaking.md` os exige mas não
define. O racional de cada um está no ADR correspondente — aqui ficam só os valores, para consulta
rápida enquanto o schema não existe.

| Decisão                                              | ADR                                                                  |
| ---------------------------------------------------- | -------------------------------------------------------------------- |
| Sobreposição de segmentos no score                   | [0026](./adr/0026-sobreposicao-de-segmentos-no-score.md)             |
| Valor monetário em centavos, exibido como faixa      | [0027](./adr/0027-valor-monetario-em-centavos-exibido-como-faixa.md) |
| Nota do mentor pública, credibilidade em duas etapas | [0024](./adr/0024-nota-do-mentor-e-publica.md)                       |
| Critérios de moderação por tipo de conta             | [0025](./adr/0025-criterios-de-moderacao-por-tipo-de-conta.md)       |

---

## 1. `Segmento` — 12 valores

```
FINTECH           HRTECH            GOVTECH
HEALTHTECH        LEGALTECH         CONSTRUTECH
EDTECH            MARTECH           ECONOMIA_CRIATIVA
AGROTECH          LOGTECH           RETAILTECH
```

- Não existe `OUTRO`. O motor não consegue cruzar `OUTRO` com `OUTRO`.
- A startup marca **no máximo 2**. O limite impede marcar tudo para aparecer em toda busca.
- O investidor marca **quantos quiser** — tese ampla é legítima.
- No score, **um segmento em comum já vale a pontuação cheia** ([ADR 0026](./adr/0026-sobreposicao-de-segmentos-no-score.md)).

**Não decidido, e deliberadamente adiado:** se falta algum setor forte do Porto Digital na lista.
Acrescentar valor depois é migration, e o grupo preferiu não travar por isso.

## 2. Faixa de capital buscado e de ticket

Par de números (`minimo`, `maximo`), guardado em **centavos como inteiro**.

- **Teto obrigatório** — ninguém deixa em branco.
- **Mínimo aceito: R$ 1.000.**
- Há compatibilidade quando os intervalos **se sobrepõem em qualquer ponto**.
- O cartão indica se o ticket está **acima ou abaixo**, visível aos dois lados.
- O front exibe agrupado: `R$ 100 mil – R$ 500 mil`. A API devolve o inteiro, nunca string
  formatada.

Detalhes em [ADR 0027](./adr/0027-valor-monetario-em-centavos-exibido-como-faixa.md).

## 3. Áreas de expertise do mentor — 9 valores

```
PRODUTO                  MARKETING                  PESSOAS_E_CULTURA
TECNOLOGIA               FINANCAS                   JURIDICO_E_SOCIETARIO
DESIGN_E_UX              VENDAS_E_GO_TO_MARKET      CAPTACAO_E_INVESTIMENTO
```

- Múltipla escolha, e cada área carrega **anos de experiência** — não um rótulo como "avançado".
  Ano é conferível contra o LinkedIn; rótulo é opinião.
- `OPERACOES` foi cortado da proposta original por ser vago o bastante para virar caixa-de-tudo.
- `CAPTACAO_E_INVESTIMENTO` é área de mentoria, não o mesmo que ter o papel `INVESTIDOR`: ensinar a
  captar não é aportar.

**Credibilidade em duas etapas**, porque anos de experiência é autodeclaração:

1. **Até a terceira avaliação** — vale o declarado, conferido pela moderação contra o LinkedIn
   ([ADR 0025](./adr/0025-criterios-de-moderacao-por-tipo-de-conta.md)).
2. **A partir da terceira** — a nota das startups substitui a autoclassificação
   ([ADR 0024](./adr/0024-nota-do-mentor-e-publica.md)).

No cartão aparece **um** dos dois; no perfil expandido, os dois.

**Consequência de modelagem:** área com anos deixa de ser lista simples e vira tabela própria — uma
linha por área do mentor.

---

## Acréscimo ao documento: o perfil do investidor é público

O RF04 define o perfil público apenas da startup. Decisão tomada: o perfil do investidor — tese,
segmentos e estágios de interesse, faixa de ticket e modelo preferido — também é visível às
startups. Sem isso a descoberta funcionaria em um sentido só e o RF15 não teria o que buscar.

A **nota** do investidor continua restrita ao administrador
([ADR 0012](./adr/0012-visibilidade-assimetrica-do-feedback.md)).

## O que continua em aberto

Estes não bloqueiam a migration — permitem escrever o schema, mas não implementar a regra:

| O que falta                                                        | Requisito |
| ------------------------------------------------------------------ | --------- |
| Pesos do score e valor do limiar, incluindo quanto vale o segmento | RF03      |
| Cotas por plano e preços                                           | RF17      |
| Prazo da janela de tolerância por inadimplência                    | RF17      |
| Se o cancelamento é permitido durante inadimplência                | RF17      |
| Escala e critérios da nota do feedback                             | RF10      |
