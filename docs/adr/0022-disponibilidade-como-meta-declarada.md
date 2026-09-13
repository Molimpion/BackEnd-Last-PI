# ADR 0022 — Disponibilidade como meta declarada, não como número medido

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RNF01, Seção 8.2

## Contexto

O RNF01 estabelece meta de **99% de disponibilidade mensal** em homologação. O problema é que
disponibilidade só é comprovável com monitoramento contínuo por um período relevante — e o projeto
não tem monitoramento contínuo, por decisão registrada no
[ADR 0020](./0020-sentry-em-vez-de-prometheus-e-grafana.md).

Há um agravante: o plano gratuito do Render **suspende o serviço após período sem tráfego**, e a
primeira requisição seguinte pode levar dezenas de segundos. Qualquer medição sem aquecimento prévio
mediria a hibernação, não a aplicação.

## Decisão

Separar o que é comprovado do que é declarado:

- **Comprovado empiricamente:** os limites de desempenho — 2s no percentil 95 para leitura, 5s para
  o cálculo de matchmaking. Medidos com k6, contra ambiente de homologação **previamente aquecido**,
  com 100 usuários simultâneos. O relatório é anexado à documentação de V&V.
- **Declarado como meta de operação**, na documentação de governança: os 99% de disponibilidade.

**Não se declara número de uptime que não tenha sido medido.**

Para hibernação, a mitigação adotada é aquecer o serviço alguns minutos antes de qualquer
apresentação ou demonstração. Plano pago no mês da entrega fica como alternativa disponível caso
necessário.

## Alternativas recusadas

**Declarar 99% como resultado atingido.** Recusado por ser afirmação não verificada. É o mesmo erro
que a seção 8.6 registra sobre documentação otimista, aplicado a um número que uma banca pode
questionar diretamente — e para o qual não haveria evidência.

**Montar monitoramento contínuo para medir de verdade.** Recusado pelo mesmo motivo do ADR 0020:
frente própria de infraestrutura, fora do escopo do semestre.

**Rodar o teste de carga contra `localhost`.** Recusado porque o resultado não representa a rede
real — mede a máquina de quem testou, não o serviço em homologação.

**Remover a meta de disponibilidade do documento.** Recusado porque a meta tem valor como
compromisso de operação, mesmo sem medição. O que não pode é apresentá-la como medida.

## Consequências

- O relatório de V&V traz duas categorias distintas, e a distinção precisa estar explícita nele:
  medido e declarado.
- O teste de carga exige ambiente de homologação aquecido, e o aquecimento faz parte do
  procedimento, não é passo opcional.
- Antes de apresentação ou banca, alguém precisa acessar o sistema alguns minutos antes. É passo
  operacional, e vale registrar no roteiro da apresentação.
- Se o projeto passar a ter monitoramento contínuo, este ADR pode ser substituído por um que declare
  o número como medido.
