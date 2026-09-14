# Projeto Matchmaking

**Plataforma de Matchmaking para Startups e Investidores Anjo do Nordeste**

Projeto Integrador — 5º Período ADS — "Startups e Economia Criativa"
Disciplinas integradas: Full Stack (Unidade de Extensão), Empreendedorismo, Governança em TI, Verificação e Validação.

---

## 1. Contexto e escopo

**Contexto.** Porto Digital (Bairro do Recife) e o ecossistema de startups e economia criativa local.

**Desafio.** Criar um produto completo (SaaS) que conecte startups nascentes do Porto Digital a mentores e investidores, incluindo modelo de negócio e governança.

**Entrega.** Produto de software completo, pronto para lançamento (Go-to-Market), acompanhado do plano de negócios e da documentação de governança.

**Foco direto.** Reduzir a mortalidade precoce de startups por falta de capital (capital de giro/caixa) e por falta de validação de mercado, via conexão qualificada com _smart money_ e mentoria estratégica.

### 1.1 Posicionamento do produto

A plataforma é **um ambiente de conexão e relacionamento**, não de intermediação de investimento. O sistema não processa aporte, não custodia valores e não formaliza participação societária. A negociação e o fechamento do _deal_ acontecem fora da plataforma; o sistema registra a conexão, a interação e o feedback.

Essa delimitação é deliberada e tem duas razões:

- **Regulatória.** Facilitar oferta de participação societária aproxima o produto do escopo de regulação da CVM (oferta pública e crowdfunding de investimento). Como plataforma de conexão, o produto fica fora desse terreno.
- **De escopo.** A jornada termina na reunião realizada e no feedback pós-interação, o que mantém o projeto executável no prazo do semestre.

### 1.2 Abrangência de segmento

A plataforma atende **qualquer segmento de startup** — Fintech, Healthtech, Agrotech, Edtech, Retailtech e demais. Não há nicho fechado.

Ser horizontal na aceitação, porém, **não é ser cego ao segmento**. Segmento, estágio, ticket buscado e tese de investimento são atributos estruturados e obrigatórios, em listas fechadas, porque são exatamente o insumo do motor de matchmaking. Aceitar todos sem classificar ninguém transformaria o produto em busca com filtro genérico.

### 1.3 Riscos estruturais reconhecidos

| Risco                                                           | Natureza     | Tratamento adotado                                                                                                                                     |
| --------------------------------------------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Partida a frio (_cold start_) de marketplace de dois lados      | Negócio      | Estratégia de captação inicial no plano de Go-to-Market; matchmaking por limiar (e não por corte eliminatório) para evitar tela vazia com base pequena |
| Investidor é o lado escasso e sua atenção é o recurso disputado | Produto      | Cota de solicitações por período, limiar mínimo de afinidade, pauta obrigatória em reunião                                                             |
| Desconfiança quanto à seriedade dos perfis                      | Produto      | Verificação de cadastro (RF16) + moderação com critérios explícitos (RF08)                                                                             |
| Exposição de dados estratégicos da startup                      | Conformidade | Níveis de visibilidade e autorização expressa de acesso (RF04, RF13)                                                                                   |
| Indisponibilidade do serviço de IA derrubar a plataforma        | Técnico      | Degradação graciosa obrigatória (RNF11)                                                                                                                |
| Perda silenciosa de confirmação de pagamento                    | Técnico      | Padrão outbox no fluxo de pagamento (seção 8.4)                                                                                                        |

---

## 2. Design Thinking

### Fase 1 — Empatia

#### Persona 1 — Mariana, empreendedora

_Foco em sobrevivência da startup e em captação de recursos de forma segura e estruturada._

**Dores — o que a frustra ou impede de avançar:**

- Enfrenta a falta de capital para manter seus desenvolvedores por mais de três meses.
- Possui dificuldade em traduzir métricas técnicas em uma proposta de valor atrativa para o mercado.
- Sofre com a timidez e a falta de conexões na cena local de venture capital.
- Sente receio de ter suas ideias ou os números estratégicos do seu negócio expostos publicamente.

**Buscas — o que ela precisa que o sistema resolva:**

- Deseja uma conexão qualificada com _smart money_ e mentoria estratégica para realizar a validação de mercado.
- Precisa de uma vitrine padronizada onde as informações essenciais sejam expostas inicialmente, mas os dados sensíveis fiquem seguros.
- Busca parar de gastar semanas abordando investidores que estão fora do perfil da sua startup.

#### Persona 2 — Carlos, investidor anjo

_Precisa de padronização e confiança imediata._

**Dores — o que o frustra ou impede de avançar:**

- Recebe centenas de "pitches ruins" no WhatsApp ou LinkedIn, sem nenhum formato padronizado.
- Perde muito tempo analisando startups que estão fora de sua tese, como avaliar modelos B2C quando só investe em B2B.
- Tem receio quanto à governança jurídica básica por parte dos fundadores das startups.
- Sofre com o excesso de ruído e com a falta de padronização na triagem de oportunidades.

**Buscas — o que ele precisa que o sistema resolva:**

- Necessita de um filtro confiável e centralizado que poupe seu tempo e ofereça dados comparáveis entre as empresas.
- Deseja cruzar interesses baseados em sua tese de investimento sem precisar analisar dezenas de apresentações (decks) manualmente.
- Exige que os agendamentos de reuniões tenham contexto, garantindo que nenhuma solicitação seja feita sem uma pauta clara associada ao estágio de investimento.

#### Persona 3 — Ana, administradora da plataforma

_É quem garante a integridade do ecossistema._

**Buscas — o que ela precisa que o sistema resolva:**

- Necessita de ferramentas para moderar os cadastros e o conteúdo publicado na plataforma.
- Precisa acompanhar métricas de uso gerais para entender a saúde do ecossistema, como número de matches, conversas iniciadas e reuniões agendadas.
- Precisa justificar e rastrear suas decisões de moderação a posteriori.

**Observação de modelagem.** A administradora **cuida do sistema e não participa dele**. Não é investidora nem mentora na mesma conta, e sua conta não é criada por cadastro público.

#### Mapa de empatia (resumo cruzado)

- **O que ouvem:** "startups no Nordeste têm dificuldade de captar porque o capital está concentrado no Sudeste".
- **O que veem:** editais burocráticos e eventos presenciais onde nem sempre há tempo útil para rodadas de negócios estruturadas.
- **O que precisam:** um filtro confiável e centralizado, que poupe tempo e ofereça dados comparáveis.

> **Nota de validação (V&V).** As personas acima são construídas a partir de pesquisa secundária. Recomenda-se complementá-las com entrevistas presenciais junto a fundadores e investidores do Porto Digital antes da entrega final, convertendo suposição em evidência de campo.

### Fase 2 — Definição

**Declaração de ponto de vista (POV).**
Empreendedores locais gastam semanas abordando investidores fora de perfil e falham por falta de clareza nas teses de negócio, enquanto investidores perdem oportunidades por excesso de ruído e falta de padronização na triagem.

**Perguntas norteadoras (How Might We).**

- **HMW 1:** como poderíamos cruzar interesses de tese de investimento sem que o investidor precise analisar dezenas de decks manualmente?
- **HMW 2:** como poderíamos padronizar a vitrine da startup de forma que dados sensíveis fiquem seguros e apenas as informações essenciais sejam expostas inicialmente?
- **HMW 3:** como poderíamos preservar a agência da startup para iniciar contato sem reproduzir o ruído que o investidor já sofre hoje?
- **HMW 4:** como poderíamos sustentar o produto financeiramente sem transformar a plataforma em intermediária de investimento?

### Fase 2.1 — Matriz CSD

#### Certezas

- **Sobre a empreendedora (Mariana):** enfrenta asfixia financeira — falta capital para manter desenvolvedores por mais de 3 meses — e possui dificuldade em traduzir métricas técnicas para o mercado.
- **Sobre a privacidade:** startups têm receio real de ter suas ideias ou números estratégicos expostos de forma pública.
- **Sobre o investidor (Carlos):** perde tempo analisando startups fora da sua tese (recebe pitches B2C quando só investe em B2B) e repudia materiais longos e sem padrão enviados por WhatsApp.
- **Sobre a solução (matchmaking):** o sistema deve cruzar interesses baseados em critérios exatos de afinidade — segmento, estágio, interesse e ticket médio — para evitar o desperdício de tempo de ambos os lados.

#### Suposições

- **O formato do Canvas:** supomos que quebrar o pitch em um formulário guiado por etapas (_wizard/stepper_) será suficiente para reduzir a carga cognitiva da Mariana e padronizar a leitura para o Carlos.
- **O nível de privacidade:** supomos que exibir apenas o perfil público (resumo e setor) nos cartões de afinidade será atrativo o bastante para o investidor dar o primeiro passo e solicitar acesso aos dados sensíveis.
- **Engajamento:** supomos que forçar o agendamento de reuniões com uma pauta clara associada ao estágio de investimento aumentará a confiança do investidor na seriedade da plataforma.

#### Dúvidas

- **Hierarquia de dados:** quais são exatamente os 3 ou 4 indicadores-chave (KPIs) que o Carlos procura nos primeiros 5 segundos ao olhar um cartão de afinidade?
- **Barreira de entrada:** quantas etapas de cadastro (consentimento LGPD + Canvas) a Mariana está disposta a preencher de uma única vez antes de abandonar o sistema?
- **Feedback pós-match:** após uma reunião, quais critérios específicos investidor e empreendedor usarão para avaliar um ao outro, de modo a gerar as métricas de confiabilidade da administradora?

> **Encaminhamento das dúvidas.** As três dúvidas acima são hipóteses a validar na rodada beta prevista no RNF04 e RNF07, e não devem ser resolvidas por decisão de escritório. O roteiro do teste de usabilidade deve incluir tarefas que as respondam.

