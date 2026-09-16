# Tasks do MVP do Laços

## Objetivo

Este documento organiza as atividades de implementação do MVP do Laços em tarefas pequenas, objetivas e sequenciais, mantendo alinhamento com a Constitution, a Specification e o Plano de Implementação.

## Princípios de organização

* Priorizar apenas funcionalidades do MVP.
* Seguir a ordem de implementação definida no plano.
* Manter tarefas pequenas e com escopo bem delimitado.
* Garantir que cada tarefa tenha dependências claras e critérios de conclusão verificáveis.
* Marcar tarefas que podem ser executadas em paralelo.
* Reutilizar estruturas e campos já existentes sempre que possível, evitando duplicação desnecessária de fluxos ou dados.

---

## 1. Base e infraestrutura

### TASK-001 — Inicializar o projeto Flutter

* **Descrição:** criar a estrutura inicial do projeto Flutter com suporte para Android, iOS e Web, incluindo organização de pastas e configuração básica do ambiente.
* **Dependências:** nenhuma.
* **Critérios de conclusão:**

  * O projeto abre corretamente localmente.
  * A estrutura de pastas inicial está criada.
  * O ambiente executa uma tela inicial padrão.
* **Paralelo:** Sim. Pode ser executada em paralelo com TASK-002.

### TASK-002 — Configurar integrações com Firebase

* **Descrição:** configurar o Firebase Authentication e o Cloud Firestore, preparando a infraestrutura inicial do backend para autenticação e armazenamento de dados do sistema.
* **Dependências:** TASK-001.
* **Critérios de conclusão:**

  * O projeto está conectado ao Firebase.
  * Firebase Authentication e Cloud Firestore estão configurados e funcionando.
  * A aplicação consegue inicializar sem erros de configuração.
* **Paralelo:** Sim. Pode ser executada em paralelo com TASK-003.

### TASK-003 — Definir tema, rotas e componentes base

* **Descrição:** criar o tema visual da aplicação, as rotas principais e os componentes reutilizáveis de interface.
* **Dependências:** TASK-001.
* **Critérios de conclusão:**

  * Existe um tema consistente para mobile e web.
  * As rotas principais estão definidas.
  * Componentes básicos como botões, campos e cards estão disponíveis.
* **Paralelo:** Sim. Pode ser executada em paralelo com TASK-002.

---

## 2. Autenticação

### TASK-004 — Implementar fluxo de cadastro de usuários

* **Descrição:** criar a tela e a lógica de cadastro para idosos e familiares, incluindo validação de dados básicos.
* **Dependências:** TASK-002, TASK-003.
* **Critérios de conclusão:**

  * O usuário consegue criar conta como idoso ou familiar.
  * Os dados obrigatórios são validados.
  * O cadastro cria um registro inicial no sistema.
* **Paralelo:** Não.

### TASK-005 — Implementar login e recuperação de senha

* **Descrição:** criar o fluxo de login com e-mail e senha e a recuperação de senha por e-mail.
* **Dependências:** TASK-004.
* **Critérios de conclusão:**

  * O usuário consegue entrar na aplicação com credenciais válidas.
  * O fluxo de recuperação de senha envia o e-mail correto.
  * Erros de autenticação são exibidos de forma clara.
* **Paralelo:** Não.

### TASK-006 — Implementar gerenciamento de sessão

* **Descrição:** manter o estado de autenticação do usuário e direcionar corretamente entre telas autenticadas e públicas.
* **Dependências:** TASK-005.
* **Critérios de conclusão:**

  * O usuário permanece autenticado ao reiniciar a aplicação.
  * A navegação respeita o estado de sessão.
  * Logout funciona corretamente.
* **Paralelo:** Não.

---

## 3. Perfil

### TASK-007 — Criar e editar perfil do usuário

* **Descrição:** implementar a tela de perfil com campos básicos e a possibilidade de edição após o cadastro.
* **Dependências:** TASK-006.
* **Critérios de conclusão:**

  * O usuário consegue visualizar e editar seu perfil.
  * Os dados são salvos corretamente no Firestore.
  * A interface mostra feedback de sucesso ou erro.
