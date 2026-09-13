# ADR 0020 — Sentry como observabilidade, sem Prometheus e Grafana

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 6.3, RNF01

## Contexto

Projetos anteriores do grupo usavam `prom-client` para expor métricas no formato Prometheus. Levar
isso adiante implicaria, para ser útil de verdade, subir Prometheus para coletar e Grafana para
visualizar — mais dois serviços para hospedar, configurar e manter.

O que o produto realmente precisa observar é: erro em produção, com stack trace e contexto, e uma
noção de desempenho das rotas.

## Decisão

`@sentry/node` como ferramenta de observabilidade, e log estruturado com `pino`.

`prom-client`, Prometheus e Grafana ficam **fora de escopo**, por decisão consciente.

## Alternativas recusadas

**Prometheus e Grafana.** É a resposta correta para métricas de infraestrutura em produção real, e
daria painéis mais ricos. Recusado porque exigiria uma frente própria de infraestrutura — hospedar
dois serviços a mais, configurar coleta, escrever dashboards — sem que nenhum requisito peça isso. O
RNF01 pede tempo de resposta comprovado por teste de carga, não monitoramento contínuo.

**Expor `/metrics` com `prom-client` sem coletor.** Recusado por ser meio caminho: um endpoint que
ninguém consulta é código morto com aparência de observabilidade.

**Nada além do log.** Recusado porque erro em produção sem agregação vira caça a linha em arquivo, e
ninguém encontra o que não sabe procurar.

## Consequências

- Erro em produção chega com stack trace e contexto, em painel pronto, sem infraestrutura própria.
- **Não há série temporal de métricas de infraestrutura.** Uso de CPU, memória e fila ao longo do
  tempo não são observáveis — é a contrapartida aceita.
- O RNF01 é comprovado por teste de carga pontual com k6, contra ambiente aquecido, e não por
  monitoramento contínuo. Ver [ADR 0022](./0022-disponibilidade-como-meta-declarada.md).
- O `SENTRY_DSN` é opcional no `.env.example`: a aplicação sobe sem ele em desenvolvimento.
- Se em algum momento o projeto precisar de métrica de infraestrutura, este ADR precisa ser
  substituído — não complementado com um `prom-client` solto.
