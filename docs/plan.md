# Plano de Implementação do MVP do Laços

## 1. Objetivo do plano

Este documento define a arquitetura técnica, a organização do projeto, a modelagem de dados, as integrações externas, os padrões de desenvolvimento e a estratégia de implementação para a primeira versão do Laços.

O plano foi elaborado com base na Constitution, na Specification do MVP e nas decisões técnicas da equipe, priorizando:

- desenvolvimento em Flutter para Android, iOS e Web;
- compartilhamento máximo de código entre plataformas;
- uso de Firebase como backend principal;
- foco em usabilidade, acessibilidade, segurança e evolução incremental do MVP.

---

## 2. Visão arquitetural

### 2.1 Arquitetura geral

O sistema será estruturado como uma aplicação Flutter multi-plataforma com uma camada de domínio compartilhada e integração direta com Firebase.

A arquitetura proposta é uma abordagem híbrida entre:

- Feature-first organization para facilitar evolução do MVP;
- Camadas de domínio, aplicação e infraestrutura para separar regras de negócio, fluxo de interface e integração com serviços externos;
- Reuso de componentes visuais e serviços comuns entre mobile e web.

### 2.2 Componentes principais

1. Aplicação Flutter
   - Interface web e mobile compartilhada;
   - Navegação unificada;
   - Componentes acessíveis e responsivos.

2. Camada de autenticação
   - Firebase Authentication;
   - Login por e-mail e senha;
   - Recuperação de senha;
   - Controle de sessão e perfis.

3. Camada de dados
   - Firestore para dados estruturados;
   - Storage para arquivos e imagens;
   - Regras de segurança para controle de acesso.

4. Camada de notificações
   - Firebase Cloud Messaging para notificações push;
   - Eventos de amizade, mensagens, grupos, vínculo familiar e alertas.

5. Camada de mapas e descoberta
   - Integração com serviço de mapas para exibir locais e atividades;
   - Dados podem ser armazenados no Firestore e renderizados em telas reutilizáveis.

---

## 3. Organização do projeto

A estrutura do projeto deverá seguir uma organização modular para facilitar o crescimento sem duplicação excessiva de código.

### 3.1 Estrutura de pastas sugerida

```text
lib/
  app/
    app.dart
    routes.dart
    theme/
    localization/
  core/
    constants/
    errors/
    extensions/
    utils/
    services/
    validators/
    widgets/
  features/
    auth/
      data/
      domain/
      presentation/
    profile/
      data/
      domain/
      presentation/
    discovery/
      data/
      domain/
      presentation/
    friendships/
      data/
      domain/
      presentation/
    chat/
      data/
      domain/
      presentation/
    groups/
      data/
      domain/
      presentation/
    family/
      data/
      domain/
      presentation/
    notifications/
      data/
      domain/
      presentation/
    help/
      data/
      domain/
      presentation/
  shared/
    models/
    repositories/
    providers/
    components/
  main.dart
```

### 3.2 Diretrizes de organização

- Cada feature deve encapsular dados, regras de negócio e interface.
- A camada shared deve concentrar modelos reutilizáveis, componentes visuais comuns e serviços transversais.
- Regras de negócio sensíveis devem permanecer centralizadas e não dispersas na UI.
- O código deve ser pensado para ser compartilhado entre mobile e web sempre que fizer sentido.

---

## 4. Stack técnico recomendada

### 4.1 Flutter

- Flutter SDK para desenvolvimento multiplataforma.
- Estrutura base com suporte a Android, iOS e Web.
- Uso de widgets responsivos e componentes acessíveis.

### 4.2 Gerenciamento de estado

O projeto deverá utilizar um padrão consistente de estado, preferencialmente com:

- Riverpod ou BLoC para gestão de estado reativo;
- separação entre estado da interface, estado de sessão e estado de dados remotos.

Recomendação: utilizar Riverpod por oferecer integração simples com providers assíncronos e boa escalabilidade para projetos com múltiplas features.

### 4.3 Persistência local

- Armazenamento local de preferências e dados de uso básico com Shared Preferences ou Hive, quando necessário;
- o estado principal permanecerá no Firestore, sendo a persistência local opcional para melhorar a experiência offline limitada.

### 4.4 Testes

- Testes unitários para regras de negócio e validações;
- testes de widgets para componentes e fluxos de tela;
- testes de integração para autenticação, Firestore e notificações;
- validação manual por plataforma para garantir compatibilidade mobile/web.

---

## 5. Modelo de dados no Firestore

O modelo de dados deve priorizar simplicidade, segurança e consultas eficientes.

### 5.1 Coleções principais

#### users

Documento por usuário autenticado.

Campos principais:

- uid
- type: elderly | family
- name
- birthDate
- ageRange
- email
- photoUrl
- city
- state
- interests: array
- bio
- createdAt
- updatedAt
- privacySettings
- status

