# Tasks do MVP do Laços

## Objetivo

Este documento organiza as atividades de implementação do MVP do Laços em tarefas pequenas, objetivas e sequenciais, mantendo alinhamento com a Constitution, a Specification e o Plano de Implementação.

## Princípios de organização

- Priorizar apenas funcionalidades do MVP.
- Seguir a ordem de implementação definida no plano.
- Manter tarefas pequenas e com escopo bem delimitado.
- Garantir que cada tarefa tenha dependências claras e critérios de conclusão verificáveis.
- Marcar tarefas que podem ser executadas em paralelo.

---

## 1. Base e infraestrutura

### TASK-001 — Inicializar o projeto Flutter
- Descrição: criar a estrutura inicial do projeto Flutter com suporte para Android, iOS e Web, incluindo organização de pastas e configuração básica do ambiente.
- Dependências: nenhuma.
- Critérios de conclusão:
  - o projeto abre corretamente localmente;
  - a estrutura de pastas inicial está criada;
  - o ambiente executa uma tela inicial padrão.
- Paralelo: Sim. Pode ser executada em paralelo com TASK-002.

### TASK-002 — Configurar integrações com Firebase
- Descrição: configurar o Firebase Authentication e o Cloud Firestore, preparando a infraestrutura inicial do backend para autenticação e armazenamento de dados do sistema.
- Dependências: TASK-001.
Critérios de conclusão:
- o projeto está conectado ao Firebase;
- Firebase Authentication e Cloud Firestore estão configurados e funcionando;
- a aplicação consegue inicializar sem erros de configuração.
- Paralelo: Sim. Pode ser executada em paralelo com TASK-003.

### TASK-003 — Definir tema, rotas e componentes base
- Descrição: criar o tema visual da aplicação, as rotas principais e os componentes reutilizáveis de interface.
- Dependências: TASK-001.
- Critérios de conclusão:
  - existe um tema consistente para mobile e web;
  - as rotas principais estão definidas;
  - componentes básicos como botões, campos e cards já estão disponíveis.
- Paralelo: Sim. Pode ser executada em paralelo com TASK-002.

---

## 2. Autenticação

### TASK-004 — Implementar fluxo de cadastro de usuários
- Descrição: criar a tela e a lógica de cadastro para idosos e familiares, incluindo validação de dados básicos.
- Dependências: TASK-002, TASK-003.
- Critérios de conclusão:
  - o usuário consegue criar conta como idoso ou familiar;
  - os dados obrigatórios são validados;
  - o cadastro cria um registro inicial no sistema.
- Paralelo: Não.

### TASK-005 — Implementar login e recuperação de senha
- Descrição: criar o fluxo de login com e-mail e senha e a recuperação de senha por e-mail.
- Dependências: TASK-004.
- Critérios de conclusão:
  - o usuário consegue entrar na aplicação com credenciais válidas;
  - o fluxo de recuperação de senha envia o e-mail correto;
  - erros de autenticação são exibidos de forma clara.
- Paralelo: Não.

### TASK-006 — Implementar gerenciamento de sessão
- Descrição: manter o estado de autenticação do usuário e direcionar corretamente entre telas autenticadas e públicas.
- Dependências: TASK-005.
- Critérios de conclusão:
  - o usuário permanece autenticado ao reiniciar a aplicação;
  - a navegação respeita o estado de sessão;
  - logout funciona corretamente.
- Paralelo: Não.

---

## 3. Perfil

### TASK-007 — Criar e editar perfil do usuário
- Descrição: implementar a tela de perfil com campos básicos e a possibilidade de edição após o cadastro.
- Dependências: TASK-006.
- Critérios de conclusão:
  - o usuário consegue visualizar e editar seu perfil;
  - os dados são salvos corretamente no Firestore;
  - a interface mostra feedback de sucesso ou erro.
- Paralelo: Não.

