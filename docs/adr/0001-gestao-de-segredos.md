# ADR 0001 — Gestão de segredos

**Status:** Proposto — pendente de decisão do grupo
**Data:** 2026-09-13

## Contexto

Os segredos do projeto se dividem em dois tipos, e a diferença muda como são tratados:

- **Gerados por nós.** Hoje só o `SESSION_SECRET`, produzido com `openssl rand -hex 32`. Não
  precisa bater com nada externo, então pode ser diferente em cada ambiente e rotacionado à
  vontade — ao custo de invalidar as sessões vigentes (RF07 usa sessão opaca em Redis).
- **Emitidos por terceiros.** `SENDGRID_API_KEY`, as três do Cloudinary, `ABACATEPAY_API_KEY`,
  `ABACATEPAY_WEBHOOK_SECRET` e `SENTRY_DSN`. Vêm do painel do fornecedor e precisam bater
  exatamente com o que ele tem. Não há como gerar localmente.

O segredo precisa existir em três lugares distintos, com mecanismos distintos:

| Ambiente                 | Mecanismo                                                                                   |
| ------------------------ | ------------------------------------------------------------------------------------------- |
| Máquina do desenvolvedor | `.env` local, no `.gitignore`                                                               |
| CI                       | GitHub Secrets, lidos como `${{ secrets.NOME }}`                                            |
| Produção (Render)        | Environment Variables no painel, replicadas nos **três** serviços (api, worker, dispatcher) |

Dois fatos do projeto restringem as opções:

1. **Os repositórios são públicos** (seção 9.6), porque é o que habilita proteção de branch no plano
   gratuito. Segredo de repositório não é exposto a PR vindo de fork — o GitHub omite. Isso é
   proteção, não defeito, mas significa que qualquer step de CI que dependa de segredo real vai
   falhar em PR de fork.
2. **O backend roda em três processos** (seção 6.4). Segredo configurado só no serviço da API deixa
   worker e dispatcher quebrados, e a falha aparece tarde — no processamento de fila, não na subida.

O estado atual é que a pipeline de CI **não consome nenhum segredo**: PostgreSQL e Redis sobem como
serviço do runner, e o `SESSION_SECRET` é gerado efêmero a cada execução. Nenhuma decisão de gestão
foi tomada ainda porque nenhuma foi necessária.

## Decisão

Pendente. As perguntas abaixo precisam de resposta do grupo antes de a primeira integração externa
ser implementada (RF12, RF17 ou upload de arquivo, o que vier primeiro):

1. **Quem é o titular das contas de fornecedor?** Conta pessoal de um integrante cria dependência de
   uma pessoa e some quando ela sai. Conta compartilhada do grupo exige gerenciar a credencial dela
   também.
2. **Ambiente de homologação e produção usam as mesmas chaves?** Para a AbacatePay a resposta é não —
   sandbox e produção são chaves distintas (seção 8.5). Para SendGrid e Cloudinary o grupo precisa
   decidir se separa.
3. **Usar GitHub Environments em vez de segredos de repositório?** Environments permitem exigir
   aprovação manual antes de um job acessar o segredo. Custa configuração; protege contra workflow
   malicioso num repositório público.
4. **Qual a política de rotação, e o que acontece se um segredo vazar?** Sem procedimento escrito, o
   vazamento vira improviso. Mínimo: saber quem revoga, onde, e o que quebra enquanto isso.
5. **Como um integrante novo recebe os segredos?** Mandar por WhatsApp é o padrão do mundo real e é
   ruim. A alternativa exige escolher um mecanismo.

## Alternativas consideradas

- **Arquivo `.env` compartilhado no Drive ou no grupo.** Recusado: sem rastreabilidade de quem
  acessou, sem revogação individual, e o arquivo circula indefinidamente depois que a pessoa sai.
- **Segredos versionados em arquivo criptografado (SOPS, git-crypt).** Mantém segredo e código
  juntos e versionados. Recusado por enquanto: exige gerenciar a chave mestra, que é o mesmo
  problema um nível acima, com uma ferramenta a mais para o grupo aprender.
- **Gerenciador de segredos dedicado (Vault, Doppler, Infisical).** É a resposta correta em produção
  real. Recusado pelo escopo: frente própria de infraestrutura, pelo mesmo motivo que Prometheus e
  Grafana ficaram fora (seção 6.3).

## Consequências

Enquanto esta decisão estiver pendente:

- Nenhum step de CI pode depender de segredo real. Se um for necessário, este ADR precisa ser
  resolvido antes.
- Toda variável nova entra no `.env.example` com valor vazio ou claramente falso, no mesmo PR que a
  introduz (seção 7.2).
- Vale a regra do RNF02 sem exceção: credencial, chave e segredo só em variável de ambiente, nunca
  versionados.