* **Paralelo:** Não.

### TASK-008 — Implementar interesses e privacidade do perfil

* **Descrição:** permitir o cadastro de interesses e definir regras básicas de visibilidade de informações públicas e privadas.
* **Dependências:** TASK-007.
* **Critérios de conclusão:**

  * Interesses podem ser adicionados e editados.
  * As informações públicas e privadas são tratadas conforme as regras do MVP.
  * A idade é exibida como faixa etária em perfis públicos e para familiares.
* **Paralelo:** Não.

---

## 4. Descoberta

### TASK-009 — Implementar busca de locais e atividades

* **Descrição:** criar a tela de descoberta com busca por categoria e localização, exibindo locais e atividades disponíveis obtidos por meio de uma API externa.
* **Dependências:** TASK-003.
* **Critérios de conclusão:**

  * O usuário consegue pesquisar locais e atividades.
  * Os resultados são obtidos por meio de uma API externa.
  * Os resultados exibem nome, categoria e descrição quando disponível.
  * A busca funciona com filtros básicos.
* **Paralelo:** Sim. Pode ser executada em paralelo com TASK-010.

### TASK-010 — Implementar detalhes de local e atividade

* **Descrição:** criar a tela de detalhes utilizando as informações retornadas por uma API externa, exibindo endereço, horário de funcionamento, descrição, imagens, avaliações e demais informações disponíveis.
* **Dependências:** TASK-009.
* **Critérios de conclusão:**

  * O usuário consegue abrir os detalhes de um item encontrado.
  * As informações retornadas pela API externa são apresentadas de forma clara.
  * A tela é responsiva para mobile e web.
* **Paralelo:** Sim. Pode ser executada em paralelo com TASK-009.

---

## 5. Amizades

### TASK-011 — Implementar sugestões de amizade por interesses

* **Descrição:** criar a lógica de sugestão de usuários com base em interesses em comum.
* **Dependências:** TASK-008.
* **Critérios de conclusão:**

  * O sistema apresenta sugestões relevantes para o usuário.
  * A sugestão usa os interesses cadastrados.
  * A lista é atualizada quando os dados mudam.
* **Paralelo:** Não.

### TASK-012 — Implementar envio de solicitações de amizade

* **Descrição:** permitir que um usuário envie solicitações de amizade para outros usuários.
* **Dependências:** TASK-011.
* **Critérios de conclusão:**

  * A solicitação é enviada corretamente.
  * O destinatário recebe a solicitação no fluxo apropriado.
  * O sistema impede envio duplicado inadequado.
* **Paralelo:** Não.

### TASK-013 — Implementar aceite, recusa e limite anti-spam

* **Descrição:** criar o fluxo de resposta a solicitações e aplicar o limite de 20 solicitações por período com janela de 24 horas.
* **Dependências:** TASK-012.
* **Critérios de conclusão:**

  * Solicitações podem ser aceitas ou recusadas.
  * O estado da amizade é atualizado corretamente.
  * O limite anti-spam bloqueia novos envios quando atingido.
* **Paralelo:** Não.

---

## 6. Chat

### TASK-014 — Implementar chat privado entre amigos confirmados

* **Descrição:** criar a estrutura inicial do chat privado e permitir que amigos confirmados troquem mensagens.
* **Dependências:** TASK-013.
* **Critérios de conclusão:**

  * Apenas amigos confirmados conseguem acessar o chat privado.
  * Mensagens são enviadas e exibidas corretamente.
  * O histórico é armazenado no Firestore.
* **Paralelo:** Não.

### TASK-015 — Implementar seleção de avatares para o perfil

* **Descrição:** disponibilizar um conjunto de avatares pré-definidos para que o usuário escolha uma imagem de perfil durante o cadastro ou posteriormente na edição do perfil, utilizando assets locais do Flutter.
* **Dependências:** TASK-007, TASK-008.
* **Critérios de conclusão:**

  * O usuário consegue selecionar um avatar entre as opções disponíveis.
  * O avatar escolhido é salvo corretamente no Cloud Firestore.
  * O avatar é exibido corretamente no perfil e nas demais telas da aplicação.