### Fase 3 — Ideação

Dinâmicas que fundamentam a arquitetura:

1. **Pitch Canvas estruturado.** Em vez de upload de PDF despadronizado de 30 slides, a aplicação força o preenchimento dos blocos essenciais (problema, solução, proposta de valor, tamanho de mercado, tração, modelo de receita). É o que torna as startups comparáveis e o que dá insumo ao motor de afinidade.
2. **Matchmaking direcionado por tese.** O investidor recebe solicitações apenas de startups compatíveis com sua tese (segmento, ticket, estágio), a partir de um score com limiar mínimo.

   _Correção de nomenclatura:_ a versão anterior deste documento chamava esse mecanismo de "double-blind". O termo está incorreto — _double-blind_ significa anonimato mútuo entre as partes, o que não é o caso. O mecanismo correto é **triagem direcionada por tese**.

3. **Agendamento com contexto.** Nenhuma reunião é solicitada sem pauta clara associada ao estágio de investimento.
4. **Papéis acumuláveis.** Uma mesma pessoa pode ser mentor, investidor, ou ambos, sem duplicar cadastro.
5. **Cota de solicitações com devolução.** A startup tem um número limitado de solicitações por período; a cota é devolvida quando a solicitação é recusada ou expira, o que preserva a agência da startup sem gerar ruído.
6. **Planos e assinatura.** O modelo de receita é implementado no produto: o plano define limites reais de uso (cota, profundidade de match, acesso a métricas).
7. **Níveis de visibilidade.** Perfil público resumido para descoberta; perfil completo apenas mediante autorização expressa da startup.

### Fase 4 — Prototipação

**Jornada mapeada:** cadastro com consentimento LGPD ➔ verificação e moderação ➔ preenchimento do perfil/Canvas ➔ algoritmo de compatibilidade ➔ visualização de cartões de afinidade ➔ solicitação com pauta ➔ aceite ➔ chat/agendamento ➔ reunião ➔ feedback pós-interação.

Design mantido em Figma, com o front-end espelhando fielmente o protótipo.

### Fase 5 — Testes

Rodada beta com fundadores juniores e investidores convidados, validando clareza da interface e conclusão de tarefas antes da entrega final. A mesma rodada serve de evidência para RNF04 (usabilidade) e RNF07 (confiabilidade), e é a oportunidade de resolver as dúvidas da matriz CSD.

---

## 3. Atores e modelo de acesso

| Ator                        | Descrição                                                                                  |
| --------------------------- | ------------------------------------------------------------------------------------------ |
| Startup (Empreendedor)      | Cadastra a startup, apresenta modelo de negócio e Canvas, busca mentoria e/ou investimento |
| Investidor Anjo / Mentor    | Cadastra perfil de interesse, avalia startups compatíveis e interage com elas              |
| Administrador da Plataforma | Modera cadastros e conteúdo, consulta auditoria e acompanha métricas do ecossistema        |

### 3.1 Tipo de conta e papéis

O modelo separa dois conceitos que normalmente são confundidos:

- **Tipo de conta** — `STARTUP`, `PESSOA` ou `ADMINISTRADOR`. É exclusivo e define a natureza do cadastro.
- **Papéis** — existem apenas dentro do tipo `PESSOA` e são **acumuláveis**: `INVESTIDOR`, `MENTOR`, ou ambos. Definem quais blocos de perfil foram preenchidos e como a pessoa entra no matchmaking.

A permissão resulta da soma: o tipo de conta define o conjunto de funcionalidades, os papéis refinam dentro dele. Uma pessoa com os dois papéis acessa as funcionalidades de ambos sem trocar de conta.

O administrador é **tipo de conta separado**, criado apenas por outro administrador, nunca por cadastro público. A razão é evitar conflito de interesse na moderação e manter a auditoria limpa.

---

## 4. Requisitos Funcionais

> Todos os requisitos abaixo possuem critério de aceitação verificável. Os requisitos RF01–RF11 correspondem ao documento base da disciplina, aqui refinados; RF12–RF17 são acréscimos que cobrem lacunas identificadas.

### RF01 — Cadastro de startup

_Disciplina: Full Stack_

O sistema deve permitir o cadastro de startups com perfil estruturado.

**Campos obrigatórios:** nome, segmento (lista fechada), estágio (lista fechada: ideação, validação, tração, escala), cidade, descrição curta, faixa de capital buscado, natureza da busca (capital, mentoria ou ambos).
**Campos opcionais:** CNPJ (muitas startups em ideação ainda não o possuem), site, logotipo.

**Critérios de aceitação:**

- O cadastro não é submetido sem todos os campos obrigatórios preenchidos.
- Segmento e estágio são obrigatoriamente valores de lista fechada — texto livre inviabiliza o cruzamento do motor de afinidade.
- A startup é criada com status `PENDENTE` e não aparece em nenhum resultado de matchmaking até ser aprovada (RF08).

### RF02 — Cadastro de investidor / mentor

_Disciplina: Full Stack_

O sistema deve permitir o cadastro de pessoas com papéis acumuláveis.

**Bloco comum:** nome, e-mail, cidade, LinkedIn, empresa/atuação atual.
**Bloco do papel `INVESTIDOR`:** segmentos de interesse (múltipla escolha), estágios de interesse, faixa de ticket, modelo preferido (B2B, B2C ou ambos).
**Bloco do papel `MENTOR`:** áreas de expertise, disponibilidade em horas por mês.

**Critérios de aceitação:**

- Quem marca os dois papéis preenche os dois blocos.
- O usuário pode adicionar um papel posteriormente; ao adicionar, é obrigado a completar o bloco correspondente antes de o papel ficar ativo.
- Um papel incompleto não participa do matchmaking.

### RF03 — Motor de matchmaking

_Disciplinas: Full Stack / Empreendedorismo_

O sistema deve calcular a afinidade entre startups e investidores/mentores.

**Regras:**

- Score determinístico de 0 a 100, com pesos definidos e documentados sobre: segmento, estágio, faixa de ticket e modelo de negócio.
- Exibição por **limiar**, não por corte booleano eliminatório. Corte rígido produz tela vazia com base pequena e afasta o usuário na fase de partida a frio.
- O sistema deve exibir a **justificativa do score** em linguagem natural (ex.: "compatível em segmento e estágio; ticket 20% acima da sua faixa").

**Critérios de aceitação:**

- O mesmo par de perfis, com os mesmos dados, produz sempre o mesmo score (determinismo verificável em teste).
- Nenhum cartão de afinidade é exibido sem justificativa.
- Perfis não verificados ou não aprovados não entram no cálculo.

### RF04 — Visualização de perfis compatíveis e níveis de visibilidade

_Disciplina: Full Stack_

O sistema deve permitir a visualização de perfis compatíveis antes do contato, respeitando dois níveis:

- **Perfil público:** nome, segmento, estágio, descrição curta, faixa de capital buscado e score de afinidade. Visível a qualquer usuário aprovado.
- **Perfil completo:** Canvas integral, tração, números e documentos. Liberado apenas mediante autorização expressa da startup (RF13).

**Critérios de aceitação:**

- O investidor visualiza o cartão de afinidade sem qualquer solicitação prévia.
- Nenhum dado classificado como protegido trafega para o cliente antes da autorização — a restrição é aplicada no backend, não apenas ocultada na interface.

### RF05 — Comunicação e agendamento

_Disciplina: Full Stack_

O sistema deve permitir comunicação e agendamento de reuniões dentro da plataforma.

**Chat interno:** troca de mensagens com histórico persistido. Substitui a conversa dispersa em WhatsApp, que hoje perde histórico e não gera dado para o ecossistema.
**Agendamento interno:** a startup propõe data, hora e **pauta obrigatória**; o investidor ou mentor aceita, recusa ou contrapropõe horário; o sistema registra a reunião e seu desfecho.

**Destinatário da solicitação:** a startup pode enviar solicitação a um **investidor ou a um mentor**. A solicitação registra por qual papel a pessoa foi abordada (ADR 0030).

**Estados da reunião:** `PROPOSTA`, `CONFIRMADA`, `RECUSADA`, `REALIZADA`, `NAO_REALIZADA`. Contraproposta não é estado: cada proposta de horário fica registrada em histórico. Uma solicitação aceita pode originar várias reuniões, com **no máximo uma ativa** (`PROPOSTA` ou `CONFIRMADA`) por vez (ADR 0032).

**Critérios de aceitação:**

- O chat só é aberto após o aceite da solicitação — nunca antes.
- Nenhuma solicitação de reunião é criada sem pauta preenchida.
- Nenhuma solicitação aceita tem duas reuniões ativas ao mesmo tempo.
- Integração com calendário externo (Google Calendar e similares) está **fora de escopo**, documentada como evolução futura.

#### Regra de cota de solicitações

A startup possui cota de solicitações **por mês calendário**, definida pelo plano contratado (RF17). A cota volta no dia 1.

- A cota é **debitada no envio** da solicitação, seja a investidor ou a mentor.
- A cota é **devolvida** quando a solicitação é recusada pelo destinatário ou quando expira.
- A solicitação expira automaticamente em **15 dias** sem resposta.
- A startup tem **no máximo uma solicitação pendente** para a mesma pessoa pelo mesmo papel. Depois de recusada ou expirada, pode enviar de novo.

Estados da solicitação: `PENDENTE` → `ACEITA` | `RECUSADA` | `EXPIRADA`. A devolução ocorre nas transições para `RECUSADA` e `EXPIRADA`.

**Justificativa da regra:** debitar apenas no aceite esvaziaria o propósito da cota (recusa gratuita incentiva disparo em massa). Debitar sem devolver puniria a startup por recusa alheia. A cota bloqueada enquanto pendente é o que preserva o efeito anti-ruído.