#### friendships

Representa relações de amizade entre usuários.

Campos principais:

- id
- requesterId
- recipientId
- status: pending | accepted | rejected | blocked
- createdAt
- updatedAt

#### familyLinks

Representa o vínculo entre idoso e familiar.

Campos principais:

- id
- elderlyId
- familyId
- status: pending | active | removed
- requestedAt
- approvedAt
- removedAt
- permissions

#### chats

Representa uma conversa privada entre usuários amigos.

Campos principais:

- id
- participants: array
- lastMessageAt
- createdAt
- lastMessagePreview
- status

#### messages

Subcoleção de chats.

Campos principais:

- id
- senderId
- text
- attachments: array
- createdAt
- isRead
- messageType

#### groups

Representa grupos de interesse.

Campos principais:

- id
- name
- description
- creatorId
- category
- location
- createdAt
- memberIds: array
- imageUrl
- isActive

#### groupMessages

Subcoleção de grupos para mensagens internas.

Campos principais:

- id
- senderId
- text
- attachments
- createdAt
- isRead

#### locations

Catálogo de locais e atividades.

Campos principais:

- id
- name
- category
- description
- address
- city
- state
- openingHours
- coordinates
- rating
- imageUrl
- createdAt

#### alerts

Registros de alertas de segurança e sinalizações.

Campos principais:

- id
- conversationId
- conversationType: private | group
- reportedBy
- reportedAt
- severity
- status: open | resolved
- summary
- relatedUserIds

#### auditLogs

Registro de ações realizadas por familiares.

Campos principais:

- id
- actorId
- targetId
- action
- entityType
- entityId
- createdAt
- details

### 5.2 Regras de modelagem

- O idoso será o dono principal dos dados e controlará o vínculo familiar.
- Dados sensíveis, como senha, credenciais e dados restritos, nunca serão armazenados em documentos públicos.
- Perfis públicos devem expor apenas informações apropriadas para cada contexto.
- A idade deve ser calculada a partir da data de nascimento completa, mas a exibição pública deve usar faixa etária.

---

## 6. Armazenamento de arquivos

### 6.1 Firebase Storage

As imagens e arquivos anexos deverão ser organizados por pastas, por exemplo:

```text
uploads/
  users/{uid}/profile.jpg
  chats/{chatId}/{messageId}/{fileName}
  groups/{groupId}/{fileName}
  locations/{locationId}/{fileName}
```

### 6.2 Regras de segurança

- Somente o proprietário da imagem ou usuários autorizados poderão acessar certos arquivos.
- Anexos de conversas sinalizadas podem ter acesso controlado ao familiar vinculado.
- Arquivos inválidos ou excessivamente grandes devem ser validados antes do upload.

---

## 7. Autenticação e autorização

### 7.1 Firebase Authentication

- Cadastro com e-mail e senha.
- Login com e-mail e senha.
- Recuperação de senha por e-mail.
- Sessão persistente para mobile e web.

### 7.2 Controle de permissões

As permissões devem ser aplicadas por tipo de usuário e por contexto:

- idoso: acesso completo às funcionalidades pessoais e sociais;
- familiar: acesso restrito às informações autorizadas e aos alertas permitidos;
- usuários comuns: acesso limitado a funcionalidades públicas e de interação social.

### 7.3 Regras de segurança no Firestore

As regras devem garantir:

- que apenas usuários autenticados leiam/escrevam seus próprios dados;
- que vínculos familiares só sejam aprovados por autorização do idoso;
- que apenas amigos confirmados possam trocar mensagens privadas;
- que familiares tenham acesso apenas a dados e conversas autorizadas.

---

## 8. Integrações externas

### 8.1 Firebase Authentication

Responsável por cadastro, login, sessão e recuperação de senha.

### 8.2 Cloud Firestore

Responsável por armazenar dados transacionais do sistema, como perfis, amizades, grupos, chats e alertas.

### 8.3 Firebase Storage

Responsável por armazenar imagens de perfil, fotos de grupos, anexos e conteúdo multimídia.

### 8.4 Firebase Cloud Messaging

Responsável por enviar:

- solicitações de amizade;
- respostas de amizade;
- novas mensagens;
- convites e atualizações de grupos;
- notificações de vínculo familiar;
- avisos importantes da plataforma.

### 8.5 Serviço de mapas

Para exibição de locais de lazer e atividades, o sistema poderá integrar um provedor de mapas com base em localização e geolocalização opcional.

### 8.6 Observabilidade

- Logs estruturados para eventos críticos;
- monitoramento de erros e falhas de autenticação;
- rastreamento de eventos principais para auditoria.

---

## 9. Padrões de desenvolvimento

### 9.1 Padrão de arquitetura

Será adotado um padrão baseado em features com separação entre:

