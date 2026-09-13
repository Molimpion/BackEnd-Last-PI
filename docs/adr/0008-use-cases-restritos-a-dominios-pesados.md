# ADR 0008 — Casos de uso restritos aos domínios com regra pesada

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RNF07, RNF09

## Contexto

São cerca de doze domínios, e eles não têm o mesmo peso. Listar reuniões de um usuário é ler e
devolver. Enviar uma solicitação debita cota, verifica limiar de afinidade, valida pauta, cria a
solicitação, agenda a expiração e notifica o investidor.

Aplicar a mesma cerimônia aos dois extremos tem custo nos dois sentidos: camada de caso de uso em
cima de um `findMany` é burocracia pura; service único para uma operação de seis passos vira função
de trezentas linhas que ninguém testa.

Sem critério escrito, isso vira discussão a cada pull request — e em trabalho de grupo, discussão
recorrente sobre forma consome o tempo que deveria ir para conteúdo.

## Decisão

Regra de corte explícita:

> **É use case** se a operação tem mais de um passo, toca mais de uma tabela ou tem decisão
> condicional relevante.
> **É service** se a operação é ler e devolver.

**Domínios com use case:** autenticação e sessão, matchmaking, solicitações com cota, assinatura,
moderação, autorização de acesso a dados protegidos.

**Domínios com service simples:** cadastros, Canvas, perfis, reuniões, auditoria, notificações.

Nos domínios com use case, o controller chama o caso de uso **diretamente** — não existe service
intermediário.

## Alternativas recusadas

**Use case em todos os domínios.** É o que a leitura ortodoxa de arquitetura limpa pediria. Recusado
porque produz uma classe por operação trivial, cada uma com um método que repassa a chamada ao
repositório. O custo é real e o benefício é teórico num projeto deste tamanho.

**Service em todos os domínios.** Recusado porque concentra a regra pesada em métodos longos, com
muitas responsabilidades, difíceis de testar isoladamente — justamente nos cinco fluxos onde o RNF07
exige teste de integração e cobertura por branch.

**Controller → service → use case, empilhando os dois.** Recusado: empilhar dois padrões para a mesma
responsabilidade cria uma camada de repasse que não decide nada e que todo mundo precisa atravessar
para entender o fluxo.

## Consequências

- **Os domínios com use case coincidem com os cinco fluxos críticos do RNF07.** Não é coincidência: é
  onde a regra de negócio efetivamente vive, e portanto onde o teste de integração é obrigatório.
- A escolha entre os dois padrões deixa de ser preferência pessoal e vira critério verificável em
  revisão de PR.
- Um domínio pode migrar de service para use case quando a regra crescer. A migração é esperada, não
  é falha de planejamento.
- No repositório, nos domínios de cadastro e consulta, service chamando Prisma diretamente é
  aceitável — ser dogmático ali custa cerimônia sem retorno.
