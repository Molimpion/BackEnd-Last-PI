# Proposta — as três listas fechadas que bloqueiam a primeira migration

**Status:** proposta, aguardando decisão do grupo.

Os três pontos abaixo são exigidos pelo `Projeto_Matchmaking.md` mas não definidos por ele. Nenhum é
escolha de quem implementa: eles determinam o que o usuário **pode** dizer sobre si e o que o motor
de afinidade consegue cruzar. Uma vez na migration, mudar exige outra migration — e migração de dado,
se já houver cadastro.

Este documento traz valores concretos para acelerar a discussão. Leve ao grupo como
"concordo / troco isso / falta aquilo". Depois de decidido, cada item vira ADR e este arquivo é
apagado.

---

## 1. Valores do enum `Segmento`

**Exigido por:** RF01 (obrigatório, lista fechada), RF02 (segmentos de interesse do investidor),
RF03 (entra no cálculo do score).

**O que o documento diz:** cita Fintech, Healthtech, Agrotech, Edtech, Retailtech "e demais". "E
demais" não é um enum.

### Proposta — 12 valores

```
FINTECH           HRTECH            GOVTECH
HEALTHTECH        LEGALTECH         CONSTRUTECH
EDTECH            MARTECH           ECONOMIA_CRIATIVA
AGROTECH          LOGTECH           RETAILTECH
```

**Por que 12 e não os 5 do documento.** Os cinco citados cobrem o óbvio e deixam de fora setores com
presença real no ecossistema. Lista curta demais empurra a startup para o valor mais próximo, e o
score passa a cruzar segmentos que não se parecem.

**Por que `ECONOMIA_CRIATIVA` entra.** É o tema do projeto integrador e o Porto Digital tem polo
dedicado. Deixar de fora seria contraditório com o contexto declarado na seção 1.

**Por que não existe `OUTRO`.** O motor de afinidade não consegue cruzar `OUTRO` com `OUTRO`: duas
startups sem nada em comum teriam compatibilidade máxima de segmento. Se a lista precisar crescer,
cresce por migration — que é rastreável e revisável, ao contrário de um campo-lixo.

### Em aberto para o grupo

- `LOGTECH` e `CONSTRUTECH` têm presença suficiente no Recife para justificar? Vocês conhecem o
  ecossistema melhor que eu.
- Uma startup pode ter **mais de um** segmento? A modelagem atual assume um só. Permitir vários
  muda o cálculo do score de igualdade para interseção.
- Falta algum setor forte do Porto Digital nesta lista?

---

## 2. Formato das faixas de capital buscado e de ticket

**Exigido por:** RF01 (faixa de capital buscado da startup), RF02 (faixa de ticket do investidor),
RF03 (o score cruza as duas e precisa justificar em linguagem natural).

**O que o documento diz:** "faixa", sem definir o formato.

### As duas modelagens possíveis

|                        | Enum de intervalos nomeados     | Par de números (`minimo`, `maximo`) |
| ---------------------- | ------------------------------- | ----------------------------------- |
| Como fica              | `ATE_50K`, `DE_50K_A_200K`, …   | `minimo: 50000, maximo: 200000`     |
| Preencher              | Escolhe numa lista, rápido      | Digita dois valores                 |
| Comparar               | Igualdade ou vizinhança de enum | Interseção real de intervalos       |
| Justificativa do RF03  | "faixa adjacente à sua"         | "ticket 20% acima da sua faixa"     |
| Dado inconsistente     | Impossível                      | Possível (`minimo > maximo`)        |
| Mudar as faixas depois | Migration + migração de dado    | Não precisa                         |

### Proposta — par de números

`minimo` e `maximo` em **centavos de real**, como inteiro.

**Por que par de números.** O RF03 exige justificativa em linguagem natural e dá como exemplo
literal "ticket 20% acima da sua faixa". Esse "20%" **não é calculável a partir de enum** — com
intervalos nomeados, o máximo que se consegue dizer é "faixa adjacente". A decisão de formato é, na
prática, a decisão de quão específica a justificativa pode ser.

