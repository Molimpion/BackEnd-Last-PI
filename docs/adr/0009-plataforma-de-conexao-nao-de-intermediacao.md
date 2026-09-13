# ADR 0009 — Plataforma de conexão, não de intermediação de investimento

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 1.1

## Contexto

O desafio do projeto é conectar startups nascentes do Porto Digital a mentores e investidores anjo.
A leitura mais ambiciosa desse enunciado levaria a um produto que acompanha o aporte até o fim:
processar o investimento, custodiar valores, formalizar participação societária.

Duas forças empurram contra essa leitura:

- **Regulação.** Facilitar oferta de participação societária aproxima o produto do escopo de
  regulação da CVM — oferta pública e crowdfunding de investimento. Entrar nesse terreno significa
  obrigações de registro e conformidade que um projeto acadêmico de um semestre não tem como
  atender.
- **Escopo.** Custódia de valores e formalização societária são, cada uma, um produto inteiro.
  Somadas aos dezessete requisitos funcionais já previstos, inviabilizam a entrega no prazo.

## Decisão

A plataforma é **um ambiente de conexão e relacionamento**. O sistema não processa aporte, não
custodia valores e não formaliza participação societária.

A negociação e o fechamento do _deal_ acontecem fora da plataforma. O sistema registra a conexão, a
interação e o feedback. **A jornada termina na reunião realizada e no feedback pós-interação.**

## Alternativas recusadas

**Intermediar o investimento de ponta a ponta.** Recusado pelos dois motivos acima somados. Não é
uma decisão sobre ambição técnica: é sobre entrar ou não num terreno regulado sem estrutura para
operar nele.

**Registrar o valor e os termos do aporte, sem processá-lo.** Uma posição intermediária — a
plataforma não move dinheiro, mas guarda os termos do acordo. Recusado porque não resolve o problema
regulatório de forma clara e cria expectativa de que a plataforma tem papel na negociação. O limite
precisa ser óbvio para quem usa, não uma sutileza jurídica.

## Consequências

- **Não existe entidade de aporte, de valor investido ou de participação societária no modelo de
  dados.** Isso é limite de escopo, não funcionalidade faltando.
- O funil de métricas (RF09) termina em "reuniões realizadas", nunca em "investimentos fechados". A
  plataforma não tem como saber se o negócio aconteceu.
- O único fluxo financeiro do sistema é a **assinatura do próprio produto** (RF17), que é receita da
  plataforma, não capital da startup. São coisas distintas e não devem se confundir no código nem na
  interface.
- O sucesso do produto não é medido por capital captado — é medido por conexões qualificadas.
- Se alguém propuser registrar aporte no futuro, este ADR precisa ser substituído, não ignorado.
