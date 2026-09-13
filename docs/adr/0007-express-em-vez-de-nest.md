# ADR 0007 — Express em vez de Nest.js ou Fastify

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RNF09

## Contexto

O backend é uma API REST com cerca de doze domínios, três processos em runtime e prazo de um
semestre. O grupo já usou Express nos dois períodos anteriores e tem padrão consolidado com ele.

Em projeto integrador, **cronograma é o principal fator de risco** — mais que desempenho, mais que
elegância arquitetural.

## Decisão

Node.js com TypeScript e **Express**.

A estrutura que o framework não impõe é suprida pela organização interna documentada na seção 6.4:
código por feature, camadas com fronteira explícita, dependência apontando para dentro.

## Alternativas recusadas

**Nest.js.** É a escolha que resolveria o ponto fraco do Express — ele impõe módulos, injeção de
dependência e estrutura de camadas por construção, que é exatamente o que este projeto precisa. Foi
recusado pela curva de aprendizado: decorators, providers, módulos e o contêiner de DI são conceitos
novos para o grupo, e o tempo gasto aprendendo sai do tempo de implementar os dezessete requisitos
funcionais. O ganho de estrutura não compensa diante do escopo do semestre.

**Fastify.** Recusado porque o ganho é principalmente de desempenho, e desempenho não é o gargalo
deste produto — o RNF01 pede 2s no percentil 95 para leitura, que o Express entrega folgado. Trocar
de framework por um benefício que o requisito não cobra é risco sem contrapartida.

## Consequências

**Contrapartida assumida: Express não impõe estrutura.** Nada no framework impede um service de
importar `express` ou um controller de chamar Prisma direto. Três mecanismos compensam isso:

1. A organização por feature e as regras de camada da seção 6.4, documentadas no `CLAUDE.md`.
2. Regras de `no-restricted-imports` no ESLint recusando os imports que violam a fronteira — a
   verificação é automática, não depende de alguém lembrar.
3. Revisão obrigatória de pull request (RNF06).

Sem esses três, a decisão vira dívida. É por isso que a fronteira foi configurada no lint já na
primeira semana, antes de existir qualquer feature.

Outras consequências:

- A especificação OpenAPI é escrita à mão (`swagger-jsdoc`), e por isso pode divergir do código — daí
  a regra de endpoint, DTO e spec no mesmo PR (seção 8.6).
- Validação de entrada fica por conta do Zod nos DTOs, na borda.