### TASK-008 — Implementar interesses e privacidade do perfil
- Descrição: permitir o cadastro de interesses e definir regras básicas de visibilidade de informações públicas e privadas.
- Dependências: TASK-007.
- Critérios de conclusão:
  - interesses podem ser adicionados e editados;
  - as informações públicas e privadas são tratadas conforme as regras do MVP;
  - a idade é exibida como faixa etária em perfis públicos.
- Paralelo: Não.

---

## 4. Descoberta

### TASK-009 — Implementar busca de locais e atividades
- Descrição: criar a tela de descoberta com busca por categoria e localização, exibindo locais e atividades disponíveis.
- Dependências: TASK-003.
- Critérios de conclusão:
  - o usuário consegue pesquisar locais e atividades;
  - os resultados são exibidos com nome, categoria e descrição;
  - a busca funciona com filtros básicos.
- Paralelo: Sim. Pode ser executada em paralelo com TASK-010.

### TASK-010 — Implementar detalhes de local e atividade
- Descrição: criar a tela de detalhes com informações completas do local, como endereço, horário e descrição.
- Dependências: TASK-009.
- Critérios de conclusão:
  - o usuário consegue abrir os detalhes de um item encontrado;
  - as informações principais são apresentadas de forma clara;
  - a tela é responsiva para mobile e web.
- Paralelo: Sim. Pode ser executada em paralelo com TASK-009.

---

## 5. Amizades

### TASK-011 — Implementar sugestões de amizade por interesses
- Descrição: criar a lógica de sugestão de usuários com base em interesses em comum.
- Dependências: TASK-008.
- Critérios de conclusão:
  - o sistema apresenta sugestões relevantes para o usuário;
  - a sugestão usa os interesses cadastrados;
  - a lista é atualizada quando os dados mudam.
- Paralelo: Não.

### TASK-012 — Implementar envio de solicitações de amizade
- Descrição: permitir que um usuário envie solicitações de amizade para outros usuários.
- Dependências: TASK-011.
- Critérios de conclusão:
  - a solicitação é enviada corretamente;
  - o destinatário recebe a solicitação no fluxo apropriado;
  - o sistema impede envio duplicado inadequado.
- Paralelo: Não.

### TASK-013 — Implementar aceite, recusa e limite anti-spam
- Descrição: criar o fluxo de resposta a solicitações e aplicar o limite de 20 solicitações por período com janela de 24 horas.
- Dependências: TASK-012.
- Critérios de conclusão:
  - solicitações podem ser aceitas ou recusadas;
  - o estado da amizade é atualizado corretamente;
  - o limite anti-spam bloqueia novos envios quando atingido.
- Paralelo: Não.

---

## 6. Chat

### TASK-014 — Implementar chat privado entre amigos confirmados
- Descrição: criar a estrutura inicial do chat privado e permitir que amigos confirmados troquem mensagens.
- Dependências: TASK-013.
- Critérios de conclusão:
  - apenas amigos confirmados conseguem acessar o chat privado;
  - mensagens são enviadas e exibidas corretamente;
  - o histórico é armazenado no Firestore.
- Paralelo: Não.

### TASK-015 — Implementar seleção de avatares para o perfil
- Descrição: disponibilizar um conjunto de avatares pré-definidos para que o usuário escolha uma imagem de perfil durante o cadastro ou posteriormente na edição do perfil, utilizando assets locais do Flutter.
Dependências: TASK-007, TASK-008.
- Critérios de conclusão:
  - o usuário consegue selecionar um avatar entre as opções disponíveis;
  - o avatar escolhido é salvo corretamente no Cloud Firestore;
  - o avatar é exibido corretamente no perfil e nas demais telas da aplicação.
- Paralelo: Não.

---

## 7. Grupos

### TASK-016 — Implementar criação e participação em grupos
- Descrição: permitir que usuários criem grupos de interesse e participem de grupos existentes.
- Dependências: TASK-014.
- Critérios de conclusão:
  - grupos podem ser criados com nome, descrição e categoria;
  - usuários conseguem entrar em grupos disponíveis;
  - membros são registrados corretamente.
