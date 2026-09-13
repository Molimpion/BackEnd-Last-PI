# ADR 0023 — `overrides` para corrigir dependências transitivas vulneráveis

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RNF02, Seção 9.4

## Contexto

A instalação inicial trouxe quatro advisories `high` na **árvore de produção**, todos sob o pacote
`prisma`:

- `mysql2` — downgrade de plugin de autenticação que vaza credencial em texto claro, e bomba de
  descompressão no protocolo comprimido.
- `deepmerge-ts` — exaustão de pilha ao mesclar grafos recursivos.

Eles entram em produção porque, no Prisma 7, o `@prisma/client` depende do pacote `prisma` em
runtime — não apenas como ferramenta de desenvolvimento.

Dois detalhes fecham as saídas óbvias:

1. **O Prisma fixa versão exata**, sem faixa: `"mysql2": "3.15.3"` e `"deepmerge-ts": "7.1.5"`. O npm
   não tem como resolver para a versão corrigida por conta própria.
2. **`7.10.0` é a última versão 7.x.** Não existe patch esperando para ser instalado.

## Decisão

Usar `overrides` no `package.json` forçando as versões corrigidas:

```json
"overrides": {
  "mysql2": "^3.24.4",
  "deepmerge-ts": "^8.0.2"
}
```

O baseline de vulnerabilidades aceitas em `quality-baseline.json` fica **vazio**: qualquer advisory
novo reprova o portão.

## Alternativas recusadas

**Aceitar as quatro no baseline.** Era a posição anterior, com a justificativa de que o `mysql2`
nunca é carregado — o projeto usa o adapter `pg`. Recusado depois de verificar que a correção
funciona: manter vulnerabilidade conhecida em projeto acadêmico com disciplina de Governança em TI é
difícil de defender quando existe conserto testado. Baseline é para o que não tem saída, não para o
que dá trabalho.

**`npm audit fix --force`.** Recusado: rebaixa o `prisma` para `6.19.3`, incompatível com o
`@prisma/client@7` que o projeto usa. A ferramenta "resolve" quebrando a aplicação.

**Esperar o Prisma atualizar.** Recusado como única estratégia. É o que resolve de verdade, mas não
tem prazo, e até lá a árvore de produção fica com advisory aberto.

**Remover o `mysql2` da árvore.** Não é possível: é dependência direta declarada pelo `prisma`,
mesmo em projeto que usa PostgreSQL.

## Consequências

- **`npm audit --omit=dev` retorna zero vulnerabilidades**, e o baseline vazio faz qualquer advisory
  novo reprovar o portão.
- **`deepmerge-ts` subiu de major (7 → 8) dentro do `@prisma/config`**, que é quem carrega o
  `prisma.config.ts`. Isso é o risco real desta decisão: estamos rodando o Prisma com uma versão de
  dependência que ele não declarou suportar.
- Verificado após a mudança: `prisma generate`, `prisma validate` e `prisma migrate status` — este
  último resolvendo o datasource a partir do `prisma.config.ts`, o caminho que passa pelo
  `deepmerge-ts`. Também build, lint, tipos e a suíte de testes.
- **A cada atualização do Prisma, os overrides precisam ser reconferidos.** Se uma versão nova já
  trouxer as dependências corrigidas, eles devem ser removidos em vez de mantidos por inércia —
  override esquecido é o tipo de coisa que prende uma versão antiga sem ninguém perceber.
- `override` afeta a árvore inteira, não só o ramo do Prisma. Hoje nenhum outro pacote depende
  desses dois, mas isso precisa ser considerado se mudar.
