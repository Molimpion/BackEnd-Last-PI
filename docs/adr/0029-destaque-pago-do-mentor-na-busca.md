# ADR 0029 — Destaque pago do mentor na busca manual

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF15, RF17, RF03

## Contexto

O [ADR 0028](./0028-plano-por-publico-em-tres-niveis.md) criou planos para o mentor e, com eles, a
necessidade de recursos que só o mentor usa. Um dos recursos propostos foi o destaque na busca: o
mentor pagante aparece antes dos outros quando a startup procura mentoria.

O RF15 define a ordenação da busca manual como **score de afinidade ou data de cadastro**. O
[ADR 0003](./0003-score-deterministico.md) sustenta o score em explicabilidade: a posição de um
perfil se justifica pelos atributos dele. Um critério pago na ordenação é um terceiro fator que não
aparece na justificativa.

## Decisão

**O plano do mentor pode conceder destaque na busca manual** (coluna `destaqueNaBusca`).

O destaque atua **só na busca manual do RF15**. O score do RF03, o limiar e a justificativa em
linguagem natural não mudam: dois perfis com os mesmos dados continuam produzindo o mesmo score,
pague ou não o mentor.

## Alternativas recusadas

**Sem destaque pago.** Era a recomendação técnica, recusada pelo grupo. O argumento contra: dinheiro
na ordenação enfraquece a confiança da startup de que o topo da lista é o mais compatível, e a
plataforma existe para resolver desconfiança.

**Destaque somando pontos ao score.** Recusado por quebrar o ADR 0003 diretamente: o score deixaria
de ser função dos perfis e a justificativa passaria a omitir parte do cálculo.

## Consequências

- **O resultado destacado precisa ser identificado como tal na interface.** Sem o rótulo, a startup
  lê a ordem como compatibilidade e a decisão vira engano, que é exatamente o que o RF16 combate.
- O teste de determinismo do RF03 não é afetado, porque o destaque não entra no score.
- A combinação entre destaque e ordenação por score não está decidida: se o destacado vai ao topo em
  qualquer ordenação, se aparece num bloco separado acima dos resultados, ou se há limite de
  destacados por página.
- O RF15 ganha um critério de ordenação que o documento não prevê. Precisa ser refletido no
  `Projeto_Matchmaking.md` pelo responsável técnico.
