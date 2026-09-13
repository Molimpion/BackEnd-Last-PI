# ADR 0016 — Front-end consome o back-end diretamente

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 8.3, RNF09

## Contexto

O front-end é Next.js, que oferece rotas de API próprias (_route handlers_). É comum usá-las como
intermediário entre o navegador e o back-end — o navegador chama o Next, o Next chama a API.

Esse padrão faz sentido quando não existe back-end próprio, ou quando é preciso esconder credencial
de serviço externo. Nenhum dos dois é o caso aqui: o projeto tem um back-end dedicado, e ele é quem
guarda as credenciais.

## Decisão

As rotas de API do Next.js **não são utilizadas** como intermediário. O navegador fala diretamente
com o back-end no Render.

## Alternativas recusadas

**Next.js como proxy para o back-end.** Recusado porque duplicaria o lugar onde investigar falhas:
diante de um erro, seria necessário verificar tanto o Next quanto o back-end para descobrir onde a
requisição quebrou. Numa equipe onde nem todo mundo domina os dois lados, isso dobra o custo de cada
depuração.

A decisão também reforça o RNF09, que exige front e back desacoplados, comunicando-se
exclusivamente por API REST documentada em OpenAPI. Um proxy no meio tornaria o contrato menos
observável — o que o front consome deixaria de ser o que a especificação descreve.

## Consequências

- Reforça o [ADR 0015](./0015-cookie-entre-dominios-distintos.md): sem proxy, a requisição é entre
  sites distintos, e o cookie precisa de `SameSite=None` mais `Secure`.
- O CORS do back-end é parte do caminho crítico. Origem mal configurada quebra a aplicação inteira,
  não uma tela.
- A especificação OpenAPI é o contrato de verdade, consumida pelo Kubb — não existe camada
  intermediária onde um desvio possa ser absorvido silenciosamente.
- Nenhum segredo pode ficar no front-end, porque não há servidor intermediário para guardá-lo. Tudo
  que é credencial vive no back.