* **Paralelo:** Não.

---

## 7. Grupos

### TASK-016 — Implementar criação e participação em grupos

* **Descrição:** permitir que usuários criem grupos de interesse e participem de grupos existentes.
* **Dependências:** TASK-014.
* **Critérios de conclusão:**

  * Grupos podem ser criados com nome, descrição e categoria.
  * Usuários conseguem entrar em grupos disponíveis.
  * Membros são registrados corretamente.
* **Paralelo:** Não.

### TASK-017 — Implementar mensagens internas de grupos

* **Descrição:** criar o fluxo de mensagens dentro dos grupos e exibir atualizações relevantes.
* **Dependências:** TASK-016.
* **Critérios de conclusão:**

  * Mensagens de grupo são enviadas e armazenadas.
  * Membros conseguem visualizar as mensagens recentes.
  * Notificações de atualização do grupo são disparadas quando necessário.
* **Paralelo:** Não.

---

## 8. Acompanhamento familiar e proteção contra golpes

### TASK-018 — Implementar notificação e controle do vínculo familiar

* **Descrição:** complementar o vínculo familiar já estabelecido por meio do `linkedElderEmail`, implementando a notificação ao idoso após o vínculo e permitindo que o idoso bloqueie o familiar quando não quiser mais a supervisão.
* **Dependências:** vínculo familiar existente via `linkedElderEmail`.
* **Critérios de conclusão:**

  * O idoso recebe uma notificação quando um familiar é vinculado à sua conta.
  * A notificação informa de forma clara que o familiar/responsável passou a supervisioná-lo.
  * O idoso consegue bloquear o familiar vinculado.
  * O bloqueio encerra imediatamente o acesso do familiar aos dados e funcionalidades de supervisão.
  * O sistema mantém as regras existentes de vínculo entre familiar e idoso.
* **Paralelo:** Não.

### TASK-019 — Implementar permissões e acesso restrito para familiares

* **Descrição:** controlar quais informações e funcionalidades estão disponíveis para o perfil de familiar enquanto o vínculo estiver ativo.
* **Dependências:** TASK-018.
* **Critérios de conclusão:**

  * O familiar visualiza apenas os dados permitidos pelo MVP.
  * O familiar consegue visualizar informações autorizadas do idoso, como nome, foto, faixa etária, localização em nível permitido, interesses, amizades, grupos e atividades confirmadas.
  * O familiar pode acessar conversas sinalizadas como suspeitas conforme as regras do MVP.
  * O familiar não consegue editar o perfil do idoso.
  * O familiar não consegue enviar mensagens, solicitações de amizade ou realizar ações sociais em nome do idoso.
  * O familiar não consegue alterar credenciais ou configurações restritas do idoso.
  * O acesso é encerrado quando o vínculo é removido ou bloqueado.
* **Paralelo:** Não.

### TASK-020 — Implementar logs de auditoria para ações do familiar

* **Descrição:** registrar ações relevantes realizadas pelo familiar durante o período de supervisão, garantindo rastreabilidade das ações permitidas pelo sistema.
* **Dependências:** TASK-019.
* **Critérios de conclusão:**

  * Ações relevantes são registradas com data, usuário e contexto.
  * O histórico de auditoria é persistido corretamente.
  * O sistema mantém rastreabilidade das ações realizadas pelo familiar.
  * O registro não permite que o familiar altere ou exclua seus próprios logs.
* **Paralelo:** Não.

### TASK-025 — Construir interface da tela de gerenciamento de mensagens do familiar

* **Descrição:** criar a estrutura visual e estática da tela "Gerenciar Mensagens" (`ManageMessagesScreen`), incluindo o painel de alertas com cards ilustrativos (links suspeitos, golpes de PIX, contatos confiáveis) e a seção de filtros com opções de bloqueio e chaves seletoras (switches).
* **Dependências:** TASK-003.
* **Critérios de conclusão:**

  * A tela é acessível a partir do menu/navegação do perfil do familiar.
  * O layout segue os padrões visuais e o tema do projeto.
  * Exibe a estrutura inicial de cards de alertas e opções de filtros.
