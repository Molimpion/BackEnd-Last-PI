# Registros de decisão arquitetural (ADR)

Uma decisão por arquivo, numerada por ordem de escrita — não por importância.

Cada ADR responde três coisas: o contexto que forçou a decisão, o que foi decidido, e **o que foi
recusado com a razão**. A terceira é a que importa: sem ela, o arquivo não explica por que o sistema
não foi construído da forma óbvia.

## Produto

| #                                                                | Decisão                                                                     | Status                               |
| ---------------------------------------------------------------- | --------------------------------------------------------------------------- | ------------------------------------ |
| [0009](./0009-plataforma-de-conexao-nao-de-intermediacao.md)     | Plataforma de conexão, não de intermediação de investimento                 | Aceito                               |
| [0010](./0010-tipo-de-conta-e-papeis-acumulaveis.md)             | Tipo de conta exclusivo com papéis acumuláveis                              | Aceito                               |
| [0003](./0003-score-deterministico.md)                           | Score de afinidade determinístico                                           | Aceito                               |
| [0004](./0004-cota-com-devolucao.md)                             | Cota de solicitações com devolução                                          | Aceito                               |
| [0012](./0012-visibilidade-assimetrica-do-feedback.md)           | Visibilidade assimétrica do feedback                                        | Aceito — parte substituída pelo 0024 |
| [0024](./0024-nota-do-mentor-e-publica.md)                       | A nota do mentor é pública; a do investidor não                             | Aceito                               |
| [0013](./0013-reativacao-sem-nova-cobranca.md)                   | Reativação dentro do período vigente, sem cobrança                          | Aceito                               |
| [0026](./0026-sobreposicao-de-segmentos-no-score.md)             | Sobreposição de segmentos no score é tudo ou nada                           | Aceito                               |
| [0027](./0027-valor-monetario-em-centavos-exibido-como-faixa.md) | Valor monetário em centavos, exibido como faixa                             | Aceito                               |
| [0028](./0028-plano-por-publico-em-tres-niveis.md)               | Plano por público, em três níveis                                           | Aceito                               |
| [0029](./0029-destaque-pago-do-mentor-na-busca.md)               | Destaque pago do mentor na busca manual                                     | Aceito                               |
| [0030](./0030-solicitacao-a-investidor-e-mentor.md)              | Solicitação a investidor e mentor, com cota mensal e sem duplicata pendente | Aceito                               |
| [0031](./0031-mentor-pode-pedir-acesso-ao-perfil-completo.md)    | Mentor também pode pedir acesso ao perfil completo                          | Aceito                               |
| [0032](./0032-estados-da-reuniao-e-contraproposta.md)            | Estados da reunião e contraproposta como histórico                          | Aceito                               |
| [0033](./0033-escala-e-criterios-do-feedback.md)                 | Escala e critérios do feedback                                              | Aceito                               |
| [0034](./0034-notificacoes-de-seguranca.md)                      | Notificações de segurança entram na lista de tipos                          | Aceito                               |

## Segurança, privacidade e governança

| #                                                          | Decisão                                                 | Status                           |
| ---------------------------------------------------------- | ------------------------------------------------------- | -------------------------------- |
| [0001](./0001-gestao-de-segredos.md)                       | Gestão de segredos                                      | **Proposto** — pendente do grupo |
| [0002](./0002-sessao-opaca-em-redis.md)                    | Sessão opaca em Redis em vez de JWT                     | Aceito                           |
| [0011](./0011-rate-limit-de-login-por-ip.md)               | Rate limit de login por IP, não por e-mail              | Aceito                           |
| [0005](./0005-exclusao-por-anonimizacao.md)                | Exclusão de conta por anonimização                      | Aceito                           |
| [0017](./0017-repositorios-publicos.md)                    | Repositórios públicos para habilitar proteção de branch | Aceito                           |
| [0022](./0022-disponibilidade-como-meta-declarada.md)      | Disponibilidade como meta declarada, não medida         | Aceito                           |
| [0025](./0025-criterios-de-moderacao-por-tipo-de-conta.md) | Critérios de moderação por tipo de conta                | Aceito                           |

## Arquitetura e implementação

| #                                                        | Decisão                                                  | Status |
| -------------------------------------------------------- | -------------------------------------------------------- | ------ |
| [0007](./0007-express-em-vez-de-nest.md)                 | Express em vez de Nest.js ou Fastify                     | Aceito |
| [0014](./0014-organizacao-por-feature.md)                | Código organizado por feature, não por categoria técnica | Aceito |
| [0008](./0008-use-cases-restritos-a-dominios-pesados.md) | Casos de uso restritos aos domínios pesados              | Aceito |
| [0006](./0006-outbox-no-pagamento.md)                    | Padrão outbox no fluxo de pagamento                      | Aceito |
| [0015](./0015-cookie-entre-dominios-distintos.md)        | Cookie entre domínios distintos em vez de proxy          | Aceito |
| [0016](./0016-front-consome-o-back-diretamente.md)       | Front-end consome o back-end diretamente                 | Aceito |
| [0020](./0020-sentry-em-vez-de-prometheus-e-grafana.md)  | Sentry como observabilidade, sem Prometheus e Grafana    | Aceito |

## Processo e qualidade

| #                                                                     | Decisão                                                              | Status |
| --------------------------------------------------------------------- | -------------------------------------------------------------------- | ------ |
| [0018](./0018-portao-de-qualidade-catraca-e-falha-fechada.md)         | Portão de qualidade: catraca, cobertura sobre o diff e falha fechada | Aceito |
| [0021](./0021-teste-de-integracao-obrigatorio-nos-fluxos-criticos.md) | Teste de integração obrigatório e cobertura por branch               | Aceito |
| [0019](./0019-um-unico-postgres-e-redis-no-compose.md)                | Um único PostgreSQL e Redis, no Compose do back-end                  | Aceito |
| [0023](./0023-overrides-para-dependencias-transitivas.md)             | `overrides` para corrigir dependências transitivas vulneráveis       | Aceito |

## Como escrever um novo

Copie a estrutura de qualquer um dos existentes: `Status`, `Data`, `Requisito`, e as seções
`Contexto`, `Decisão`, `Alternativas recusadas`, `Consequências`.

Status possíveis: **Proposto** (decisão ainda em aberto), **Aceito**, **Recusado**, **Substituído
por ADR NNNN**.

ADR aceito não se edita para mudar de ideia — escreve-se um novo que o substitui, e o antigo passa a
`Substituído`. O histórico da decisão é parte do valor do registro.

## O que deliberadamente não virou ADR

**Declarações de escopo.** Login social, integração com Google Calendar e crowdfunding próprio estão
fora de escopo, e isso já está no `Projeto_Matchmaking.md`. Registrar "não vamos fazer X" como ADR
infla a pasta sem explicar nenhuma escolha entre alternativas.

**Decisões de outro repositório.** Next.js em vez de SPA com Vite, e `fetch` nativo em vez de Axios
(seção 6.2), pertencem ao `FrontEnd-Last-PI`. FastAPI em vez de Django (seção 6.5) pertence ao
`IA-Last-PI` — e não deve ser escrito lá antes de a pendência 1 da seção 11 ser resolvida: o
documento admite que, se nenhuma função para a IA se justificar, o repositório é descartado.

**Mitigações operacionais.** Aquecer o Render antes de uma apresentação (seção 8.2) é procedimento,
não decisão arquitetural. Está registrado como consequência no
[ADR 0022](./0022-disponibilidade-como-meta-declarada.md).