### RF06 — Pitch e Business Model Canvas

_Disciplina: Empreendedorismo_

O sistema deve permitir que a startup apresente pitch e modelo de negócio dentro do perfil.

**Formato:** formulário guiado em etapas (_wizard/stepper_), com blocos obrigatórios — problema, solução, proposta de valor, tamanho de mercado, tração, modelo de receita — gerando visualização padronizada em Canvas.

**Critérios de aceitação:**

- A startup só se torna elegível ao matchmaking com o Canvas 100% preenchido.
- A visualização padronizada é idêntica entre startups, permitindo comparação direta pelo investidor.

### RF07 — Autenticação e controle de acesso

_Disciplinas: Full Stack / Governança em TI_

**Autenticação:** e-mail e senha, com verificação de e-mail obrigatória. Login social está fora de escopo, documentado como evolução.

**Sessão:** sessão opaca armazenada em Redis, referenciada por cookie `HttpOnly`. **Não se usa JWT.**
_Justificativa:_ o produto exige revogação imediata — moderação que reprova cadastro, assinatura que vence, plano que rebaixa, conta suspensa. Com JWT, essas mudanças só surtiriam efeito na expiração do token, e a solução usual (lista de revogação em Redis) equivale à sessão opaca com passos a mais.

**MFA:** segundo fator por TOTP (compatível com Google Authenticator, Authy, 1Password e qualquer aplicativo do padrão), com QR code de ativação e **códigos de recuperação de uso único**.

- Opcional para `STARTUP` e `PESSOA`.
- **Obrigatório** para `ADMINISTRADOR`.

**Autorização (RBAC):** permissão calculada a partir dos papéis **ativos no momento da requisição**, nunca de um valor fixo copiado na criação da sessão.

**Critérios de aceitação:**

- Usuário com papéis de mentor e investidor acessa as funcionalidades de ambos sem trocar de conta.
- Conta inativada, suspensa ou reprovada **não autentica** e tem sessões vigentes invalidadas — a verificação de conta ativa ocorre tanto no login quanto no filtro de cada requisição.
- Perda de um papel reflete na permissão já na requisição seguinte.
- Administrador sem MFA ativo não acessa funcionalidades administrativas.

**Proteções de borda:**

- Rate limit de tentativas de login **por IP**. Bloqueio por endereço de e-mail deve ser evitado ou usar limite alto com desbloqueio por confirmação, sob pena de virar vetor de negação de serviço contra terceiro (basta conhecer o e-mail da vítima e errar a senha repetidamente).
- Mensagem de erro genérica, sem distinguir e-mail inexistente de senha incorreta.
- Proteção CSRF por _double-submit_, já que a credencial trafega em cookie.

### RF08 — Moderação e auditoria administrativa

_Disciplinas: Full Stack / Governança em TI_

O administrador deve moderar cadastros e conteúdo publicado.

**Critérios explícitos de moderação:**

1. Existência real da startup (site, CNPJ ou vínculo comprovável com o Porto Digital).
2. Canvas preenchido de forma coerente e não genérica.
3. Ausência de conteúdo ofensivo, enganoso ou fraudulento.

**Critérios de aceitação:**

- Toda decisão de moderação exige justificativa registrada.
- O usuário é notificado do resultado e do motivo.
- Recusa permite correção e reenvio.
- Nenhuma decisão de moderação é anônima: fica registrado qual administrador decidiu, quando e por quê.

**Tela de auditoria (painel do administrador):** consulta dos registros de auditoria com filtro por tipo de ação, usuário e período, com exportação.

- É **tela de leitura**. O administrador consulta e exporta; não edita nem apaga registro.
- O próprio acesso à tela de auditoria gera registro.

### RF09 — Métricas

_Disciplinas: Empreendedorismo / Full Stack_

**Dashboard do administrador (ecossistema):** cadastros por segmento e estágio, taxa de aprovação na moderação, matches gerados, solicitações enviadas/aceitas/recusadas/expiradas, reuniões realizadas, assinaturas ativas por plano.

**Painel do usuário:**

- Startup: quantos investidores visualizaram seu perfil, status das solicitações enviadas, consumo de cota.
- Investidor: funil de solicitações recebidas, aceitas e reuniões realizadas.

**Critérios de aceitação:**

- Métricas do dashboard administrativo são agregadas e **anonimizadas** quando cruzam dados de terceiros.
- Métricas de visualização de perfil são um dos diferenciais entre plano gratuito e pago (RF17).

### RF10 — Feedback pós-interação

_Disciplina: Verificação e Validação_

Após reunião marcada como realizada, ambas as partes avaliam a interação, com nota e campos estruturados (não apenas texto livre).

- A startup avalia a qualidade da conversa e a utilidade da orientação recebida.
- O investidor avalia a preparação da startup e a aderência à sua tese.
- O mentor avalia a preparação da startup e a abertura à orientação.

**Escala:** nota de 1 a 5 por critério, com comentário livre opcional. A nota geral é a média dos critérios, não um valor informado à parte (ADR 0033).

**Visibilidade assimétrica, por decisão de produto:**

- A avaliação recebida pela **startup** é visível em seu perfil, auxiliando a triagem do investidor.
- A avaliação recebida pelo **investidor/mentor** é visível **apenas ao administrador**, servindo como sinal de moderação.

_Justificativa:_ expor publicamente a nota do lado escasso do marketplace tende a afastá-lo, comprometendo a oferta que sustenta a plataforma.

### RF11 — Consentimento e LGPD no cadastro

_Disciplina: Governança em TI_

O sistema deve exibir política de uso e coletar consentimento conforme a LGPD.

**Consentimento granular, não checkbox único:**

- Termos de uso — obrigatório.
- Tratamento de dados pessoais — obrigatório.
- Comunicações de marketing — **opcional**, sem prejuízo do cadastro.

**Critérios de aceitação:**

- Cada consentimento é registrado com data, hora, endereço IP e **versão do documento aceito**.
- O usuário não avança no cadastro sem os consentimentos obrigatórios.
- Alteração dos termos gera nova versão; o histórico de aceites anteriores é preservado.

### RF12 — Notificações

_Disciplina: Full Stack — requisito acrescentado_

**Canais:** notificação in-app (com histórico) e e-mail.

**Eventos notificáveis:** nova solicitação recebida; solicitação aceita ou recusada; nova mensagem no chat; reunião proposta, confirmada ou recusada; solicitação prestes a expirar; cadastro aprovado ou reprovado na moderação; cobrança aprovada; falha de cobrança; assinatura prestes a vencer; assinatura rebaixada.

**Critérios de aceitação:**

- O usuário controla por tipo quais notificações recebe por e-mail.
- Notificações in-app de eventos críticos de conta (moderação, segurança, assinatura) não são desativáveis.
- O envio de e-mail ocorre em processamento assíncrono, nunca no ciclo da requisição do usuário.

### RF13 — Autorização de acesso a dados protegidos

_Disciplinas: Full Stack / Governança em TI — requisito acrescentado_

Formaliza o fluxo que sustenta os níveis de visibilidade do RF04.

**Fluxo:** o investidor ou mentor solicita acesso ao perfil completo ➔ a startup é notificada e visualiza quem solicitou ➔ aprova ou nega ➔ o acesso concedido é registrado e pode ser **revogado a qualquer momento** pela startup.

**Critérios de aceitação:**

- Todo acesso a dado protegido gera registro de auditoria: quem acessou, o quê e quando.
- Revogação surte efeito imediato na requisição seguinte.
- Negativa não bloqueia futura solicitação, mas fica registrada.
- A startup vê se o pedido veio de investidor ou de mentor antes de decidir (ADR 0031).
- Existe no máximo um pedido pendente da mesma pessoa, pelo mesmo papel, para a mesma startup.

### RF14 — Direitos do titular (LGPD)

_Disciplina: Governança em TI — requisito acrescentado_

Implementa os direitos exigidos pelo RNF03, que o documento base não instrumentalizava.

**Exportação:** o titular obtém seus dados em formato legível por máquina.
**Exclusão de conta:** realizada por **anonimização**, não por remoção total.

_Justificativa da anonimização:_ histórico de chat contém dado de terceiro e registros de interação sustentam as métricas do ecossistema. A exclusão remove os dados pessoais identificáveis e preserva os registros de interação de forma não identificável.

**Critérios de aceitação:**

- A exclusão exige confirmação explícita, é irreversível e gera registro de auditoria.
- Após a exclusão, nenhum dado pessoal identificável do titular permanece consultável na aplicação.
- O prazo de retenção de registros de auditoria é de **12 meses**.

### RF15 — Busca e filtro manual

_Disciplina: Full Stack — requisito acrescentado_

Complementa o match automático com descoberta ativa.

**Filtros:** segmento, estágio, cidade, faixa de capital buscado, natureza da busca. **Ordenação:** score de afinidade ou data de cadastro. Mentores com plano que inclui destaque aparecem priorizados na busca por mentoria, identificados como destaque (ADR 0029). O destaque não altera o score.

**Critérios de aceitação:**

- A busca respeita os níveis de visibilidade do RF04 — resultados exibem somente perfil público.
- Filtro avançado e listagem completa são recursos do plano pago; o plano gratuito recebe resultado limitado (RF17).

### RF16 — Verificação de cadastro

_Disciplinas: Full Stack / Governança em TI — requisito acrescentado_

Distinto do RF08: a moderação é a decisão do administrador; a verificação é o **insumo** dessa decisão e o **sinal de confiança** para a outra parte.

**Startup informa:** site, CNPJ quando houver, vínculo com o Porto Digital.
**Pessoa informa:** LinkedIn e empresa/atuação atual.

