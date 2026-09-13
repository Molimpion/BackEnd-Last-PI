## O que muda

<!-- Descreva o comportamento, não os arquivos. Quem lê precisa saber o que passa a funcionar. -->

## Como testar

<!-- Passos para quem revisa reproduzir. -->

## Checklist

- [ ] `npm run quality -- --base=origin/dev` passou localmente
- [ ] Endpoint, DTO e especificação OpenAPI alterados neste mesmo PR
- [ ] Variável de ambiente nova adicionada ao `.env.example` neste mesmo PR
- [ ] Teste cobrindo o comportamento novo — de **integração**, se toca um dos cinco fluxos críticos
      do RNF07
- [ ] Decisão arquitetural relevante registrada como ADR em `docs/adr/`
- [ ] Mensagem de commit descreve o comportamento (ela é a fonte do changelog)

## Isso sai da lista de "não existe ainda"?

<!--
Se este PR implementa algo que o CONTEXT.md lista como inexistente, diga aqui qual item.
Não edite o CONTEXT.md — quem atualiza é o responsável técnico, na revisão.
Deixe em branco se não se aplica.
-->
