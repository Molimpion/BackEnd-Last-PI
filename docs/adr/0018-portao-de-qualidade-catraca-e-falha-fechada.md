# ADR 0018 — Portão de qualidade: catraca, cobertura sobre o diff e falha fechada

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** Seções 9.4 e 9.5, RNF07

## Contexto

O CI precisa decidir se um PR pode ser mesclado. Rodar os comandos soltos no workflow resolve o
básico, mas produz três problemas conhecidos, dois deles observados na implementação de referência
que o grupo usou antes (seção 9.5).

- Os comandos param na primeira falha. A pessoa conserta o lint, faz push, espera, e só então
  descobre que os tipos também estavam quebrados.
- Uma meta fixa de qualidade ou trava o projeto (se o código atual não a atinge) ou é inútil (se
  está folgada demais).
- **O mais grave:** na implementação de referência, o código de saída das ferramentas não era
  verificado, e saída vazia era interpretada como ausência de problemas. Uma falha de rede na
  auditoria de dependências faria a verificação de vulnerabilidade crítica desaparecer sem qualquer
  sinal vermelho.

## Decisão

Um script próprio (`scripts/quality-gate.ts`, `npm run quality`) com sete verificações, e três
propriedades:

**1. Coleta tudo antes de decidir.** As sete verificações rodam sempre; o script reporta todas e só
então sai com código de erro.

**2. Catraca contra baseline congelado** (`quality-baseline.json`). Estritamente maior reprova, igual
passa. A dívida técnica só pode diminuir, sem obrigar a zerá-la antes de continuar. Vulnerabilidade
crítica é bloqueio absoluto, sem entrada no baseline — não existe número a afrouxar.

**3. Falha fechado.** Verificação que **não conseguiu executar** reprova, e é reportada como
`NAO EXECUTOU`, distinta de `REPROVOU`. Ferramenta que quebrou não é ferramenta que achou zero
problema.

Cobertura medida **sobre as linhas adicionadas pelo PR**, com mínimo de 70% — o mesmo número do
RNF07.

## Alternativas recusadas

**Percentual de cobertura global congelado.** Recusado por diluição: um PR grande e bem testado num
projeto com passivo descoberto pode fazer o percentual global cair, barrando contribuição legítima.
Medir só o diff avalia a contribuição da pessoa, não o passivo herdado.

**Baseline por contagem de vulnerabilidades.** Recusado porque tem furo: se um PR remove uma
vulnerabilidade e introduz outra, o total não muda e o portão aprova. O baseline registra
**identificadores de advisory**, então advisory novo reprova mesmo com o total estável.

**Rodar os testes no workflow, antes do portão.** Recusado porque o curto-circuito voltaria pela
porta dos fundos: suíte vermelha impediria as outras seis verificações de rodar. O portão executa a
suíte ele mesmo.

**Cobertura por statement.** Recusado pelo RNF07: os cinco fluxos críticos são majoritariamente
caminhos de erro — webhook duplicado, cobrança falha, cota esgotada, acesso negado — e cobertura por
statement aprova um `if` novo tendo exercitado apenas o caminho feliz.

## Consequências

- **O baseline é editável por quem está sendo medido.** Isso é limitação assumida: o que resolve não
  é código, é a revisão obrigatória — alterar o baseline vira uma linha de diff que outra pessoa
  precisa aprovar. Depende do [ADR 0017](./0017-repositorios-publicos.md) para ser barreira real.
- As verificações de `any` são baseadas em expressão regular, sem parser, e podem gerar falso
  positivo em string ou comentário.
- O portão não detecta `.skip` nem `.only`. Fica valendo a regra de processo.
- A cobertura sobre o diff exige `fetch-depth: 0` no checkout — sem histórico completo o git não acha
  o ancestral comum.
- Em evento de `push` não há base de comparação, e a cobertura do diff é reportada como não
  aplicável.
