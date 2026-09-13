# ADR 0010 — Tipo de conta exclusivo com papéis acumuláveis

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 3.1, RF02, RF07

## Contexto

O ecossistema tem três atores: startup, pessoa que investe e/ou mentora, e administrador da
plataforma. Dois fatos observados nas personas complicam a modelagem ingênua:

- **A mesma pessoa frequentemente atua como mentor e investidor.** Obrigar dois cadastros duplica
  dados, duplica a moderação e obriga a pessoa a trocar de conta para ver o que lhe interessa.
- **O administrador cuida do sistema e não participa dele.** Ele não é investidor nem mentor na
  mesma conta, e sua conta não nasce de cadastro público.

## Decisão

Dois conceitos separados, que normalmente são confundidos:

- **Tipo de conta** — `STARTUP`, `PESSOA` ou `ADMINISTRADOR`. Exclusivo. Define a natureza do
  cadastro e o conjunto de funcionalidades.
- **Papel** — existe apenas dentro de `PESSOA`, e é **acumulável**: `INVESTIDOR`, `MENTOR`, ou
  ambos. Define quais blocos de perfil foram preenchidos e como a pessoa entra no matchmaking.

A permissão resulta da soma: o tipo define o conjunto, o papel refina dentro dele. A conta de
administrador é criada **apenas por outro administrador**, nunca por cadastro público, e tem MFA
obrigatório.

Papel incompleto não participa do matchmaking. Adicionar um papel depois é possível, mas ele só fica
ativo quando o bloco correspondente é preenchido.

## Alternativas recusadas

**Um único conceito de "tipo de usuário" com cinco valores** (startup, investidor, mentor,
investidor-mentor, admin). Recusado porque transforma combinação em enumeração: cada papel novo
multiplica os valores possíveis, e a permissão vira uma tabela de casos em vez de uma soma.

**Papéis livres, incluindo administrador acumulável.** Recusado por conflito de interesse: um
administrador que também é investidor modera perfis com os quais pode ter interesse de negócio, e a
auditoria perde sentido — não dá para distinguir a ação do moderador da ação do participante.

**Papel como campo booleano em `Pessoa`.** Recusado na modelagem porque não torna verificável o
critério "papel incompleto não participa do matchmaking". Marcar uma caixa não é preencher um
perfil. Cada papel é uma tabela própria em relação 1-para-1 opcional: o papel existe quando a linha
existe.

## Consequências

- **A permissão é calculada a partir dos papéis ativos no momento da requisição**, nunca de um valor
  copiado na criação da sessão (RF07). É parte do que sustenta o [ADR 0002](./0002-sessao-opaca-em-redis.md).
- Perda de um papel reflete na permissão já na requisição seguinte.
- Uma pessoa com os dois papéis acessa as funcionalidades de ambos **sem trocar de conta**.
- A criação de administrador precisa de um caminho separado do cadastro público — e de um
  administrador inicial criado fora da aplicação, por seed.
- Toda consulta de matchmaking filtra por papel completo, não por papel declarado.
