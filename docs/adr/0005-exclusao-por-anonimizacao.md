# ADR 0005 — Exclusão de conta por anonimização

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF14, RNF03

## Contexto

A LGPD garante ao titular o direito de exclusão, e o RF14 precisa instrumentalizar isso. A
implementação óbvia — apagar as linhas do titular — colide com dois fatos do produto:

- **O histórico de chat contém dado de terceiro.** Uma conversa tem duas partes. Apagar as mensagens
  de quem saiu mutila o histórico de quem ficou, que não pediu nada e tem interesse legítimo no
  próprio registro.
- **Os registros de interação sustentam as métricas do ecossistema** (RF09) e a auditoria (RNF10).
  Apagar interações faz números já apurados mudarem retroativamente, o que é justamente o oposto do
  que auditoria significa.

## Decisão

A exclusão de conta é realizada por **anonimização**: os dados pessoais identificáveis são removidos
ou substituídos, e os registros de interação são preservados de forma não identificável.

A operação exige confirmação explícita, é irreversível e gera registro de auditoria. Após ela,
nenhum dado pessoal identificável do titular permanece consultável na aplicação.

Separadamente, o RF14 também garante a **exportação** dos dados em formato legível por máquina —
exercer o direito de acesso não depende de excluir a conta.

## Alternativas recusadas

**Remoção total das linhas.** Recusado pelos dois motivos acima. Tecnicamente também obrigaria a
escolher entre cascatear a exclusão (destruindo dado de terceiro) ou deixar chaves órfãs
(corrompendo a integridade referencial).

**Soft delete com os dados intactos.** Recusado porque não é exclusão. Marcar `excluidoEm` e manter
nome, e-mail e CNPJ no banco atende à interface e falha ao direito — o dado continua lá, consultável
por quem tiver acesso ao banco.

**Anonimizar só o que aparece na interface.** Recusado pela mesma razão do RF04: restrição aplicada
apenas na apresentação não é restrição. O dado precisa sair do registro, não ser escondido na
consulta.

## Consequências

- Toda entidade com dado pessoal precisa de um caminho de anonimização escrito e testado. Isso é
  trabalho por entidade, não uma função genérica.
- Autoria de mensagem e de interação passa a apontar para uma conta anonimizada, não para o nada — as
  chaves estrangeiras continuam íntegras.
- A operação é irreversível por definição. Não existe "desfazer exclusão".
- O prazo de retenção de registros de auditoria é de 12 meses, independente da anonimização da conta.
- E-mail anonimizado precisa continuar satisfazendo a restrição de unicidade da `Conta`.
