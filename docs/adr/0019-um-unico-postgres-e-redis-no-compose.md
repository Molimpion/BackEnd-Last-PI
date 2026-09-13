# ADR 0019 — Um único PostgreSQL e Redis, no Compose do back-end

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 7.1, RNF09

## Contexto

São três repositórios, cada um com seu `docker-compose.yml`. A escolha ingênua — cada repositório
sobe tudo de que precisa — quebra quando dois deles rodam ao mesmo tempo, que é o caso normal de
quem desenvolve uma feature de ponta a ponta.

O serviço de IA, além disso, **não tem banco próprio**: ele obtém dados pelo back-end, conforme o
contrato da seção 6.1.

## Decisão

Divisão deliberada de responsabilidade entre os três Compose:

- **`BackEnd-Last-PI`** sobe a aplicação, o **PostgreSQL** e o **Redis**.
- **`IA-Last-PI`** sobe apenas o serviço de IA, apontando para a rede do back-end.
- **`FrontEnd-Last-PI`** sobe apenas o front-end.

**Ordem de subida: o back-end primeiro.**

Neste repositório, PostgreSQL e Redis sobem por padrão; os três processos da aplicação ficam sob o
perfil `app` (`docker compose --profile app up`), já que quem desenvolve normalmente roda a aplicação
fora do container, em modo watch.

## Alternativas recusadas

**Cada repositório sobe o próprio banco.** Recusado por dois efeitos. Conflito de porta ao rodar dois
repositórios ao mesmo tempo — ambos disputam a 5432. E, pior que o conflito, o caso em que funciona:
portas diferentes produzem **bases desconectadas entre si**, e o desenvolvedor passa a depurar por
que o dado que ele criou não aparece no outro serviço.

**Um repositório separado só para a infraestrutura.** Recusado por escopo: um quarto repositório para
gerenciar dois contêineres é cerimônia, e mais um lugar para esquecer de atualizar.

**Banco compartilhado hospedado, em vez de local.** Recusado porque o desenvolvimento passaria a
depender de rede e de um recurso compartilhado que qualquer pessoa pode corromper com uma migration.

## Consequências

- Quem trabalha no front ou na IA precisa do back-end rodando. É dependência real do produto, não
  artifício do ambiente — o front consome exclusivamente o back
  ([ADR 0016](./0016-front-consome-o-back-diretamente.md)) e a IA é consumida exclusivamente por ele.
- O ambiente local reflete a produção: um banco, um Redis, vários serviços.
- O `docker-compose.yml` deste repositório é o único lugar onde a versão do PostgreSQL e do Redis é
  declarada para desenvolvimento.
- Atende diretamente ao critério do RNF09: um integrante que não escreveu o serviço consegue
  executá-lo seguindo apenas o `README.md`.
