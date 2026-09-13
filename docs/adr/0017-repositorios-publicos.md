# ADR 0017 — Repositórios públicos para habilitar proteção de branch

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 9.6, RNF06, RNF02

## Contexto

O RNF06 exige revisão obrigatória antes de qualquer merge, e o portão de qualidade só vira barreira
efetiva quando configurado como _required status check_ na proteção de branch — executar e falhar
não impede merge por si só.

No plano gratuito do GitHub, **proteção de branch e rulesets não estão disponíveis para
repositórios privados**. Ou seja: repositório privado e gratuito significa nenhuma barreira técnica,
apenas acordo verbal entre os integrantes.

## Decisão

Os três repositórios são **públicos**.

Isso habilita, sem custo, a proteção de `main`, `release` e `dev`: _required status checks_,
_require branches to be up to date_, _require pull request reviews_ e restrição de quem pode dar
push.

A contrapartida é a disciplina de gestão de segredos já prevista no RNF02 e detalhada no
[ADR 0001](./0001-gestao-de-segredos.md).

## Alternativas recusadas

**Repositório privado no plano gratuito.** Recusado porque deixa o projeto sem nenhuma barreira: o
portão de qualidade roda, fica vermelho, e qualquer pessoa clica em merge mesmo assim. O trabalho de
construir o portão seria desperdiçado.

**Plano pago do GitHub.** Resolveria o problema mantendo o código fechado. Recusado por custo, sem
benefício correspondente — o projeto é acadêmico e não tem nada a proteger comercialmente.

**Confiar em acordo entre os integrantes, sem proteção.** Recusado pelo mesmo motivo que a
implementação de referência do portão falhava (seção 9.5): mecanismo que depende de alguém lembrar
não é mecanismo. Em grupo com prazo, a exceção vira regra na semana da entrega.

## Consequências

- **Nenhum segredo pode chegar ao repositório, em nenhuma circunstância.** Commit com credencial num
  repositório público é vazamento imediato e público, não um erro corrigível com um `revert` — a
  chave precisa ser rotacionada.
- Segredo de repositório **não é exposto a PR vindo de fork**. Se algum dia um step de CI depender de
  segredo real, PR de fork vai falhar. Hoje isso não é problema porque a pipeline não usa nenhum.
- O código compõe o portfólio dos integrantes, o que é benefício colateral real.
- A varredura de segredos do RNF02 e o `enableSecurityCheck` do repomix deixam de ser zelo e passam a
  ser necessidade.
- Qualquer pessoa pode abrir issue ou PR. A restrição efetiva é sobre quem pode **concluir o merge**,
  não sobre quem pode propor.
