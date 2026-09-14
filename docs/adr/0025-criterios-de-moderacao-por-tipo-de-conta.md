# ADR 0025 — Critérios de moderação por tipo de conta

**Status:** Aceito
**Data:** 2026-09-14
**Requisito:** RF08, RF16, RF07, RNF10

## Contexto

O RF08 exige que toda decisão de moderação tenha justificativa registrada e lista três critérios
explícitos:

1. Existência real da startup (site, CNPJ ou vínculo com o Porto Digital).
2. Canvas preenchido de forma coerente e não genérica.
3. Ausência de conteúdo ofensivo, enganoso ou fraudulento.

**Os três são sobre startup.** Mas o RF16 diz que perfil não verificado não aparece em matchmaking
nem em busca — e isso vale para qualquer perfil, não só o da startup. Sem critério escrito para
`PESSOA`, o administrador aprova ou reprova investidor e mentor por impressão, e a justificativa
registrada não tem contra o quê ser comparada.

O problema ficou concreto com o [ADR 0024](./0024-nota-do-mentor-e-publica.md): a credibilidade do
mentor novo depende inteiramente da conferência do LinkedIn. Se esse critério não estiver escrito,
ele não acontece.

## Decisão

Critérios explícitos por tipo de conta. Toda decisão continua exigindo justificativa registrada, e
toda reprovação permite correção e reenvio.

### `STARTUP`

1. **Existência real** — site, CNPJ quando houver, ou vínculo comprovável com o Porto Digital.
2. **Canvas coerente e não genérico** — os blocos descrevem um negócio específico, não texto que
   serviria para qualquer startup.
3. **Sem conteúdo ofensivo, enganoso ou fraudulento.**

### `PESSOA`

1. **LinkedIn ativo e coerente** com a empresa e a atuação declaradas.
2. **Papel `MENTOR`** — as áreas de expertise e os **anos de experiência** declarados são coerentes
   com o histórico datado do LinkedIn. É este critério que sustenta o ADR 0024 até a terceira
   avaliação.
3. **Papel `INVESTIDOR`** — a tese declarada (segmentos, estágios, faixa de ticket, modelo) é
   coerente com o histórico. Incoerência grosseira entre atuação e tese é sinal de perfil não sério.
4. **Sem conteúdo ofensivo, enganoso ou fraudulento.**

### `ADMINISTRADOR`

**Não passa por moderação pública.** A conta é criada por outro administrador (seção 3.1), nunca por
cadastro público, e exige MFA ativo para acessar qualquer funcionalidade administrativa (RF07).

O controle aqui não é aprovação, é **rastro**: a criação de uma conta de administrador é registrada
na auditoria, com quem criou e quando (RNF10).

## Alternativas recusadas

**Critério único para todos os tipos.** Recusado porque o que se verifica é materialmente diferente.
Startup se comprova por existência jurídica e coerência de proposta; pessoa se comprova por
histórico profissional. Um critério que sirva para os dois seria vago demais para decidir qualquer
coisa.

**Não moderar `PESSOA`.** Recusado por duas razões. O RF16 é explícito: perfil não verificado não
aparece em matchmaking nem em busca — moderar só startup deixaria metade do marketplace sem selo. E
o ADR 0024 ficaria sem fundamento: a nota do mentor só substitui a autoclassificação depois de três
avaliações, e até lá não haveria nada conferido.

**Submeter o administrador à mesma fila de moderação.** Recusado por circularidade: quem modera o
moderador? A conta já nasce restrita — criada apenas por outro administrador, com MFA obrigatório e
criação registrada em auditoria. Acrescentar aprovação seria cerimônia sem ganho.

**Moderação automatizada por heurística.** Recusado pelo RF08, que exige justificativa registrada e
rastreável a um administrador nomeado: _"nenhuma decisão de moderação é anônima"_. Regra automática
não justifica nada, e ainda cria a tentação de tratar reprovação como fato em vez de decisão.

## Consequências

- **O trabalho de moderação cresce.** Antes era conferir startups; agora é conferir todo cadastro. É
  custo real e recorrente, e alguém do grupo precisa assumi-lo — o documento já reconhece a
  administradora Ana como persona, mas o papel precisa ter dono de verdade.
- **A fila de moderação vira caminho crítico do produto.** Perfil não aprovado não aparece em lugar
  nenhum (RF16), então atraso na moderação é indisponibilidade funcional, não incômodo.
- Os critérios entram na interface do administrador como checklist, não como texto solto — é o que
  torna a justificativa comparável entre decisões.
- Toda decisão gera registro de auditoria com quem decidiu, quando e por quê (RNF10). Isso inclui
  reprovação, que precisa ser explicada ao usuário para permitir correção e reenvio.
- A aprovação de `PESSOA` passa a ser pré-requisito do ADR 0024. Se ela não acontecer, o mentor novo
  não tem selo nem nota.
