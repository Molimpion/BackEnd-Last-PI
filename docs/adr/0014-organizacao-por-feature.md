# ADR 0014 — Código organizado por feature, não por categoria técnica

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RNF09, RNF06

## Contexto

São cerca de doze domínios: auth, startups, canvas, perfis, match, solicitações, reuniões, chat,
assinaturas, moderação, auditoria e notificações.

A organização mais comum em projetos Express — `controllers/`, `services/`, `repositories/` — agrupa
arquivos pelo que eles **são**, não pelo que eles **fazem**. Com doze domínios, cada uma dessas
pastas passa de dez arquivos e nada relacionado fica junto.

Há também um fator de trabalho em grupo: várias pessoas mexendo no mesmo repositório ao mesmo tempo.

## Decisão

Organização **por feature**. Cada domínio é um diretório autocontido em `src/features/`, com suas
próprias rotas, controller, casos de uso ou service, repositório e DTOs.

O transversal mora em `src/infra/`, com nome que diz o que é: `db.ts`, `redis.ts`, `queue.ts`,
`session.ts`, `errors.ts`, `logger.ts`, `mailer.ts`, `storage.ts`, `payments.ts`, `ai-client.ts`.

**Não existe `utils/` nem `types.ts` global.**

## Alternativas recusadas

**Organização por categoria técnica** (`controllers/`, `services/`, `repositories/`). Recusado por
dois efeitos concretos. Alterar o domínio de assinatura exigiria abrir quatro pastas distintas para
acompanhar um fluxo — o código relacionado fica espalhado justamente onde a regra é mais densa. E em
trabalho de grupo, duas pessoas em domínios diferentes editam as mesmas pastas, o que multiplica
conflito de merge sem nenhum motivo de fundo.

**`utils/` para o que é transversal.** Recusado porque `utils/` não é um nome, é a ausência de um.
Ele atrai tudo que ninguém soube onde colocar e vira o arquivo que todo mundo importa e ninguém
entende. Módulo transversal com nome do que faz força a pergunta "isso é infraestrutura de quê?" — e
se não houver resposta, provavelmente o código pertence a um domínio.

**Um `types.ts` global.** Recusado pelo mesmo motivo, com um agravante: tipo compartilhado entre
domínios que não deveriam se conhecer é acoplamento disfarçado de conveniência.

## Consequências

- Duas pessoas trabalhando em domínios diferentes praticamente não colidem no controle de versão —
  o que importa diretamente para o RNF06.
- O limite do domínio fica visível: se um arquivo de `solicitacoes/` precisa importar de
  `assinaturas/`, isso aparece no import e vira conversa de revisão.
- As regras de fronteira do ESLint (`no-restricted-imports`) dependem desse layout — os padrões de
  arquivo são `src/features/*/service.ts`, `src/features/*/repository.ts` e afins.
- Contrapartida aceita: um pouco de repetição entre domínios. Extrair cedo demais para um módulo
  comum é o caminho de volta para o `utils/`.
- Ver também o [ADR 0008](./0008-use-cases-restritos-a-dominios-pesados.md), que define quais
  domínios têm caso de uso e quais têm service simples.
