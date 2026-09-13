# ADR 0015 — Cookie entre domínios distintos em vez de proxy sob domínio único

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seção 8.1, RF07, RNF02

## Contexto

O front-end é hospedado na Vercel e o back-end no Render. São domínios distintos, e o navegador
trata a comunicação entre eles como requisição entre sites diferentes.

A sessão é opaca, referenciada por cookie ([ADR 0002](./0002-sessao-opaca-em-redis.md)). Com o
padrão `SameSite=Lax`, **o navegador simplesmente não envia o cookie** nessa situação.

O que torna isso perigoso não é a dificuldade — a correção é trivial. É o sintoma: o login parece
funcionar, o servidor responde com sucesso, e a requisição seguinte retorna "não autenticado". A
falha se disfarça de bug de autenticação, e o grupo pode perder horas investigando sessão, Redis e
hash de senha, que estão todos corretos.

## Decisão

Manter os domínios distintos e configurar o cookie para atravessá-los:

- Cookie de sessão com **`SameSite=None`**, que autoriza o envio entre sites diferentes, e
  obrigatoriamente **`Secure`**, que exige HTTPS.
- CORS no back-end aceitando a **origem explícita** do front-end e **permitindo credenciais** —
  nunca `origin: "*"`, que é incompatível com credenciais.
- Proteção CSRF por _double-submit_, já que a credencial passa a ser enviada automaticamente pelo
  navegador.

**Isso deve ser validado na primeira semana de desenvolvimento, não na integração final.**

## Alternativas recusadas

**Servir front e back sob o mesmo domínio**, com o back em subcaminho via proxy. Elimina o problema
por completo — sem requisição entre sites, `SameSite=Lax` basta e o CSRF fica naturalmente mitigado.
Recusado pelo custo de infraestrutura: exigiria proxy reverso próprio ou reconfigurar a hospedagem,
abandonando o deploy direto de Vercel e Render que o projeto escolheu. É a alternativa tecnicamente
superior, descartada por escopo.

**Usar as rotas de API do Next.js como intermediário**, o que também colocaria tudo sob um domínio.
Recusado no [ADR 0016](./0016-front-consome-o-back-diretamente.md) por motivo independente:
duplicaria o lugar onde investigar falhas.

**Token em `localStorage` em vez de cookie.** Contorna o problema porque `localStorage` não tem
restrição de site. Recusado porque é vulnerável a XSS — qualquer script injetado lê o token — e
porque abandonaria o `HttpOnly`, que é a proteção principal da sessão.

## Consequências

- **`Secure` implica HTTPS em todo ambiente que não seja `localhost`.** Não há como testar o fluxo
  real sobre HTTP.
- A origem do front é configuração (`FRONTEND_ORIGIN`), não constante. Ambiente novo significa
  variável nova.
- O CSRF por _double-submit_ precisa existir antes da primeira rota autenticada, não depois.
- O custo desta decisão é pago uma vez, na configuração. O custo de descobri-la tarde é pago em
  horas de depuração no lugar errado — por isso está registrada.