**Critérios de aceitação:**

- Perfis aprovados exibem selo de verificado.
- Perfil não verificado **não aparece em matchmaking nem em busca**.

### RF17 — Planos e gestão de assinatura

_Disciplinas: Full Stack / Empreendedorismo — requisito acrescentado_

O modelo de receita é implementado no produto, e não apenas descrito no plano de negócios.

**Planos por público e nível** (ADR 0028). Cada público — startup, investidor e mentor — tem três níveis: `GRATUITO`, `PRO` e `PREMIUM`. Pessoa com os dois papéis pode ter uma assinatura por papel.

**O plano controla limites funcionais reais:**

| Recurso                            | Público    | Gratuito       | Pagos (`PRO`, `PREMIUM`)  |
| ---------------------------------- | ---------- | -------------- | ------------------------- |
| Cota mensal de solicitações        | Startup    | Limitada       | Ampliada                  |
| Matches visíveis                   | Investidor | Lista limitada | Lista ampliada a completa |
| Limite mensal de aceites           | Mentor     | Limitado       | Ampliado                  |
| Feedback detalhado por critério    | Mentor     | Não            | A definir por nível       |
| Destaque na busca manual (RF15)    | Mentor     | Não            | A definir por nível       |
| Busca com filtro avançado          | Todos      | Não            | A definir por nível       |
| Métricas de visualização de perfil | Todos      | Não            | A definir por nível       |
| Exportação de relatórios           | Todos      | Não            | A definir por nível       |

O que diferencia `PRO` de `PREMIUM`, e os valores de cada limite, estão pendentes (seção 11).

_Observação:_ a cota de solicitações não é um limite cosmético — é o mesmo mecanismo anti-ruído descrito no RF05. O plano e a proteção do lado escasso são servidos pela mesma regra.

**Modelo de cobrança:** **assinatura recorrente**, integrada ao gateway **AbacatePay**, com ambiente sandbox em desenvolvimento.

**Estados da assinatura:** `SEM_PLANO`, `ATIVA`, `CANCELADA_VIGENTE`, `INADIMPLENTE_EM_TOLERANCIA`, `ENCERRADA`.

**Transições:**

| De                           | Para                         | Disparo                                           |
| ---------------------------- | ---------------------------- | ------------------------------------------------- |
| `SEM_PLANO`                  | `ATIVA`                      | Confirmação de pagamento aprovado pelo gateway    |
| `ATIVA`                      | `CANCELADA_VIGENTE`          | Usuário cancela                                   |
| `ATIVA`                      | `INADIMPLENTE_EM_TOLERANCIA` | Falha de cobrança                                 |
| **`CANCELADA_VIGENTE`**      | **`ATIVA`**                  | **Usuário reativa, antes do fim do período pago** |
| `CANCELADA_VIGENTE`          | `ENCERRADA`                  | Fim do período pago (rotina agendada)             |
| `INADIMPLENTE_EM_TOLERANCIA` | `ATIVA`                      | Cobrança finalmente aprovada                      |
| `INADIMPLENTE_EM_TOLERANCIA` | `ENCERRADA`                  | Fim da janela de tolerância (rotina agendada)     |
| `ENCERRADA`                  | `SEM_PLANO`                  | Rebaixamento automático para o plano gratuito     |

**Reativação.** Em `CANCELADA_VIGENTE` o usuário ainda está dentro do período pago e mantém o acesso — o cancelamento é apenas a marcação de "não renovar". Reativar é desfazer essa marcação e **não envolve cobrança**. Depois que a assinatura chega a `ENCERRADA`, não há mais nada vigente a reativar: o caminho passa a ser contratação nova, com pagamento.

_Justificativa:_ obrigar a recontratar dentro do período vigente cria fricção desnecessária e abre risco de cobrança duplicada ou período sobreposto, caso o gateway inicie uma nova assinatura enquanto a anterior ainda vige.

**Funcionalidades:** contratar plano; visualizar plano atual e consumo de cota; consultar histórico de cobranças; cancelar assinatura.

**Critérios de aceitação:**

- O cancelamento mantém o acesso até o fim do período já pago (`CANCELADA_VIGENTE`), e só então rebaixa.
- A reativação dentro do período vigente é possível, imediata e sem nova cobrança.
- Falha de cobrança inicia janela de tolerância antes do rebaixamento, com notificação ao usuário.
- O rebaixamento ao fim da vigência é automático.
- **A liberação de plano ocorre exclusivamente por confirmação do gateway** — webhook validado ou consulta feita pelo servidor —, nunca pelo retorno de navegação do usuário.
- Uma rotina periódica do dispatcher consulta as cobranças no gateway e registra a confirmação que não chegou por webhook, pelo mesmo caminho de processamento. Cobrança já paga não produz efeito de novo (ADR 0035).
- O webhook valida a assinatura do gateway antes de qualquer processamento — endpoint isento de CSRF não é endpoint isento de autenticação.
- O processamento de webhook é **idempotente por ID de evento**.
- A confirmação de pagamento e o trabalho decorrente são gravados na mesma transação, conforme o padrão outbox descrito na seção 8.4.
- Todo webhook recebido é registrado com payload, resultado do processamento e data, permitindo reprocessamento manual e alimentando a auditoria (RNF10).

---

## 5. Requisitos Não Funcionais

> Cada RNF traz métrica objetiva e método de verificação. Requisito não verificável não é avaliável.

### RNF01 — Disponibilidade e desempenho

_Categoria: Disponibilidade | Disciplina: Full Stack_

- Tempo de resposta de até **2 s no percentil 95** para operações de leitura.
- Tempo de resposta de até **5 s no percentil 95** para o cálculo de matchmaking.
- Meta de disponibilidade mensal de **99%** em ambiente de homologação.

**Método de verificação:** teste de carga com **100 usuários simultâneos**, executado com k6 (alternativas: JMeter, Locust), contra ambiente de homologação **previamente aquecido** — jamais contra `localhost`, cujo resultado não representa a rede real. Relatório anexado à documentação de V&V.

**Ressalva registrada:** a meta de 99% de disponibilidade só é comprovável com monitoramento contínuo por período relevante. Na ausência desse monitoramento, ela é declarada como **meta de operação** na documentação de governança, e apenas os limites de desempenho são comprovados empiricamente. Não se declara número de uptime que não tenha sido medido.

### RNF02 — Segurança e criptografia

_Categoria: Segurança | Disciplina: Governança em TI_

- HTTPS obrigatório com **TLS 1.2 ou superior** em todas as rotas, sem exceção.
- Senhas armazenadas com **hash** (bcrypt ou argon2) — nunca criptografia reversível.
- Dados sensíveis do Canvas e documentos protegidos criptografados em repouso.
- Credenciais, chaves de API e segredos exclusivamente em variáveis de ambiente, nunca versionados.
- Cookie de sessão com atributo `Secure` **obrigatório em produção**.

**Método de verificação:** varredura de segredos no repositório, checagem da configuração de TLS e teste que falhe caso `Secure` esteja desabilitado no ambiente produtivo.

### RNF03 — Conformidade com a LGPD

_Categoria: Conformidade | Disciplina: Governança em TI_

O tratamento de dados pessoais segue a LGPD, instrumentalizado pelos requisitos:

| Princípio / direito               | Requisito que o implementa |
| --------------------------------- | -------------------------- |
| Consentimento e finalidade        | RF11                       |
| Direito de acesso e portabilidade | RF14 (exportação)          |
| Direito de exclusão               | RF14 (anonimização)        |
| Minimização e controle de acesso  | RF04, RF13                 |
| Segurança do tratamento           | RNF02                      |
| Rastreabilidade                   | RNF10                      |

**Retenção:** registros de auditoria por **12 meses**; dados de conta excluída anonimizados imediatamente.

**Método de verificação:** matriz de conformidade ligando cada princípio ao requisito correspondente, entregue como artefato de Governança em TI.

### RNF04 — Usabilidade

_Categoria: Usabilidade | Disciplina: Full Stack_

- Cadastro completo de startup, incluindo Canvas, concluído em **até 15 minutos** por usuário sem treino prévio.
- **Taxa de conclusão mínima de 80%** em teste com **5 usuários**.

**Método de verificação:** teste de usabilidade com roteiro de tarefas, 5 participantes que nunca usaram o sistema, observação sem intervenção (dificuldade socorrida é dificuldade não registrada), cronometragem e planilha de resultados. Cinco participantes é o número em que os problemas encontrados começam a se repetir.

**Artefatos entregues:** roteiro, planilha de resultados, lista de problemas identificados e correções aplicadas. Gravação de tela mediante consentimento dos participantes.

_A mesma rodada satisfaz o beta de RNF07._

### RNF05 — Escalabilidade

_Categoria: Escalabilidade | Disciplina: Full Stack_

Substitui a formulação anterior ("suportar crescimento sem redesenho"), que era inverificável, por critérios estruturais:

- Aplicação **stateless**, com sessão externalizada em Redis.
- Consultas de listagem **obrigatoriamente paginadas**.
- Índices presentes nos campos utilizados pelo motor de matchmaking.

**Método de verificação:** revisão de arquitetura documentada e teste de carga com volume simulado de **1.000 startups e 200 investidores** (massa gerada com faker).

### RNF06 — Governança de arquitetura e processo

_Categoria: Governança | Disciplina: Governança em TI_

- Arquitetura documentada em **diagrama de contêineres** (front, back, serviço de IA, PostgreSQL, Redis, gateway de pagamento e demais serviços externos).
- Padrão de commits (_conventional commits_, validado por commitlint) e de branches definido.
- **Revisão obrigatória por outro membro** antes de qualquer merge.
- Política de gestão de segredos via GitHub Secrets e variáveis de ambiente.

