# ADR 0011 — Rate limit de login por IP, não por endereço de e-mail

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF07, RNF02

## Contexto

O login precisa de proteção contra tentativa automatizada de adivinhação de senha. A defesa usual é
limitar tentativas, e existem duas chaves óbvias para contar: o endereço IP de origem ou o endereço
de e-mail sendo tentado.

Bloquear por e-mail parece mais preciso — segue o alvo, não a origem. É justamente por isso que ele
é perigoso.

## Decisão

Rate limit de tentativas de login **por IP**, implementado com `express-rate-limit` e
`rate-limit-redis` — o contador precisa ser compartilhado, já que a aplicação é stateless e roda em
múltiplas instâncias (RNF05).

Mensagem de erro **genérica**, sem distinguir e-mail inexistente de senha incorreta.

Bloqueio por endereço de e-mail deve ser evitado. Se for adotado, com limite alto e desbloqueio por
confirmação.

## Alternativas recusadas

**Bloqueio por endereço de e-mail.** Recusado porque vira vetor de negação de serviço contra
terceiro: basta conhecer o e-mail da vítima e errar a senha repetidamente para trancar a conta dela.
O atacante não precisa de acesso a nada — só do e-mail, que é público no LinkedIn de qualquer
fundador ou investidor. A defesa contra invasão viraria ferramenta de sabotagem, num produto cujo
lado escasso são exatamente os investidores.

**Mensagem de erro específica** ("e-mail não cadastrado" / "senha incorreta"). Recusado porque
permite enumerar contas: o atacante descobre quem tem cadastro na plataforma antes de tentar
qualquer senha. Numa base de investidores identificáveis, isso é informação de valor por si só.

**Nenhum limite, confiando só na força da senha.** Recusado — é a ausência de decisão.

## Consequências

- Usuários atrás de um mesmo NAT — coworking do Porto Digital, por exemplo — compartilham o
  contador. O limite precisa ser alto o bastante para não penalizar uso legítimo em rede
  compartilhada.
- O limite por IP é contornável por quem tem vários IPs. Ele encarece o ataque, não o impede; a
  defesa de fundo continua sendo hash forte de senha e MFA.
- O contador vive no Redis, com as consequências de disponibilidade que o
  [ADR 0002](./0002-sessao-opaca-em-redis.md) já registra.
- Tentativas de login malsucedidas são registradas na auditoria (RNF10) — o que não bloqueia
  continua sendo observável.
