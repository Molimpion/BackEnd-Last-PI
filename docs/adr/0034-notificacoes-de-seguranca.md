# ADR 0034 — Notificações de segurança entram na lista de tipos

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF12, RF07

## Contexto

O RF12 lista os eventos notificáveis: solicitação, mensagem, reunião, moderação e cobrança. Também
diz que notificações de eventos críticos de conta — **moderação, segurança e assinatura** — não podem
ser desativadas.

Nenhum evento da lista é de segurança. A regra fala de uma categoria que não existe.

## Decisão

**Três tipos de segurança entram agora na lista**, sem possibilidade de desativação:

- `LOGIN_NOVO`
- `SENHA_ALTERADA`
- `MFA_ALTERADO`

## Alternativas recusadas

**Só a lista do RF12, com tipos de segurança entrando junto do fluxo que os dispara.** Era a
recomendação técnica: não criar tipo antes de existir quem o emita. Recusado pelo grupo para que a
regra do RF12 tenha objeto desde a primeira migration.

## Consequências

- Os três tipos existem no banco antes de o fluxo de autenticação emiti-los. Até lá, são valores sem
  uso.
- O que dispara cada tipo não está definido. `LOGIN_NOVO` depende de decidir o que é um login "novo"
  (dispositivo, IP, local), e `MFA_ALTERADO` de decidir se regerar códigos de recuperação conta.
- A preferência de e-mail por tipo não se aplica a estes três nem aos de moderação e assinatura.
