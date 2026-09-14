# ADR 0036 — Enums do domínio como cópia verificada por teste

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** Seção 6.4, RNF07

## Contexto

A fronteira de camadas proíbe controller, service e use case de importar o cliente Prisma. Depois
da correção do lint, a regra recusa `@prisma/client`, `infra/db.js` e tudo em `generated/prisma/**`.

A regra de negócio vai precisar dos enums do schema. O caso de uso de assinatura precisa saber que
`StatusDaAssinatura` é `SEM_PLANO`, `ATIVA`, `CANCELADA_VIGENTE`, `INADIMPLENTE_EM_TOLERANCIA` ou
`ENCERRADA`. O Prisma já gera essas listas em `src/generated/prisma/enums.ts`, mas o arquivo está na
pasta que o lint recusa. O que a regra quer barrar é o acesso ao banco; o arquivo de enums não acessa
banco nenhum, e foi barrado junto.

## Decisão

**A feature declara a própria cópia do enum, e um teste confere que a cópia é igual à do schema.**

A cópia fica em `src/features/<feature>/enums.ts`, como lista em tempo de execução, de onde o tipo é
derivado:

```ts
export const statusDaAssinatura = [
  "SEM_PLANO",
  "ATIVA",
  "CANCELADA_VIGENTE",
  "INADIMPLENTE_EM_TOLERANCIA",
  "ENCERRADA",
] as const;

export type StatusDaAssinatura = (typeof statusDaAssinatura)[number];
```

O teste fica ao lado, em `src/features/<feature>/enums.test.ts`, e é o único arquivo da feature fora
do repository que importa de `generated/prisma`:

```ts
import { StatusDaAssinatura } from "../../generated/prisma/enums.js";
import { statusDaAssinatura } from "./enums.js";

it("a lista de estados da assinatura é igual à do schema", () => {
  expect([...statusDaAssinatura].sort()).toEqual(Object.values(StatusDaAssinatura).sort());
});
```

Se alguém acrescentar um valor no schema e esquecer a cópia, o teste reprova e o PR não entra.

**O `enums.ts` da feature não importa nada de `generated/prisma`.** Se importasse, a cópia deixaria de
ser cópia e a separação não existiria. O ESLint recusa esse import em `src/features/*/enums.ts`, com
a mesma regra que vale para service e use case.

Só entra em `enums.ts` o enum que a regra de negócio da feature usa. Não se copia o schema inteiro.

## Alternativas recusadas

**Liberar `generated/prisma/enums.js` no lint.** A mais simples: uma lista só, sem cópia e sem teste.
Recusada porque a regra de negócio passaria a depender de um arquivo gerado pelo Prisma, e o grupo
preferiu que ela não conheça o Prisma de forma nenhuma.

**`src/infra/enums.ts` repassando os enums do Prisma.** Recomendação técnica na discussão: uma lista
só, sem cópia, sem teste e sem mexer no lint. Recusada pelo mesmo motivo da anterior — a dependência
continua, só passa por um intermediário.

**`src/types.ts` global.** Recusado pela convenção do `CLAUDE.md`: nome genérico atrai qualquer tipo
compartilhado e vira depósito.

**Cópia sem teste.** Recusada porque a divergência entre schema e cópia seria silenciosa: o banco
aceitaria um valor que a regra de negócio não conhece.

## Consequências

- Todo valor novo em enum usado pela regra de negócio exige mexer em dois arquivos: o schema e o
  `enums.ts` da feature. Esquecer o segundo quebra o CI, não a produção.
- Mais código por feature: um `enums.ts` e um `enums.test.ts` para cada feature que use enum.
- O teste compara o conjunto de valores, não a ordem. Ordem de declaração no schema não tem
  significado para a regra de negócio.
- O tipo do domínio e o tipo gerado são a mesma união de strings, então o valor que o repository
  devolve atribui direto ao tipo do domínio, sem conversão.
- Dois `enums.ts` de features diferentes podem copiar o mesmo enum. Cada um tem o próprio teste; se
  isso se repetir muito, é sinal de que o enum pertence a uma feature e as outras deveriam importar
  dela.
- Os primeiros `enums.ts` e `enums.test.ts` nascem com a primeira feature que usar enum. Nenhum é
  criado antes.