**Método de verificação:** o próprio repositório e o histórico de pull requests servem de evidência.

### RNF07 — Confiabilidade e testes

_Categoria: Confiabilidade | Disciplina: Verificação e Validação_

**Fluxos críticos de cobertura obrigatória:**

1. Autenticação, sessão e MFA
2. Motor de matchmaking
3. Controle de cota de solicitações
4. Fluxo de assinatura e webhook de pagamento
5. Controle de acesso a dados protegidos

**Exigências:**

- Cobertura mínima de **70%** nesses fluxos.
- **Testes de integração obrigatórios** nos cinco fluxos — não apenas testes unitários com dependências mockadas.
- **Branch coverage** (e não apenas cobertura por statement) nos fluxos críticos.
- Rodada beta com usuários reais antes do lançamento.

**Justificativa da exigência de integração:** os cinco fluxos críticos falham predominantemente em configuração, não em lógica isolada. Redis mockado não comprova que a sessão funciona; repositório mockado não comprova que a consulta está correta. Suíte 100% unitária atende o requisito no papel e não na prática.

**Justificativa do branch coverage:** os fluxos críticos deste produto são majoritariamente caminhos de erro — webhook duplicado, cobrança falha, cota esgotada, acesso negado. Cobertura por statement aprova um `if` novo tendo exercitado apenas o caminho feliz.

**Método de verificação:** portão de qualidade no CI (seção 8), com relatório de cobertura anexado como artefato de execução.

### RNF08 — Portabilidade e responsividade

_Categoria: Portabilidade | Disciplina: Full Stack_

- Interface funcional a partir de **320 px** de largura.
- Pontos de quebra testados em mobile, tablet e desktop.
- **Nenhuma funcionalidade exclusiva de desktop.**

**Método de verificação:** checklist de todas as telas nas três resoluções.

### RNF09 — Manutenibilidade

_Categoria: Manutenibilidade | Disciplina: Full Stack_

- Front-end e back-end desacoplados, comunicando-se **exclusivamente por API REST documentada em OpenAPI**.
- README por repositório com instruções completas de execução.
- Ambiente local reproduzível via **Docker Compose**.
- Código modular, com separação explícita entre camada HTTP, regra de negócio e acesso a dados.

**Método de verificação:** um integrante que não escreveu determinado serviço consegue executá-lo seguindo apenas o README.

### RNF10 — Auditabilidade

_Categoria: Auditabilidade | Disciplina: Governança em TI_

**Eventos registrados:** ações de moderação; concessão e revogação de acesso a dados protegidos; alterações de assinatura e eventos de pagamento; alterações de papel; tentativas de login malsucedidas; acessos à própria tela de auditoria.

**Conteúdo de cada registro:** quem, o quê, quando e de onde (endereço IP).

**Critérios de aceitação:**

- O log é **somente escrita** — nem o administrador edita ou remove registros.
- A consulta ocorre pela tela de auditoria descrita no RF08.

**Método de verificação:** revisão dos registros gerados durante os testes de aceitação.

### RNF11 — Resiliência à indisponibilidade do serviço de IA

_Categoria: Resiliência | Disciplina: Full Stack — requisito acrescentado_

O serviço de IA é uma aplicação separada. Sua falha **não pode** comprometer a plataforma.

- Toda chamada ao serviço de IA possui **timeout definido**.
- Falha ou indisponibilidade resulta em **degradação graciosa com aviso claro**, jamais em erro que interrompa a operação.

**Critério de aceitação:** com o serviço de IA **desligado**, permanecem plenamente funcionais o cadastro, o matchmaking determinístico, o chat, o agendamento e a assinatura.

**Método de verificação:** execução da suíte de aceitação com o serviço de IA derrubado deliberadamente.

_Benefício colateral:_ protege a apresentação final — falha do serviço de IA durante a banca não derruba a demonstração.

---

---

## 6. Arquitetura e stack

### 6.1 Visão geral do sistema

Três aplicações independentes, em repositórios separados:

| Repositório        | Responsabilidade                    | Hospedagem |
| ------------------ | ----------------------------------- | ---------- |
| `FrontEnd-Last-PI` | Interface web                       | Vercel     |
| `BackEnd-Last-PI`  | API, regra de negócio, orquestração | Render     |
| `IA-Last-PI`       | Serviço de inteligência artificial  | A definir  |

**Regras de comunicação:**

- O front-end consome **exclusivamente** o back-end.
- O serviço de IA é consumido **exclusivamente** pelo back-end. O front-end nunca o acessa diretamente.

### 6.2 Front-end

**Framework:** Next.js (React 19), com TypeScript.
_Justificativa:_ o grupo já utilizou Next.js em período anterior, e a familiaridade prevalece sobre a diferença técnica em relação a uma SPA com Vite. Deploy simplificado na Vercel.

**Bibliotecas:**

| Categoria              | Biblioteca                                                                                          | Função                                                                                |
| ---------------------- | --------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Design system          | **shadcn/ui**                                                                                       | Componentes copiados para o repositório, editáveis — permite fidelidade ao Figma      |
| Primitivos de UI       | radix-ui                                                                                            | Base acessível dos componentes                                                        |
| Estilo                 | tailwindcss, `@tailwindcss/postcss`, tailwind-merge, class-variance-authority, clsx, tw-animate-css | Estilização e composição de classes                                                   |
| Estado de servidor     | `@tanstack/react-query` + devtools                                                                  | Cache, revalidação, estados de carregamento e erro                                    |
| Geração de cliente     | **Kubb**                                                                                            | Gera tipos TypeScript, schemas Zod e hooks de React Query a partir do OpenAPI do back |
| Formulários            | react-hook-form, `@hookform/resolvers`, zod                                                         | Formulários longos com validação por bloco (Canvas em etapas)                         |
| Tempo real             | socket.io-client                                                                                    | Chat                                                                                  |
| Gráficos               | recharts                                                                                            | Dashboards do RF09                                                                    |
| Animação               | motion                                                                                              | Transições                                                                            |
| Tema                   | next-themes                                                                                         | Tema claro/escuro                                                                     |
| Feedback               | sonner                                                                                              | Toasts                                                                                |
| Componentes auxiliares | vaul, lucide-react                                                                                  | Drawer e ícones                                                                       |
| Datas                  | date-fns                                                                                            | Formatação e cálculo                                                                  |
| MFA                    | qrcode                                                                                              | QR code de ativação do TOTP                                                           |
| Qualidade              | eslint, `eslint-config-next`, prettier, husky, commitlint, typescript                               | Padrão de código e commits                                                            |

**Notas de versão:** utilizar o pacote `motion` (sucessor de `framer-motion`); manter `eslint-config-next` alinhado à major do Next; fixar TypeScript e `@types/node` em versões estáveis conhecidas em vez de adotar a mais recente.

**Cliente HTTP:** `fetch` nativo encapsulado em função utilitária única (base URL, credenciais, token CSRF, tratamento de erro), com React Query acima. Axios foi avaliado e dispensado — com Kubb e React Query, o cliente HTTP fica encapsulado e a dependência adicional não se justifica.

### 6.3 Back-end — stack

**Runtime e framework:** Node.js com TypeScript e **Express**.
_Justificativa:_ o grupo utilizou Express nos dois períodos anteriores e possui padrão consolidado. Nest.js e Fastify foram avaliados; o ganho de estrutura do Nest não compensa a curva de aprendizado diante do escopo do semestre, e cronograma é o principal fator de risco em projeto integrador.

_Contrapartida assumida:_ Express não impõe estrutura. A seção 6.4 existe justamente para suprir isso, e o cumprimento é verificado na revisão de pull request.

| Categoria          | Biblioteca                                                         | Função                                                                                             |
| ------------------ | ------------------------------------------------------------------ | -------------------------------------------------------------------------------------------------- |
| ORM / banco        | prisma, `@prisma/client`, `@prisma/adapter-pg`, pg                 | PostgreSQL                                                                                         |
| Cache e sessão     | ioredis                                                            | Sessão opaca, cota, rate limit                                                                     |
| Fila e agendamento | **bullmq**                                                         | E-mail assíncrono, expiração de solicitações, rebaixamento de assinatura, processamento de webhook |
| Tempo real         | socket.io                                                          | Chat                                                                                               |
| Autenticação       | bcrypt, **otplib**                                                 | Hash de senha e TOTP                                                                               |
| Validação          | zod                                                                | Entrada de dados (DTOs)                                                                            |
| Segurança de borda | helmet, cors, express-rate-limit, rate-limit-redis                 | Cabeçalhos, CORS, limitação de tentativas                                                          |
| Log                | pino, pino-http, pino-pretty                                       | Log estruturado                                                                                    |
| Monitoramento      | `@sentry/node`                                                     | Captura de erros em produção                                                                       |
| E-mail             | `@sendgrid/mail`                                                   | Envio transacional                                                                                 |
| Upload             | multer, cloudinary, multer-storage-cloudinary                      | Logotipos, fotos e documentos                                                                      |
| Pagamento          | AbacatePay (SDK/cliente HTTP)                                      | Assinatura recorrente                                                                              |
| Documentação       | swagger-jsdoc, swagger-ui-express, `@scalar/express-api-reference` | OpenAPI em duas interfaces                                                                         |
| Relatórios         | pdfkit, csv-stringify                                              | Exportações                                                                                        |
| Testes             | **vitest**, `@vitest/coverage-v8`, supertest, `@faker-js/faker`    | Unitário, integração e massa de dados                                                              |
| Qualidade          | eslint, typescript-eslint, husky, commitlint, tsx                  | Padrão de código e execução                                                                        |
| Ambiente           | dotenv, Docker, Docker Compose                                     | Configuração e serviços locais                                                                     |

