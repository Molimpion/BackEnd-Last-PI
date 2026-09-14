# ADR 0012 — Visibilidade assimétrica do feedback pós-interação

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF10, RF08

## Contexto

Depois de uma reunião marcada como realizada, as duas partes avaliam a interação (RF10). A startup
avalia a qualidade da conversa e a utilidade da orientação; o investidor avalia a preparação da
startup e a aderência à sua tese.

A escolha simétrica — as duas notas públicas, como em marketplace de serviços — cria um problema
específico deste produto: **o investidor é o lado escasso**. Ele não precisa da plataforma tanto
quanto a startup precisa dele. Qualquer coisa que aumente o custo de participar tende a tirá-lo do
sistema, e sem investidores a plataforma não tem o que oferecer às startups.

Ao mesmo tempo, a nota do investidor tem valor real: é sinal de que alguém está desperdiçando o
tempo do outro lado, e isso é problema de moderação.

## Decisão

A visibilidade é **assimétrica, por decisão de produto**:

- A avaliação recebida pela **startup** é visível em seu perfil, auxiliando a triagem do investidor.
- A avaliação recebida pelo **investidor ou mentor** é visível **apenas ao administrador**, servindo
  como sinal de moderação (RF08).

A avaliação é por nota e campos estruturados, não apenas texto livre.

## Alternativas recusadas

**Simetria pública.** Recusado porque expor publicamente a nota do lado escasso tende a afastá-lo,
comprometendo a oferta que sustenta a plataforma. O ganho de transparência não compensa a perda de
participação de quem já é minoria.

**Simetria privada** — nenhuma nota pública, só o administrador vê as duas. Recusado porque descarta
o benefício principal para o investidor: a nota da startup é exatamente o "filtro confiável" que a
persona pede, e escondê-la desperdiça o dado que o sistema coletou.

**Não coletar a avaliação do investidor.** Recusado porque o administrador perderia o único sinal
estruturado sobre comportamento do lado escasso — e ele existe, incluindo o caso do investidor que
marca reunião e não aparece.

## Consequências

- A visibilidade é **campo na linha do feedback**, não filtro aplicado na consulta. Se depender de
  alguém lembrar de filtrar em cada endpoint, uma consulta esquecida vaza a nota do investidor.
- A assimetria precisa ser explicada na interface no momento da avaliação. Quem avalia tem que saber
  quem vai ler — senão a decisão vira surpresa desagradável quando descoberta.
- A nota do investidor entra no painel de moderação, não em nenhuma resposta de API consumida pelo
  front público.
- É uma decisão de produto, não técnica: se a dinâmica do marketplace mudar — investidores deixarem
  de ser o lado escasso — ela deve ser reavaliada.
- **A assimetria vale para a nota, não para o perfil.** O perfil do investidor — tese, segmentos de
  interesse, estágios e faixa de ticket — é visível à startup, porque sem isso ela não teria o que
  buscar no RF15 e a descoberta só funcionaria num sentido. O que este ADR protege é a **avaliação
  recebida**, que é juízo de terceiro sobre a pessoa. Declarar a própria tese não afasta ninguém;
  ter a própria nota exposta, sim.

**Pendente:** os critérios e a escala da avaliação não foram definidos. É a dúvida 3 da matriz CSD, a
resolver na rodada beta (RNF04).
