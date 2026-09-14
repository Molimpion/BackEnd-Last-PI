# ADR 0024 — A nota do mentor é pública; a do investidor não

**Status:** Aceito. Substitui parcialmente o [ADR 0012](./0012-visibilidade-assimetrica-do-feedback.md).
**Data:** 2026-09-14
**Requisito:** RF02, RF08, RF10, RF16

## Contexto

O [ADR 0012](./0012-visibilidade-assimetrica-do-feedback.md) decidiu que a avaliação recebida por
investidores **e mentores** fica visível apenas ao administrador. A justificativa foi:

> expor publicamente a nota do lado escasso do marketplace tende a afastá-lo, comprometendo a oferta
> que sustenta a plataforma.

Essa justificativa descreve o **investidor** — quem disputa com capital e cuja atenção é o recurso
escasso. Ela foi aplicada ao mentor por arrastamento, porque a seção 3.1 agrupa os dois no tipo de
conta `PESSOA`. Mentor não aporta capital e não está sujeito à mesma dinâmica: um mentor bem avaliado
tende a **querer** que isso apareça.

Há um segundo problema que forçou a revisão. O perfil do mentor declara áreas de expertise e anos de
experiência, e isso é **autodeclaração**: ninguém comprova. A dor central da plataforma é
desconfiança quanto à seriedade dos perfis — o Carlos declara receio quanto à governança dos
fundadores, e o mesmo ceticismo se aplica a quem se apresenta como mentor.

## Decisão

**A avaliação recebida pelo mentor é visível à startup. A avaliação recebida pelo investidor
continua visível apenas ao administrador.**

A credibilidade do mentor se constrói em duas etapas:

**Até a terceira avaliação** — vale o que ele declarou, conferido pela moderação. O administrador
verifica se as áreas e os anos de experiência declarados são coerentes com o LinkedIn informado
(RF16), e a aprovação concede o selo de verificado. Ver
[ADR 0025](./0025-criterios-de-moderacao-por-tipo-de-conta.md).

**A partir da terceira avaliação** — a nota recebida das startups substitui a autoclassificação.
Três é o mínimo para haver tendência: uma avaliação isolada pode ser sorte ou azar.

**Na exibição:**

- No **cartão de afinidade**, aparece apenas um dos dois — a autoclassificação antes da virada, a
  nota depois. Cartão é para decidir em segundos, e dois indicadores concorrentes atrapalham.
- No **perfil expandido**, a startup vê os dois: o que o mentor declarou e o que quem foi mentorado
  avaliou.

## Alternativas recusadas

**Manter a simetria do ADR 0012.** Recusado por desperdiçar o único sinal verificado que o sistema
coleta sobre mentoria. A nota vem de quem foi efetivamente mentorado — é evidência de uso, não
alegação. Escondê-la deixa a startup decidindo com base no que o próprio mentor escreveu sobre si.

**Tornar pública também a nota do investidor.** Recusado: é exatamente o que o ADR 0012 protege, e a
razão dele continua válida. O investidor é o lado escasso disputado por capital, e a exposição da
nota é custo adicional de participar num lado que já é minoria.

**Confiar apenas na autoclassificação.** Recusado porque não é verificável e infla sozinha: ninguém
se declara iniciante. Sem contrapeso, o campo vira decoração.

**Confiar apenas na nota, sem autoclassificação.** Recusado pela partida a frio. Mentor recém-chegado
não tem avaliação nenhuma, e ficaria indistinguível de mentor mal avaliado — o que afasta justamente
quem está entrando.

**Escala nomeada (`BASICO`, `INTERMEDIARIO`, `AVANCADO`) em vez de anos.** Recusado porque rótulo é
opinião e ano é fato conferível. O administrador consegue verificar "8 anos em produto" contra o
histórico datado do LinkedIn; não consegue verificar "avançado".

## Consequências

- **O ADR 0012 continua valendo integralmente para o investidor.** A parte dele que tratava do mentor
  está substituída por este ADR.
- **A moderação vira dependência operacional.** Antes da terceira avaliação, a credibilidade do
  mentor depende inteiramente de alguém conferir o LinkedIn. Se a moderação atrasar, o mentor novo
  fica sem sinal nenhum.
- O modelo precisa guardar a **contagem de avaliações recebidas** por mentor, porque é ela que
  define qual indicador aparece no cartão.
- A regra de exibição é do backend, não do front: a API decide o que devolve conforme a contagem.
  Deixar essa decisão para o cliente repetiria o erro que o RF04 proíbe — restrição aplicada só na
  interface não é restrição.
- Três avaliações num projeto de um semestre pode ser difícil de alcançar. Se a rodada beta mostrar
  que quase ninguém vira, o número deve ser reavaliado — não a regra.