**Removido em relação aos projetos anteriores do grupo:** `jsonwebtoken` (a sessão é opaca em Redis); `mqtt` (específico de IoT); `ts-node-dev` (redundante com `tsx`); Fastify; `pg` sem ORM; **`prom-client`** — decisão consciente de manter Prometheus e Grafana fora de escopo, dado que exigiriam frente própria de infraestrutura; o Sentry cobre erro e desempenho com painel pronto.

### 6.4 Back-end — arquitetura interna

#### Processos em runtime

O back-end **não é um processo único**. São três:

| Processo                   | Papel                                                                                                                                                            |
| -------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **API**                    | Recebe requisições HTTP e WebSocket, aplica regra, grava e responde                                                                                              |
| **Worker**                 | Consome as filas do BullMQ: envio de e-mail, processamento de trabalho de pagamento, tarefas assíncronas                                                         |
| **Dispatcher / agendador** | Varre o outbox e enfileira o que não foi enfileirado; executa as rotinas periódicas (expirar solicitação em 15 dias, devolver cota, rebaixar assinatura vencida) |

Essa separação é decisão estrutural: uma requisição HTTP nunca executa trabalho demorado. A API registra a intenção e responde; a execução acontece em outro processo. É o que permite ao sistema sobreviver a um serviço externo indisponível — gateway, provedor de e-mail, serviço de IA — sem derrubar a aplicação.

**Consequência de deploy:** o Render precisa hospedar três serviços a partir do mesmo repositório, não um.

#### Organização do código: por feature, não por categoria técnica

```
src/
  features/
    auth/          routes, controller, usecases, repository, dto
    startups/      routes, controller, service,  repository, dto
    canvas/        routes, controller, service,  repository, dto
    perfis/        routes, controller, service,  repository, dto
    match/         routes, controller, usecases, repository, dto
    solicitacoes/  routes, controller, usecases, repository, dto
    reunioes/      routes, controller, service,  repository, dto
    chat/          gateway, service, repository, dto
    assinaturas/   routes, controller, usecases, repository, dto
                   + webhook, outbox
    moderacao/     routes, controller, usecases, repository, dto
    auditoria/     routes, controller, service,  repository, dto
    notificacoes/  routes, controller, service,  repository, dto
                   + jobs
  infra/
    db.ts          cliente Prisma
    redis.ts       cliente Redis
    queue.ts       filas do BullMQ e politicas de retry
    session.ts     middleware de sessao e autorizacao
    errors.ts      erro de aplicacao e middleware de traducao
    logger.ts      logger estruturado
    mailer.ts      integracao de e-mail
    storage.ts     integracao de upload
    payments.ts    cliente do gateway
    ai-client.ts   cliente do servico de IA, com timeout
```

**Justificativa.** Com cerca de doze domínios, organizar por categoria técnica (`controllers/`, `services/`, `repositories/`) produz pastas grandes onde nada relacionado fica junto: alterar assinatura exigiria abrir quatro pastas distintas. Organizando por feature, o domínio é autocontido e duas pessoas trabalhando em domínios diferentes praticamente não colidem no controle de versão — o que importa em trabalho de grupo.

**Não existe `utils/` nem `types.ts` global.** O transversal mora em `infra/`, com nome que diz o que é.

#### Camadas e regra de fronteira

| Camada                 | Responsabilidade                           | Restrição                        |
| ---------------------- | ------------------------------------------ | -------------------------------- |
| `routes`               | Declara o caminho e pendura middlewares    | —                                |
| `controller`           | **Única camada que conhece HTTP**          | Não contém regra de negócio      |
| `dto`                  | Validação de entrada com Zod, na fronteira | —                                |
| `service` / `usecases` | Regra de negócio pura                      | Não conhece `request`/`response` |
| `repository`           | **Única camada que conhece Prisma**        | Não contém regra de negócio      |

**A dependência aponta para dentro:** controller conhece o caso de uso, o caso de uso conhece o repositório, nunca o contrário. Um service que importa `express` é um erro de arquitetura.

**Validação exclusivamente na borda.** O DTO valida com Zod no controller; abaixo dele, o dado já é confiável e tipado. Não se revalida em camada interna.

#### Service ou use case

Nem todo domínio precisa de casos de uso. A regra de corte, para não virar discussão a cada pull request:

> **É use case** se a operação tem mais de um passo, toca mais de uma tabela ou tem decisão condicional relevante.
> **É service** se a operação é ler e devolver.

**Domínios com use cases** (regra pesada): autenticação e sessão, matchmaking, solicitações com cota, assinatura, moderação, autorização de acesso a dados protegidos.
**Domínios com service simples:** cadastros, Canvas, perfis, reuniões, auditoria, notificações.

Nos domínios com use case, o controller chama o caso de uso diretamente — **não existe service intermediário**, sob pena de empilhar dois padrões.

Observe que os domínios com use case coincidem com os cinco fluxos críticos do RNF07. Não é coincidência: é onde a regra de negócio efetivamente vive, e portanto onde o teste de integração é obrigatório.

#### Repositório e teste

O repositório é a única camada que conhece Prisma, e essa fronteira é o que permite testar regra de negócio sem banco. Nos domínios de cadastro e consulta, service chamando Prisma diretamente é aceitável — ser dogmático ali custa cerimônia sem retorno.

#### Padrão de logging

**Decisão a tomar antes da implementação dos workers, não durante.** O service não pode receber o logger do Express sem violar a regra de fronteira, mas precisa registrar eventos. O padrão deve ser definido e documentado no início — logger injetado via `infra/logger.ts`, sem acoplamento ao framework HTTP. Em projeto anterior do grupo esse ponto virou bloqueio justamente por ter sido adiado até a implementação dos workers.

#### Registro de decisões (ADR)

Cada decisão arquitetural relevante é registrada como ADR numerado em `docs/adr/`, contendo o contexto, a decisão tomada e **o que foi recusado, com a razão**. Decisões já tomadas que merecem ADR: sessão opaca em Redis em vez de JWT; score determinístico em vez de modelo probabilístico; cota com devolução; anonimização em vez de exclusão total; Express em vez de Nest; FastAPI em vez de Django; outbox no fluxo de pagamento; casos de uso restritos a domínios pesados.

Esse artefato atende diretamente à disciplina de Governança em TI e responde à pergunta de banca sobre por que o sistema foi construído de determinada forma.

Cada repositório mantém ainda um `CONTEXT.md` com o estado atual, as decisões vigentes e o próximo passo — em trabalho de grupo, é o que evita retrabalho por desinformação.

### 6.5 Serviço de IA

**Framework:** **FastAPI** com Uvicorn e Pydantic.
_Justificativa:_ o serviço é uma API interna sem interface, sem usuários próprios e sem banco próprio. Django foi avaliado e dispensado — ORM, painel administrativo, sistema de autenticação e templates não seriam utilizados. FastAPI é assíncrono por natureza (relevante para inferência), gera OpenAPI automaticamente e é o padrão da documentação do ecossistema de IA.

**Diretrizes já definidas, independentes da função final da IA:**

- Autenticação entre serviços por **chave compartilhada** em variável de ambiente, validada em cada requisição.
- Operações demoradas são **enfileiradas pelo back-end** (BullMQ) e processadas em segundo plano, com notificação ao término — nunca executadas de forma síncrona no ciclo da requisição do usuário.
- Sujeito integralmente ao RNF11.

> **Pendência.** A função da IA no produto ainda não foi definida pelo grupo. O motor de matchmaking do RF03 é **determinístico por decisão de projeto**, o que preserva a explicabilidade exigida por V&V. Consequentemente, a IA deve ocupar uma **camada auxiliar** — candidatos: assistente de preenchimento do Canvas, resumo automatizado de pitch para o investidor, extração de tese a partir de texto livre para alimentar o score. Caso nenhuma função se justifique, o repositório deve ser descartado; três repositórios com um sem propósito definido é dívida, não arquitetura.

### 6.6 Infraestrutura

| Componente                          | Escolha                           |
| ----------------------------------- | --------------------------------- |
| Banco de dados                      | PostgreSQL                        |
| Cache, sessão e fila                | Redis                             |
| Hospedagem do front                 | Vercel                            |
| Hospedagem do back (três processos) | Render                            |
| Ambiente local                      | Docker e Docker Compose           |
| Repositórios                        | GitHub (públicos — ver seção 9.6) |

---

## 7. Ambiente de desenvolvimento

### 7.1 Docker Compose por repositório

Cada repositório possui seu próprio `docker-compose.yml`, mas com uma divisão deliberada de responsabilidade:

- **`BackEnd-Last-PI`** sobe a aplicação, o **PostgreSQL** e o **Redis**.
- **`IA-Last-PI`** sobe apenas o serviço de IA, apontando para a rede do back-end.
- **`FrontEnd-Last-PI`** sobe apenas o front-end.

**Ordem de subida:** o back-end primeiro.

_Justificativa:_ se cada repositório subisse o próprio banco, haveria conflito de porta ao rodar dois ao mesmo tempo e, pior, bases desconectadas entre si. Com um único PostgreSQL e um único Redis, o ambiente local reflete a produção — e o serviço de IA, que não possui banco próprio, obtém dados pelo back-end, conforme o contrato definido na seção 6.1.

### 7.2 Variáveis de ambiente

Os três repositórios mantêm um **`.env.example` completo e atualizado**, contendo todas as variáveis necessárias para executar o serviço, com valores de exemplo e sem qualquer segredo real.

**Regra de processo:** variável nova introduzida no código entra no `.env.example` no mesmo pull request. Um `.env.example` incompleto é dívida silenciosa — o próximo integrante não consegue subir o projeto e depende de perguntar ao autor.

### 7.3 Critério de verificação

