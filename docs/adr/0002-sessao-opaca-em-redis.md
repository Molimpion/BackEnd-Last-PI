# ADR 0002 — Sessão opaca em Redis em vez de JWT

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF07

## Contexto

O produto precisa invalidar acesso **imediatamente** em quatro situações que acontecem com
frequência e que são centrais ao negócio:

- A moderação reprova um cadastro que estava aprovado (RF08).
- A assinatura vence ou é rebaixada, mudando os limites funcionais do usuário (RF17).
- Uma conta é suspensa.
- Um papel é removido — a permissão é calculada a partir dos papéis **ativos no momento da
  requisição**, nunca de um valor fixo copiado na criação da sessão.

Além disso, o front-end fica na Vercel e o back-end no Render, em domínios distintos, o que já obriga
a tratar cookie entre sites (seção 8.1).

## Decisão

Sessão **opaca** armazenada em Redis, referenciada por um cookie `HttpOnly`. O cookie carrega apenas
um identificador sem significado; todo o estado da sessão vive no servidor e é lido a cada
requisição.

Cookie com `SameSite=None` e `Secure`, CORS aceitando a origem explícita do front com credenciais, e
proteção CSRF por _double-submit_ — como a credencial trafega em cookie, ela é enviada
automaticamente pelo navegador e precisa dessa defesa.

## Alternativas recusadas

**JWT puro.** Recusado porque o token é autocontido e válido até expirar. Conta suspensa continuaria
autenticada, plano rebaixado continuaria com os limites antigos, papel removido continuaria
permitindo o acesso — até o vencimento. Reduzir a expiração para minutos mitiga o problema criando
outro: refresh constante, mais complexidade e mais pontos de falha.

**JWT com lista de revogação em Redis.** É a solução usual para o problema acima, e é onde o
raciocínio se fecha: se toda requisição precisa consultar o Redis para saber se o token ainda vale,
o token deixou de ser autocontido. O resultado é uma sessão opaca com passos a mais — assinatura,
verificação criptográfica e uma segunda estrutura para manter em dia.

**Sessão em memória do processo.** Recusado pelo RNF05, que exige aplicação stateless. O backend roda
em três processos e precisa escalar horizontalmente; sessão em memória prende o usuário a uma
instância.

## Consequências

- O Redis vira dependência do caminho de autenticação. Redis fora do ar significa ninguém
  autenticado — é um ponto único de falha assumido conscientemente, e ele já é dependência
  obrigatória por causa das filas e da cota.
- Cada requisição autenticada faz uma leitura no Redis. É barata, e é o que paga a revogação
  imediata.
- Não existe tabela de sessão no PostgreSQL.
- Logout e suspensão têm efeito na requisição seguinte, sem janela de tolerância.
- **Esta decisão vale também para autenticação federada.** Login social está fora de escopo hoje
  (RF07), mas quando for implementado, o token do provedor serve para identificar o usuário e para
  de uma vez: a sessão resultante continua sendo opaca em Redis. Aceitar o token do provedor como
  credencial das requisições seguintes reintroduziria o problema que este ADR recusa — acesso válido
  até expirar, imune a suspensão, rebaixamento de plano ou perda de papel.