**Por que centavos e não reais com decimal.** Ponto flutuante em dinheiro acumula erro. Inteiro em
centavos é a prática padrão e evita a discussão.

**Por que inteiro e não `Decimal` do Prisma.** `Decimal` seria mais correto para valores monetários
arbitrários, mas traz um tipo que atravessa serialização com atrito. Para faixa de investimento,
centavos em inteiro basta — o maior valor plausível cabe com folga.

**Regra de compatibilidade proposta:** há compatibilidade quando os intervalos se sobrepõem em
qualquer ponto. O score cresce conforme a sobreposição é maior.

### Em aberto para o grupo

- **`maximo` pode ser nulo?** Investidor sem teto declarado é caso real. Nulo significa "sem limite"
  — e isso precisa estar na regra do score, não implícito.
- **Existe faixa mínima de entrada?** Uma startup pedindo R$ 500 provavelmente é cadastro de teste.
- **A interface mostra os números ou faixas?** Dá para guardar número e **exibir** como faixa, tendo
  o melhor dos dois. Mas isso é decisão de front, e precisa ser combinada.

---

## 3. Áreas de expertise do mentor

**Exigido por:** RF02 (bloco do papel `MENTOR`).

**O que o documento diz:** "áreas de expertise", sem definir se é lista ou texto.

**Por que isso não pode ser texto livre.** Três pessoas escrevem "produto", "product management" e
"PM" para a mesma coisa, e o matchmaking não cruza nenhuma delas. É o mesmo motivo pelo qual o RF01
exige lista fechada para segmento.

### Proposta — 10 valores, múltipla escolha

```
PRODUTO              VENDAS_E_GO_TO_MARKET     JURIDICO_E_SOCIETARIO
TECNOLOGIA           MARKETING                 CAPTACAO_E_INVESTIMENTO
DESIGN_E_UX          FINANCAS                  PESSOAS_E_CULTURA
                     OPERACOES
```

**Por que múltipla escolha, diferente de segmento.** Startup é de um setor; mentor acumula
experiências. Restringir a uma área só empobreceria o perfil de quem tem mais a oferecer.

**Por que estas dez.** Cobrem as dores declaradas nas personas — Mariana tem dificuldade de traduzir
métricas técnicas para o mercado (`VENDAS_E_GO_TO_MARKET`, `MARKETING`), teme expor números
(`JURIDICO_E_SOCIETARIO`), e precisa de validação de mercado (`PRODUTO`). Carlos cita receio quanto
à governança jurídica dos fundadores, que é a mesma área.

**Por que `CAPTACAO_E_INVESTIMENTO` é área de mentoria, e não o mesmo que ser investidor.** São
papéis distintos (seção 3.1): ensinar a captar não é aportar. Uma pessoa pode ter só o papel
`MENTOR` e ainda assim ser quem melhor orienta sobre rodadas.

### Em aberto para o grupo

- Dez é demais para um formulário de cadastro? A dúvida 2 da matriz CSD é exatamente sobre quantas
  etapas Mariana aguenta antes de abandonar.
- O mentor declara **nível** de experiência por área, ou só marca a área?
- `OPERACOES` é vago o suficiente para virar caixa-de-tudo?

---

## O que acontece depois da decisão

1. Cada um dos três vira ADR, com o que foi recusado e por quê.
2. Os enums entram em `prisma/schema.prisma` e a `docs/modelagem.md` deixa de estar bloqueada.
3. Este arquivo é apagado — proposta decidida não fica no repositório concorrendo com o ADR.

Os outros cinco pontos em aberto da `docs/modelagem.md` (pesos do score, cotas, preços, janela de
tolerância, critérios do feedback) **não bloqueiam a migration** — eles permitem escrever o schema,
mas não implementar a regra correspondente.
