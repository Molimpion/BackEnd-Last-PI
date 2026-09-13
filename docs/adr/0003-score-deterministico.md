# ADR 0003 — Score de afinidade determinístico

**Status:** Aceito
**Data:** 2026-09-13
**Requisito:** RF03, RNF11

## Contexto

O motor de matchmaking cruza startups e investidores por segmento, estágio, faixa de ticket e modelo
de negócio. Duas exigências moldam a solução:

- **Explicabilidade.** O RF03 determina que nenhum cartão de afinidade é exibido sem justificativa em
  linguagem natural ("compatível em segmento e estágio; ticket 20% acima da sua faixa").
- **Verificabilidade.** A disciplina de Verificação e Validação exige critério testável: o mesmo par
  de perfis, com os mesmos dados, precisa produzir sempre o mesmo score.

O produto também tem um serviço de IA separado, cuja função ainda não foi definida.

## Decisão

Score de 0 a 100 calculado por função determinística, com pesos definidos e documentados sobre os
quatro atributos. Exibição por **limiar**, não por corte booleano eliminatório.

O cálculo é sob demanda, sem tabela de match materializada — o score é função dos perfis, e perfil
muda.

## Alternativas recusadas

**Modelo probabilístico ou aprendizado de máquina.** Recusado por três razões somadas. Não há dado
histórico para treinar: o sistema nasce vazio, e é justamente a partida a frio que o projeto precisa
atravessar. Não produz justificativa auditável em linguagem natural sem uma camada de explicação por
cima, que seria trabalho maior que o próprio motor. E tornaria o RF03 impossível de testar por
igualdade, substituindo o critério objetivo por avaliação subjetiva de qualidade.

**Corte eliminatório em vez de limiar.** Recusado pela partida a frio. Com base pequena, corte rígido
produz tela vazia — o usuário abre a plataforma, não vê ninguém, e não volta. Limiar degrada
suavemente: mostra o que existe, ordenado, com a justificativa dizendo onde a compatibilidade é
fraca.

**Delegar o cálculo ao serviço de IA.** Recusado pelo RNF11. Se o score dependesse da IA, a
indisponibilidade dela derrubaria a funcionalidade central do produto. O critério de aceitação do
RNF11 é explícito: com o serviço de IA desligado, o matchmaking permanece funcional.

## Consequências

- Os pesos são configuração versionada, não mágica no código. Alterá-los é mudança revisável.
- A IA fica restrita a camada auxiliar — resumo de pitch, assistente de preenchimento, extração de
  tese a partir de texto livre. Nunca o score em si.
- O teste de determinismo é trivial de escrever e entra nos fluxos críticos do RNF07.
- Os campos usados no cálculo precisam de índice (RNF05).

**Pendente:** os pesos exatos e o valor do limiar não foram definidos (seção 11, item 7). Sem eles o
motor não se implementa — e escolher números por conta própria seria inventar regra de negócio.