Conforme o RNF09: um integrante que não escreveu determinado serviço deve conseguir executá-lo seguindo apenas o `README.md` do repositório, sem assistência.

---

## 8. Decisões técnicas e armadilhas conhecidas

> Esta seção registra decisões que, se descobertas tardiamente, custam dias de trabalho. Todas devem ser tratadas nas primeiras semanas de desenvolvimento.

### 8.1 Cookie entre domínios diferentes

Com o front-end na Vercel e o back-end no Render, os domínios são distintos. O navegador trata a comunicação como requisição entre sites diferentes e, com `SameSite=Lax`, **não envia o cookie de sessão**.

**Correção obrigatória:**

- Cookie de sessão com **`SameSite=None`**, que autoriza o envio entre sites diferentes, e obrigatoriamente **`Secure`**, que exige HTTPS.
- CORS configurado no back-end aceitando a **origem explícita** do front-end e **permitindo credenciais**.

**Por que isso está registrado aqui:** nada disso é difícil. O problema é o sintoma — o login parece funcionar e a requisição seguinte retorna "não autenticado". A falha se disfarça de bug de autenticação, e o grupo pode perder horas investigando o lugar errado. **Isso deve ser validado na primeira semana de desenvolvimento, não na integração final.**

_Alternativa avaliada:_ servir front e back sob o mesmo domínio, com o back em subcaminho via proxy, elimina o problema por completo — ao custo de mais configuração de infraestrutura. Descartada em favor da configuração de cookie.

### 8.2 Hibernação do Render no plano gratuito

O plano gratuito do Render suspende o serviço após período sem tráfego. A primeira requisição subsequente pode levar dezenas de segundos.

**Consequências e tratamento:**

- O RNF01 **não é comprovável** com o serviço hibernado — o teste de carga roda com o ambiente previamente aquecido.
- **Solução adotada:** aquecer o serviço acessando o sistema alguns minutos antes de qualquer apresentação ou demonstração.
- Alternativa disponível caso necessário: plano pago no mês da entrega.

### 8.3 Front-end consome o back-end diretamente

**Decisão:** as rotas de API do Next.js **não são utilizadas** como intermediário para o back-end.

**Justificativa:** o projeto possui back-end próprio. Uma camada extra de servidor duplicaria o lugar onde investigar falhas — diante de um erro, seria necessário verificar tanto o Next quanto o back-end. A decisão também reforça o RNF09, que exige desacoplamento com comunicação por API REST documentada.

### 8.4 Pagamento: padrão outbox

**O problema.** Ao receber a confirmação de pagamento, o sistema precisa gravar o fato no PostgreSQL e enfileirar o trabalho decorrente (liberar plano, notificar usuário) no Redis. **Não existe transação que abranja os dois.** Se a gravação no banco tiver sucesso e o enfileiramento falhar, o pagamento consta como confirmado e ninguém libera o plano — falha silenciosa, com o gateway tendo recebido resposta de sucesso.

**A solução adotada.** Na mesma transação do banco, grava-se o evento e uma linha de trabalho pendente (`enfileirado_em IS NULL`). O processo _dispatcher_ varre essa tabela, reserva as linhas com `FOR UPDATE ... SKIP LOCKED` — o que permite múltiplas instâncias sem coordenação — enfileira no BullMQ e marca como enfileirado. Se o Redis estiver indisponível, o trabalho permanece registrado no banco e é retomado depois.

**Escopo:** apenas o fluxo de pagamento. Aplicar o padrão a todo o sistema seria overhead sem retorno.

**Defesas de idempotência, conscientemente redundantes:**

1. Restrição de unicidade no ID do evento do gateway, com `ON CONFLICT DO NOTHING`.
2. `jobId` do BullMQ derivado do identificador do trabalho — job com ID repetido é descartado pela fila.
3. Verificação de estado antes de aplicar o efeito (plano já liberado não é liberado novamente).

### 8.5 Recomendações de execução do módulo de pagamento

**Confirmar o modelo de recorrência da AbacatePay antes de implementar.** O ambiente sandbox está confirmado, mas o comportamento da assinatura precisa ser verificado: se a recorrência gerar cobrança mensal que o usuário precisa pagar novamente — em vez de débito automático — o comportamento do sistema muda, passando a exigir lembrete e janela de tolerância em lugar de tratamento de falha de cobrança.

**Confirmar a política de reenvio de webhook do gateway.** Com o outbox, o reenvio deixa de ser a rede de segurança principal, mas continua relevante para o caso em que o endpoint estiver indisponível no primeiro envio — situação em que nenhuma transação local existe para proteger o fato.

**Confirmar que a API da AbacatePay permite consultar cobranças.** A reconciliação periódica (ADR 0035) cobre o webhook que nunca chegou — servidor fora do ar, hibernação do Render (8.2) — e depende dessa consulta. Sem ela, o reenvio do gateway volta a ser a única defesa nesse caso.

**Máquina de estados no papel antes do código.** A tabela de transições do RF17 é a referência; nenhuma transição fora dela é válida. O diagrama resultante serve simultaneamente como artefato da documentação de governança e como base dos casos de teste de V&V — o mesmo trabalho atende duas disciplinas.

**Nenhum dado de cartão trafega ou é armazenado pelo sistema.** O checkout ocorre em ambiente do gateway; a plataforma recebe apenas a confirmação via webhook. É o que dispensa a necessidade de conformidade PCI-DSS própria.

### 8.6 Documentação OpenAPI como contrato

Com Kubb gerando o cliente do front a partir do OpenAPI, a especificação deixa de ser documentação e passa a ser **contrato executável**. Como a especificação é escrita manualmente (Express), ela pode divergir do código.

**Regra de processo:** endpoint, DTO e especificação OpenAPI são alterados **no mesmo pull request**, e a verificação entra no checklist de revisão.

_Precedente registrado:_ documentação desatualizada é pior que documentação ausente, porque induz confiança falsa. Em projeto anterior do grupo, o arquivo de contexto declarava 68 testes onde existiam 170, afirmava a existência de testes de modularidade inexistentes e listava JWT onde a implementação usava sessão. **A geração de cliente a partir de especificação inconsistente produz código errado com aparência de correto.**

_Recomendação de cronograma:_ implantar o Kubb apenas quando os primeiros endpoints estabilizarem — não na primeira semana, com a API ainda em mudança constante.

---

## 9. Processo de desenvolvimento, integração contínua e qualidade

### 9.1 Fluxo de branches

O mesmo fluxo vale para os **três repositórios**, sem variação:

| Branch           | Papel                                            |
| ---------------- | ------------------------------------------------ |
| `main`           | Código em produção                               |
| `release`        | Candidata a produção, em validação               |
| `dev`            | Integração do trabalho do grupo                  |
| `feature/<nome>` | Uma por funcionalidade, criada a partir da `dev` |

**Caminho do código:** `feature/<nome>` → `dev` → `release` → `main`.

**Regras de merge:**

- Pull requests para a `dev` são revisados e aprovados pelo responsável técnico do projeto.
- Merge para `release` e `main` é restrito ao responsável técnico.
- Nenhum push direto é permitido em `main`, `release` ou `dev`.

_Nota de implementação:_ o GitHub não restringe quem **abre** um pull request; a restrição efetiva é sobre quem pode **concluir o merge**, configurada na regra de proteção da branch.

### 9.2 Sincronia entre repositórios

Uma funcionalidade que altera o contrato da API afeta back-end e front-end em pull requests separados, sem possibilidade de merge atômico entre repositórios.

**Regra:** o back-end é integrado primeiro, com a especificação OpenAPI atualizada no mesmo pull request; o front-end vem em seguida, regenerando o cliente. A ordem inversa quebra a `dev` do front-end.

### 9.3 Pipelines

**Três pipelines, um por repositório**, em GitHub Actions, disparados em pull request direcionado à `dev` e à `release`, e em push nessas branches.

Os pipelines do front-end e do back-end compartilham as ferramentas (ESLint, TypeScript, Vitest). O pipeline do serviço de IA usa o ecossistema Python — ruff, mypy e pytest. **O conceito de portão de qualidade é o mesmo nos três; as ferramentas não.**

**Estrutura comum do workflow:**

- `concurrency` com `cancel-in-progress` por branch — cancela execuções obsoletas e economiza cota de runner.
- `permissions: contents: read` — menor privilégio para o token do workflow.
- **`fetch-depth: 0`** no checkout — obrigatório: sem histórico completo, o `git diff` contra a base não encontra o ancestral comum e a cobertura do diff falha.
- **`timeout-minutes`** no nível do job — o padrão do GitHub é 6 horas; um travamento consumiria a cota inteira.
- Serviços PostgreSQL e Redis no runner, com health check — é o que viabiliza os testes de integração exigidos pelo RNF07.
- Segredos via GitHub Secrets, nunca versionados.
- Upload do relatório de cobertura como artefato com **`if: always()`** — o relatório interessa justamente quando o portão barra.

### 9.4 Portão de qualidade

Script próprio executado no CI, que coleta todas as métricas antes de decidir (sem curto-circuito), permitindo ver todos os problemas de uma vez.

**Verificações:**

| #   | Verificação                                  | Reprova quando                                      |
| --- | -------------------------------------------- | --------------------------------------------------- |
| 1   | Lint                                         | Qualquer erro ou warning                            |
| 2   | Vulnerabilidades em dependências de produção | Severidade crítica sempre; demais conforme baseline |
| 3   | Verificação de tipos                         | Qualquer erro                                       |
| 4   | Ocorrências de `any`                         | Acima do baseline                                   |
| 5   | Ocorrências de `as any`                      | Acima do baseline                                   |
| 6   | Ocorrências de supressão de tipo             | Acima do baseline                                   |
| 7   | Cobertura das linhas novas                   | Abaixo do mínimo definido                           |