- domain: entidades, casos de uso, regras de negócio;
- data: repositórios, fontes de dados e mapeamentos;
- presentation: telas, widgets, controllers e estados.

### 9.2 Padrão de interface

- design system próprio ou componentes reutilizáveis;
- consistência visual com o protótipo do Figma;
- botões grandes, contraste adequado, texto claro e navegação simples;
- componentes adaptados para touch, mouse e teclado.

### 9.3 Acessibilidade

- suporte a fontes ampliáveis;
- contraste adequado;
- labels de acessibilidade;
- áreas de toque amplas;
- navegação por teclado e semântica correta.

### 9.4 Padrões de código

- nomes claros e consistentes;
- uso de tipos fortes em Dart;
- funções pequenas e bem isoladas;
- tratamento explícito de erros;
- comentários apenas quando necessários;
- documentação mínima para módulos complexos.

### 9.5 Versionamento

- branch por funcionalidade: feature/nome-da-funcionalidade;
- pull requests obrigatórios;
- revisão por outro integrante antes do merge;
- branch main protegida.

---

## 10. Estratégia de implementação do MVP

### Fase 1 — Base do projeto

Objetivos:

- criar o projeto Flutter com estrutura modular;
- configurar Firebase Authentication, Firestore e Storage;
- definir tema, rotas, componentes base e arquitetura inicial.

Entregáveis:

- projeto inicial configurado;
- autenticação funcional;
- estrutura de pastas e padrões definidos.

### Fase 2 — Autenticação e perfil

Objetivos:

- cadastro e login de idosos e familiares;
- criação e edição de perfil;
- armazenamento de interesses e dados públicos/privados.

Entregáveis:

- fluxo completo de cadastro e login;
- perfil editável;
- regras básicas de privacidade implementadas.

### Fase 3 — Descoberta e conexões

Objetivos:

- pesquisa de locais e atividades;
- sugestões de amizade por interesses;
- envio, aceite e recusa de solicitações.

Entregáveis:

- tela de descoberta funcional;
- fluxo de amizade completo;
- limite anti-spam de solicitações implementado.

### Fase 4 — Chat e grupos

Objetivos:

- chat privado entre amigos;
- criação e participação em grupos;
- notificações de mensagens e atualizações.

Entregáveis:

- chat funcional;
- grupos com membros e mensagens;
- notificações básicas do fluxo social.

### Fase 5 — Acompanhamento familiar e alertas

Objetivos:

- solicitação e aprovação de vínculo familiar;
- acesso restrito de familiares;
- sinalização de alertas e logs de auditoria.

Entregáveis:

- fluxo de vínculo implementado;
- permissões por perfil executadas;
- visualização segura de conversas sinalizadas.

### Fase 6 — Qualidade e entrega

Objetivos:

- validação de acessibilidade;
- testes e correções de usabilidade;
- revisão com a equipe e ajustes finais.

Entregáveis:

- MVP validado;
- integração com Firebase testada;
- documentação atualizada.

---

## 11. Estratégia de testes

### 11.1 Testes unitários

- validação de regras de idade, permissões, limite de solicitações e estados de vínculo;
- testes de utilidades e validadores.

### 11.2 Testes de widgets

- telas de login, cadastro, perfil, descoberta, amizade, chat e grupos;
- validação de componentes acessíveis e responsivos.

### 11.3 Testes de integração

- autenticação com Firebase;
- leitura e escrita no Firestore;
- upload de arquivos no Storage;
- recebimento de notificações por FCM.

### 11.4 Testes manuais

- validação em Android, iOS e Web;
- checagem de fluxo completo para idoso e familiar;
- revisão visual contra o protótipo do Figma.

---

## 12. Riscos e mitigação

### Risco: complexidade de permissões

Mitigação:

- centralizar permissões em serviços ou repositórios compartilhados;
- validar regras de acesso por testes automatizados.

### Risco: divergência entre mobile e web

Mitigação:

- priorizar componentes e lógica compartilhada;
- tratar diferenças de UI por camadas específicas.

### Risco: alto volume de dados em chats e grupos

Mitigação:

- estruturar mensagens em subcoleções;
- aplicar paginação e consultas otimizadas.

### Risco: dependência de notificações push

Mitigação:

- implementar fallback por polling ou mensagens internas quando necessário;
- testar em ambientes reais antes da entrega.

---

## 13. Critérios de conclusão do plano

O plano estará concluído quando:

- a arquitetura técnica estiver definida e alinhada ao MVP;
- a organização do projeto estiver documentada;
- a estrutura do banco de dados estiver proposta;
- as integrações e padrões de desenvolvimento estiverem claros;
- a estratégia de implementação estiver dividida em fases executáveis.

Este plano servirá de base para a etapa seguinte do SDD, em que serão detalhadas as tasks e o checklist de implementação.