- Paralelo: Não.

### TASK-017 — Implementar mensagens internas de grupos
- Descrição: criar o fluxo de mensagens dentro dos grupos e exibir atualizações relevantes.
- Dependências: TASK-016.
- Critérios de conclusão:
  - mensagens de grupo são enviadas e armazenadas;
  - membros conseguem visualizar as mensagens recentes;
  - notificações de atualização do grupo são disparadas quando necessário.
- Paralelo: Não.

---

## 8. Acompanhamento familiar

### TASK-018 — Implementar solicitação e aprovação de vínculo familiar
- Descrição: criar o fluxo de solicitação de vínculo entre familiar e idoso, incluindo aprovação ou recusa pelo idoso.
- Dependências: TASK-008.
- Critérios de conclusão:
  - o familiar consegue solicitar vínculo;
  - o idoso consegue aceitar ou recusar a solicitação;
  - o vínculo é criado apenas após aprovação explícita.
- Paralelo: Não.

### TASK-019 — Implementar permissões e acesso restrito para familiares
- Descrição: controlar quais informações e funcionalidades estão disponíveis para o perfil de familiar.
- Dependências: TASK-018.
- Critérios de conclusão:
  - o familiar visualiza apenas os dados permitidos;
  - o idoso mantém controle sobre as informações acessíveis;
  - o familiar não consegue editar ou executar ações restritas.
- Paralelo: Não.

### TASK-020 — Implementar logs de auditoria para ações do familiar
- Descrição: registrar ações relevantes do familiar, como visualização de informações autorizadas, alterações de configurações e marcação de alertas.
- Dependências: TASK-019.
- Critérios de conclusão:
  - ações relevantes são registradas com data, usuário e contexto;
  - o histórico de auditoria é persistido corretamente;
  - o sistema mantém rastreabilidade para conformidade.
- Paralelo: Não.

---

## 9. Notificações e ajuda

### TASK-021 — Implementar notificações básicas de eventos relevantes
- Descrição: enviar notificações para eventos importantes, como amizade, mensagens, grupos e vínculo familiar.
- Dependências: TASK-012, TASK-014, TASK-016, TASK-018.
- Critérios de conclusão:
  - notificações são disparadas para eventos relevantes;
  - mensagens de notificação são claras e objetivas;
  - eventos irrelevantes não geram excesso de alertas.
- Paralelo: Não.

### TASK-022 — Implementar central de ajuda
- Descrição: disponibilizar orientações básicas de uso e informações relevantes para o usuário sem oferecer canal de suporte.
- Dependências: TASK-003.
- Critérios de conclusão:
  - a central de ajuda está acessível no fluxo principal;
  - o conteúdo apresenta orientações claras;
  - não há canal de suporte ativo na interface.
- Paralelo: Sim. Pode ser executada em paralelo com TASK-021.

---

## 10. Qualidade e validação

### TASK-023 — Criar testes unitários e de widgets
- Descrição: implementar testes para regras de negócio, validações e fluxos principais de interface.
- Dependências: TASK-004, TASK-007, TASK-013, TASK-014, TASK-016, TASK-018.
- Critérios de conclusão:
  - os testes cobrem os fluxos críticos do MVP;
  - os cenários principais passam sem falhas;
  - regressões são detectadas antes da entrega.
- Paralelo: Não.

### TASK-024 — Validar acessibilidade e compatibilidade mobile/web
- Descrição: revisar a interface para garantir acessibilidade, responsividade e compatibilidade entre plataformas.
- Dependências: TASK-023.
- Critérios de conclusão:
  - a aplicação atende aos requisitos básicos de acessibilidade;
  - a experiência é consistente em mobile e web;
  - os problemas críticos de usabilidade foram corrigidos.
- Paralelo: Não.