**Modelo de catraca.** As métricas são comparadas contra um baseline congelado: estritamente maior reprova, igual passa. Vulnerabilidade crítica é bloqueio absoluto, sem entrada no baseline — não existe número a afrouxar.

**Cobertura medida sobre o diff, não sobre o projeto.** Apenas as linhas adicionadas em relação à base entram no cálculo. Congelar percentual global faria pull requests serem barrados por diluição, o que pune contribuição legítima.

### 9.5 Correções obrigatórias em relação à implementação de referência

Duas falhas identificadas na versão anterior do portão devem nascer corrigidas neste projeto:

**1. O portão deve falhar fechado.** Na implementação de referência, o código de saída das ferramentas invocadas não era verificado, e saída vazia era interpretada como ausência de problemas. Consequência: ferramenta que quebra torna-se indistinguível de ferramenta que nada encontrou — uma falha de rede na auditoria de dependências faria a verificação de vulnerabilidade crítica desaparecer sem qualquer sinal vermelho. Em projeto individual isso é percebido; em grupo com prazo, não. **É obrigatório verificar o código de saída e distinguir "executou e encontrou zero" de "não executou".**

**2. Cobertura por branch nos fluxos críticos.** A medição por statement aprova um `if` novo tendo exercitado apenas um dos ramos. Como os cinco fluxos críticos deste produto são majoritariamente caminhos de erro, essa medição é insuficiente (ver RNF07).

**Limitações remanescentes, conscientemente aceitas:**

- O portão não detecta testes marcados para pular ou executar isoladamente. Fica valendo a regra de processo: teste que falha se conserta, não se pula nem se remove.
- As verificações textuais de `any` são baseadas em expressão regular, sem parser — podem gerar falso positivo em string ou comentário.
- O baseline é editável por quem está sendo medido. **Neste projeto, a revisão obrigatória de pull request é o que resolve o problema:** alterar o baseline torna-se mudança visível que outro integrante precisa aprovar. É o que transforma o portão de lembrete em barreira.

### 9.6 Proteção de branch

Executar o portão e falhar **não impede merge por si só**. O bloqueio efetivo exige configurar o job como _required status check_ na proteção de cada branch.

**Consequência prática:** no plano gratuito do GitHub, proteção de branch e rulesets não estão disponíveis para repositórios privados. Como o projeto é acadêmico e comporá o portfólio dos integrantes, **os três repositórios devem ser públicos**, o que habilita a proteção sem custo e exige apenas a disciplina de gestão de segredos já prevista no RNF06.

**Configuração necessária em `main`, `release` e `dev`, nos três repositórios:**

- _Require status checks to pass before merging_, selecionando o job pelo identificador.
- _Require branches to be up to date before merging_ — sem isso, um pull request aprovado pode ser mesclado sobre uma branch que mudou depois.
- _Require pull request reviews_ — atende ao RNF06 e sustenta a integridade do baseline.
- _Restrict who can push_ em `release` e `main`, limitado ao responsável técnico.

### 9.7 Padrão de commits e hooks locais

- _Conventional commits_, validados por commitlint no hook `commit-msg`.
- Verificação de tipos no hook `pre-commit`, para falhar antes de subir.
- Os hooks locais são conveniência, não garantia: podem ser ignorados. A garantia é o CI.

## 10. Matriz de rastreabilidade

> Formato herdado da versão anterior do documento, expandido para cobrir as decisões acrescentadas.

| Achado (insight humano / de negócio)                                             | RF impactado                 | RNF impactado | O que muda na arquitetura / código                                                                                                                                           |
| -------------------------------------------------------------------------------- | ---------------------------- | ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Investidores não têm tempo de ler materiais longos e sem padrão                  | RF06                         | RNF04         | Formulário guiado em etapas no front-end, gerando visualização padronizada do Canvas                                                                                         |
| Startups temem expor ideias e números estratégicos                               | RF04, RF07, RF13             | RNF02, RNF03  | Níveis de visibilidade no banco: perfil público (resumo e setor) versus dados protegidos acessíveis apenas mediante autorização expressa, com revogação e registro de acesso |
| Falta de alinhamento entre valor pedido e capital disponível                     | RF03                         | RNF05         | Algoritmo determinístico de pontuação no back-end considerando ticket × segmento × estágio × modelo, com exibição por limiar                                                 |
| Interações informais por WhatsApp perdem histórico e não geram dados             | RF05, RF09                   | RNF10         | Chat e agendamento internos, registrando interações e alimentando métricas anonimizadas no dashboard administrativo                                                          |
| Falta de confiança sobre a seriedade dos perfis                                  | RF08, RF10, RF16             | RNF07         | Fila de aprovação com critérios explícitos e justificativa registrada; verificação com selo; rating interno com visibilidade assimétrica                                     |
| Investidor é o lado escasso e sua atenção é o recurso disputado                  | RF05 (cota), RF15            | RNF05         | Cota de solicitações com débito no envio e devolução em recusa ou expiração; rotina agendada de expiração em 15 dias via fila                                                |
| A mesma pessoa frequentemente atua como mentor e investidor                      | RF02, RF07                   | RNF09         | Cadastro único com papéis acumuláveis; permissão calculada dinamicamente a partir dos papéis ativos, não copiada na sessão                                                   |
| O produto precisa de modelo de receita, mas não pode intermediar investimento    | RF17                         | RNF02         | Assinatura recorrente com checkout externo ao sistema; liberação exclusivamente por confirmação do gateway, idempotente; nenhum dado de cartão trafega pela aplicação        |
| Decisões de moderação e acessos precisam ser justificáveis a posteriori          | RF08, RF13                   | RNF10         | Log somente escrita, tela de auditoria de leitura no painel administrativo, retenção definida em 12 meses                                                                    |
| Titulares precisam poder sair da plataforma sem quebrar o histórico de terceiros | RF14                         | RNF03         | Exclusão por anonimização: dados pessoais removidos, registros de interação preservados sem identificação                                                                    |
| Contas administrativas concentram poder sobre dados de todos                     | RF07                         | RNF02         | MFA por TOTP obrigatório para administrador, com códigos de recuperação; tipo de conta separado e não acumulável                                                             |
| Usuários não retornam à plataforma sem estímulo externo                          | RF12                         | RNF01         | Notificação in-app e e-mail transacional processado em fila assíncrona, fora do ciclo da requisição                                                                          |
| O serviço de IA é um ponto único de falha externo ao núcleo do produto           | —                            | RNF11         | Timeout definido nas chamadas e degradação graciosa; matchmaking determinístico permanece funcional com a IA indisponível                                                    |
| Confirmação de pagamento pode se perder entre banco e fila                       | RF17                         | RNF07, RNF10  | Padrão outbox no fluxo de pagamento: evento e trabalho pendente gravados na mesma transação; dispatcher com SKIP LOCKED enfileira depois                                     |
| Regra de negócio densa concentrada em poucos domínios                            | RF03, RF05, RF08, RF13, RF17 | RNF07, RNF09  | Casos de uso por operação nos domínios pesados; service simples nos demais; repositório como única camada que conhece o ORM                                                  |
| Trabalho de grupo exige integração sem quebrar o que já funciona                 | —                            | RNF06, RNF07  | Fluxo main/release/dev com feature branches, proteção nas três branches dos três repositórios e portão de qualidade como status check obrigatório                            |

---

## 11. Pendências e próximos passos

| #   | Pendência                                                                                                                                                 | Responsável / prazo sugerido               |
| --- | --------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------ |
| 1   | Definir a função da IA no produto (camada auxiliar) ou descartar o repositório                                                                            | Grupo — antes do início do desenvolvimento |
| 2   | Confirmar na documentação da AbacatePay o modelo exato de recorrência, a política de reenvio de webhook e se a API permite consultar cobranças (ADR 0035) | Antes de implementar o RF17                |
| 3   | Ambiente sandbox da AbacatePay confirmado e disponível                                                                                                    | Concluído                                  |
| 4   | Definir o padrão de logging antes da implementação dos workers                                                                                            | Primeira semana                            |
| 5   | Validar o fluxo de cookie entre domínios (7.1)                                                                                                            | Primeira semana                            |
| 6   | Tornar os três repositórios públicos e configurar proteção de `main`, `release` e `dev`                                                                   | Primeira semana                            |
| 7   | Definir os pesos exatos do score de afinidade (RF03)                                                                                                      | Antes de implementar o motor               |
| 8   | Definir os valores das cotas, dos limites e o preço dos nove planos, incluindo o que diferencia `PRO` de `PREMIUM` (ADR 0028)                             | Junto ao plano de negócios                 |
| 9   | Realizar entrevistas de campo no Porto Digital para validar as personas                                                                                   | Antes da entrega final                     |
| 10  | Recrutar os 5 participantes do teste de usabilidade (RNF04)                                                                                               | Antes da entrega final                     |

---

| 11 | Registrar os ADRs das decisões já tomadas (seção 6.4) | Primeiras duas semanas |
| 12 | Definir os KPIs do cartão de afinidade, a tolerância de etapas no onboarding e os critérios de rating — dúvidas da matriz CSD | Rodada beta |
| 13 | Definir o prazo da janela de tolerância por inadimplência (sem esse número a transição não é testável) | Antes de implementar o RF17 |
| 14 | Decidir se o cancelamento é permitido durante `INADIMPLENTE_EM_TOLERANCIA` e qual o efeito | Antes de implementar o RF17 |

---

_Documento de requisitos e decisões de projeto — Projeto Integrador, 5º período de ADS. Refina e substitui as versões anteriores, incorporando o documento base da disciplina e o material de Design Thinking produzido pela equipe._
