# ADR 0021 — Teste de integração obrigatório e cobertura por branch nos fluxos críticos

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RNF07

## Contexto

Cinco fluxos concentram a regra de negócio e o risco do produto: autenticação, sessão e MFA; motor de
matchmaking; controle de cota; assinatura e webhook de pagamento; controle de acesso a dados
protegidos.

Uma exigência de cobertura genérica — "70% de cobertura" — é fácil de atender com testes unitários e
tudo mockado, e igualmente fácil de atender sem exercitar nenhum caminho de erro. O requisito ficaria
satisfeito no papel enquanto o sistema continuaria quebrando exatamente onde importa.

## Decisão

Nos cinco fluxos críticos:

- **Teste de integração é obrigatório**, contra PostgreSQL e Redis reais. Não basta teste unitário
  com dependências mockadas.
- **Cobertura medida por branch**, não apenas por statement.
- Cobertura mínima de 70%.

A pipeline sobe PostgreSQL e Redis como serviços do runner justamente para viabilizar isso.

## Alternativas recusadas

**Suíte inteiramente unitária, com dependências mockadas.** Recusado porque os cinco fluxos falham
predominantemente em **configuração**, não em lógica isolada. Redis mockado não comprova que a sessão
funciona; repositório mockado não comprova que a consulta está correta. O teste passa e a aplicação
quebra na primeira execução real — que é o pior resultado possível, porque a suíte verde dá confiança
falsa.

**Cobertura por statement.** Recusado porque os fluxos críticos deste produto são majoritariamente
caminhos de erro: webhook duplicado, cobrança falha, cota esgotada, acesso negado, sessão revogada.
Cobertura por statement aprova um `if` novo tendo exercitado apenas o ramo feliz — exatamente o ramo
que já funcionava.

**Exigir integração em todos os domínios.** Recusado por custo. Teste de integração é mais lento e
mais caro de manter; aplicá-lo a um CRUD de perfil gasta tempo de CI sem reduzir risco.

## Consequências

- O CI depende de PostgreSQL e Redis funcionando. A pipeline fica mais lenta e tem mais peças que
  podem falhar — é o preço de testar o que realmente quebra.
- Os testes precisam de isolamento entre si: banco limpo ou transação revertida por teste, senão a
  ordem de execução vira fonte de falha intermitente.
- Os cinco fluxos coincidem com os domínios que têm caso de uso
  ([ADR 0008](./0008-use-cases-restritos-a-dominios-pesados.md)). Não é coincidência: é onde a regra
  vive.
- Massa de dados gerada com `@faker-js/faker`, nunca escrita à mão.
- A exigência de branch coverage é verificada pelo portão
  ([ADR 0018](./0018-portao-de-qualidade-catraca-e-falha-fechada.md)).