* **Paralelo:** Sim.

### TASK-026 — Integração de IA para detecção automatizada de mensagens suspeitas

* **Descrição:** implementar a análise de texto das mensagens do chat via modelo de inteligência artificial/módulo de segurança para identificar padrões suspeitos em tempo real, como pedidos de PIX/dinheiro, links externos maliciosos, palavras-chave de golpes e falsificação de identidade.
* **Dependências:** TASK-014, TASK-025.
* **Critérios de conclusão:**

  * As mensagens enviadas no chat privado do idoso passam por verificação de risco.
  * Padrões de golpes e envio de links geram uma sinalização/alerta no Firestore.
  * As mensagens e contatos suspeitos alimentam dinamicamente a lista de alertas exibida na `ManageMessagesScreen`.
* **Paralelo:** Não.

### TASK-027 — Implementar ações de bloqueio e filtros de proteção do familiar

* **Descrição:** conectar as ações e opções da tela de gerenciamento de mensagens com a lógica do banco de dados e do chat do idoso.
* **Dependências:** TASK-025, TASK-026.
* **Critérios de conclusão:**

  * O familiar pode gerenciar e bloquear contatos suspeitos em nome do idoso.
  * A opção "Bloquear Links externos" impede a renderização ou o clique em URLs enviadas nas conversas do idoso.
  * A opção "Alertar novas chances de riscos" habilita/desabilita o envio de notificações de emergência para o familiar quando a IA detectar um novo risco.
  * O familiar pode verificar os detalhes da conversa sinalizada.
* **Paralelo:** Não.

---

## 9. Notificações e ajuda

### TASK-021 — Implementar notificações básicas de eventos relevantes

* **Descrição:** enviar notificações para eventos importantes, como solicitações e respostas de amizade, mensagens, grupos, alertas de segurança e estabelecimento ou encerramento de vínculo familiar.
* **Dependências:** TASK-012, TASK-014, TASK-016, TASK-018, TASK-027.
* **Critérios de conclusão:**

  * Notificações são disparadas para eventos relevantes.
  * O idoso recebe uma notificação quando um vínculo familiar é estabelecido.
  * O familiar recebe alertas em tempo real quando uma interação/mensagem suspeita é identificada pela IA.
  * Mensagens de notificação são claras e objetivas.
  * Eventos irrelevantes não geram excesso de alertas.
* **Paralelo:** Não.

### TASK-022 — Implementar central de ajuda

* **Descrição:** disponibilizar orientações básicas de uso e informações relevantes para o usuário sem oferecer canal de suporte.
* **Dependências:** TASK-003.
* **Critérios de conclusão:**

  * A central de ajuda está acessível no fluxo principal.
  * O conteúdo apresenta orientações claras.
  * Não há canal de suporte ativo na interface.
* **Paralelo:** Sim. Pode ser executada em paralelo com TASK-021.

---

## 10. Qualidade e validação

### TASK-023 — Criar testes unitários e de widgets

* **Descrição:** implementar testes para regras de negócio, validações e fluxos principais de interface.
* **Dependências:** TASK-004, TASK-007, TASK-013, TASK-014, TASK-016, TASK-018, TASK-026, TASK-027.
* **Critérios de conclusão:**

  * Os testes cobrem os fluxos críticos do MVP.
  * Os cenários principais passam sem falhas.
  * O fluxo de vínculo familiar automático é validado.
  * A validação de `linkedElderEmail` é testada.
  * A detecção de risco pela IA e os filtros de bloqueio do familiar são testados.
  * O bloqueio do vínculo familiar é testado.
  * Regressões são detectadas antes da entrega.
* **Paralelo:** Não.

### TASK-024 — Validar acessibilidade e compatibilidade mobile/web

* **Descrição:** revisar a interface para garantir acessibilidade, responsividade e compatibilidade entre plataformas.
* **Dependências:** TASK-023.
* **Critérios de conclusão:**

  * A aplicação atende aos requisitos básicos de acessibilidade.
  * A experiência é consistente em mobile e web.
  * Os problemas críticos de usabilidade foram corrigidos.
* **Paralelo:** Não.
