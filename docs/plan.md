# Plano de Implementação do MVP do Laços

## 1. Objetivo do plano

Este documento define a arquitetura técnica, a organização do projeto, a modelagem de dados, as integrações externas, os padrões de desenvolvimento e a estratégia de implementação para a primeira versão do Laços.

O plano foi elaborado com base na Constitution, na Specification do MVP e nas decisões técnicas da equipe, priorizando:

* desenvolvimento em Flutter para Android, iOS e Web;
* compartilhamento máximo de código entre plataformas;
* uso de Firebase como backend principal;
* foco em usabilidade, acessibilidade, segurança e evolução incremental do MVP;
* reutilização das estruturas existentes do projeto, evitando duplicação desnecessária de dados e fluxos.

---

## 2. Visão arquitetural

### 2.1 Arquitetura geral

O sistema será estruturado como uma aplicação Flutter multi-plataforma com uma camada de domínio compartilhada e integração direta com Firebase.

A arquitetura proposta é uma abordagem híbrida entre:

* Feature-first organization para facilitar evolução do MVP;
* Camadas de domínio, aplicação e infraestrutura para separar regras de negócio, fluxo de interface e integração com serviços externos;
* Reuso de componentes visuais e serviços comuns entre mobile e web.

### 2.2 Componentes principais

1. Aplicação Flutter

   * Interface web e mobile compartilhada;
   * Navegação unificada;
   * Componentes acessíveis e responsivos.

2. Camada de autenticação

   * Firebase Authentication;
   * Login por e-mail e senha;
   * Recuperação de senha;
   * Controle de sessão e perfis.

3. Camada de dados

   * Cloud Firestore para armazenamento dos dados estruturados do sistema;
   * Regras de segurança para controle de acesso;
   * Recursos estáticos, como imagens da interface e avatares, incorporados ao aplicativo.

4. Camada de notificações

   * Firebase Cloud Messaging para notificações push;
   * Eventos de amizade, mensagens, grupos, vínculo familiar e alertas.

5. Camada de mapas e descoberta

   * Integração com serviço de mapas para exibir locais e atividades;
   * Dados podem ser armazenados no Firestore e renderizados em telas reutilizáveis.

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

* Cada feature deve encapsular dados, regras de negócio e interface.
* A camada shared deve concentrar modelos reutilizáveis, componentes visuais comuns e serviços transversais.
* Regras de negócio sensíveis devem permanecer centralizadas e não dispersas na UI.
* O código deve ser pensado para ser compartilhado entre mobile e web sempre que fizer sentido.
* Estruturas existentes devem ser reutilizadas sempre que atenderem aos requisitos da funcionalidade.

---

## 4. Stack técnico recomendada

### 4.1 Flutter

* Flutter SDK para desenvolvimento multiplataforma.
* Estrutura base com suporte a Android, iOS e Web.
* Uso de widgets responsivos e componentes acessíveis.

### 4.2 Gerenciamento de estado

O projeto deverá utilizar um padrão consistente de estado, preferencialmente com:

* Riverpod ou BLoC para gestão de estado reativo;
* separação entre estado da interface, estado de sessão e estado de dados remotos.

Recomendação: utilizar Riverpod por oferecer integração simples com providers assíncronos e boa escalabilidade para projetos com múltiplas features.

### 4.3 Persistência local

* Armazenamento local de preferências e dados de uso básico com Shared Preferences ou Hive, quando necessário;
* o estado principal permanecerá no Firestore, sendo a persistência local opcional para melhorar a experiência offline limitada.

### 4.4 Testes

* Testes unitários para regras de negócio e validações;
* testes de widgets para componentes e fluxos de tela;
* testes de integração para autenticação, Firestore e notificações;
* validação manual por plataforma para garantir compatibilidade mobile/web.

---

## 5. Modelo de dados no Firestore

O modelo de dados deve priorizar simplicidade, segurança e consultas eficientes, reutilizando os campos e estruturas existentes sempre que possível.

### 5.1 Coleções principais

#### users

Documento por usuário autenticado.

Campos principais:

* uid
* type: elderly | family
* name
* birthDate
* ageRange
* email
* avatar
* city
* state
* interests: array
* bio
* linkedElderEmail, quando aplicável ao perfil de familiar
* createdAt
* updatedAt
* privacySettings

O campo `linkedElderEmail` será utilizado para identificar o idoso que o familiar ou responsável deseja supervisionar. Quando o e-mail informado corresponder a uma conta de idoso válida, o vínculo será estabelecido automaticamente conforme as regras da funcionalidade.

#### friendships

Representa relações de amizade entre usuários.

Campos principais:

* id
* requesterId
* recipientId
* status: pending | accepted | rejected | blocked
* createdAt
* updatedAt

#### familyLinks

Representa o vínculo ativo entre idoso e familiar, quando uma estrutura específica de relacionamento for necessária para armazenar ou consultar essa relação.

Campos principais:

* id
* elderlyId
* familyId
* status: active | removed
* createdAt
* removedAt

O `familyLinks` não deverá criar um fluxo separado de solicitação e aprovação. O vínculo será criado como ativo após a validação do `linkedElderEmail`.

Sempre que a estrutura existente do projeto permitir realizar o relacionamento sem duplicação, ela deverá ser priorizada em vez da criação de novos documentos ou coleções.

#### chats

Representa uma conversa privada entre usuários amigos.

Campos principais:

* id
* participants: array
* lastMessageAt
* createdAt
* lastMessagePreview
* status

#### messages

Subcoleção de chats.

Campos principais:

* id
* senderId
* text
* createdAt
* isRead
* messageType

#### groups

Representa grupos de interesse.

Campos principais:

* id
* name
* description
* creatorId
* category
* location
* createdAt
* memberIds: array
* isActive

#### groupMessages

Subcoleção de grupos para mensagens internas.

Campos principais:

* id
* senderId
* text
* createdAt
* isRead

#### locations

Catálogo de locais e atividades.

Campos principais:

* id
* name
* category
* description
* address
* city
* state
* openingHours
* coordinates
* imageReference
* createdAt

#### alerts

Estrutura destinada ao armazenamento de alertas de segurança em futuras versões do sistema. A geração automática desses alertas por Inteligência Artificial não faz parte do escopo do MVP.

Campos principais:

* id
* conversationId
* conversationType: private | group
* reportedBy
* reportedAt
* severity
* status: open | resolved
* summary
* relatedUserIds

#### auditLogs

Registro de ações realizadas por familiares.

Campos principais:

* id
* actorId
* targetId
* action
* entityType
* entityId
* createdAt
* details

### 5.2 Regras de modelagem

* O idoso será o proprietário principal dos seus dados e terá controle sobre a permanência do vínculo familiar.
* O `linkedElderEmail` deverá ser reutilizado como mecanismo principal para identificar o idoso relacionado ao familiar.
* O sistema deverá validar se o e-mail informado corresponde a uma conta de idoso válida antes de estabelecer o vínculo.
* Um vínculo válido será criado automaticamente após a validação, sem necessidade de uma solicitação pendente ou de aprovação manual.
* O vínculo deverá possuir um estado que permita identificar se está ativo ou removido/bloqueado.
* O bloqueio realizado pelo idoso deverá impedir a continuidade da supervisão e do acesso do familiar às informações correspondentes.
* Dados sensíveis, como senha, credenciais e dados restritos, nunca serão armazenados em documentos públicos.
* Perfis públicos devem expor apenas informações apropriadas para cada contexto.
* A idade deve ser calculada a partir da data de nascimento completa, mas a exibição pública deve usar faixa etária.

---

## 6. Autenticação e autorização

### 6.1 Firebase Authentication

* Cadastro com e-mail e senha.
* Login com e-mail e senha.
* Recuperação de senha por e-mail.
* Sessão persistente para mobile e web.

### 6.2 Controle de permissões

As permissões devem ser aplicadas por tipo de usuário e por contexto:

* idoso: acesso completo às funcionalidades pessoais e sociais;
* familiar: acesso restrito às informações autorizadas e aos alertas permitidos;
* usuários comuns: acesso limitado a funcionalidades públicas e de interação social.

### 6.3 Regras de segurança no Firestore

As regras devem garantir:

* que apenas usuários autenticados leiam/escrevam seus próprios dados;
* que o `linkedElderEmail` seja validado antes da criação do vínculo;
* que vínculos familiares sejam criados automaticamente quando houver correspondência válida com uma conta de idoso;
* que o familiar tenha acesso somente aos dados permitidos enquanto o vínculo estiver ativo;
* que um idoso possa bloquear o familiar e interromper seu acesso;
* que apenas amigos confirmados possam trocar mensagens privadas;
* que familiares tenham acesso apenas a dados e conversas autorizadas.

---

## 7. Integrações externas

### 7.1 Firebase Authentication

Responsável por cadastro, login, sessão e recuperação de senha.

### 7.2 Cloud Firestore

Responsável por armazenar dados transacionais do sistema, como perfis, amizades, grupos, chats, vínculos familiares e alertas.

### 7.3 Recursos estáticos da aplicação

As imagens da interface, ícones e avatares serão incorporados ao aplicativo como recursos locais (assets) do Flutter, eliminando a necessidade de um serviço de armazenamento de arquivos no MVP.

### 7.4 Firebase Cloud Messaging

Responsável por enviar:

* solicitações de amizade;
* respostas de amizade;
* novas mensagens;
* convites e atualizações de grupos;
* notificações de vínculo familiar;
* avisos importantes da plataforma.

Quando um vínculo familiar for criado automaticamente após a validação do `linkedElderEmail`, o idoso deverá receber uma notificação informando que o familiar ou responsável passou a supervisioná-lo.

A infraestrutura também será preparada para, em versões futuras, permitir o envio de notificações relacionadas a alertas de segurança gerados por Inteligência Artificial.

### 7.5 Serviço de mapas

Para exibição de locais de lazer e atividades, o sistema poderá integrar um provedor de mapas com base em localização e geolocalização opcional.

### 7.6 Observabilidade

* Logs estruturados para eventos críticos;
* monitoramento de erros e falhas de autenticação;
* rastreamento de eventos principais para auditoria.

---

## 8. Padrões de desenvolvimento

### 8.1 Padrão de arquitetura

Será adotado um padrão baseado em features com separação entre:

* domain: entidades, casos de uso, regras de negócio;
* data: repositórios, fontes de dados e mapeamentos;
* presentation: telas, widgets, controllers e estados.

### 8.2 Padrão de interface

* design system próprio ou componentes reutilizáveis;
* consistência visual com o protótipo do Figma;
* botões grandes, contraste adequado, texto claro e navegação simples;
* componentes adaptados para touch, mouse e teclado.

### 8.3 Acessibilidade

* suporte a fontes ampliáveis;
* contraste adequado;
* labels de acessibilidade;
* áreas de toque amplas;
* navegação por teclado e semântica correta.

### 8.4 Padrões de código

* nomes claros e consistentes;
* uso de tipos fortes em Dart;
* funções pequenas e bem isoladas;
* tratamento explícito de erros;
* comentários apenas quando necessários;
* documentação mínima para módulos complexos.

### 8.5 Versionamento

* branch por funcionalidade: feature/nome-da-funcionalidade;
* pull requests obrigatórios;
* revisão por outro integrante antes do merge;
* branch main protegida.

---

## 9. Estratégia de implementação do MVP

### Fase 1 — Base do projeto

Objetivos:

* criar o projeto Flutter com estrutura modular;
* configurar Firebase Authentication e Cloud Firestore;
* definir tema, rotas, componentes base e arquitetura inicial.

Entregáveis:

* projeto inicial configurado;
* autenticação funcional;
* estrutura de pastas e padrões definidos.

### Fase 2 — Autenticação e perfil

Objetivos:

* cadastro e login de idosos e familiares;
* criação e edição de perfil;
* armazenamento de interesses e dados públicos/privados;
* suporte ao campo `linkedElderEmail` para perfis de familiares.

Entregáveis:

* fluxo completo de cadastro e login;
* perfil editável;
* regras básicas de privacidade implementadas.

### Fase 3 — Descoberta e conexões

Objetivos:

* pesquisa de locais e atividades;
* sugestões de amizade por interesses;
* envio, aceite e recusa de solicitações.

Entregáveis:

* tela de descoberta funcional;
* fluxo de amizade completo;
* limite anti-spam de solicitações implementado.

### Fase 4 — Chat e grupos

Objetivos:

* chat privado entre amigos;
* criação e participação em grupos;
* notificações de mensagens e atualizações.

Entregáveis:

* chat funcional;
* grupos com membros e mensagens;
* notificações básicas do fluxo social.

### Fase 5 — Acompanhamento familiar e alertas

Objetivos:

* permitir que o familiar informe o `linkedElderEmail` de um idoso;
* validar se o e-mail informado corresponde a uma conta de idoso válida;
* criar automaticamente o vínculo quando a validação for concluída;
* notificar o idoso sobre o estabelecimento do vínculo;
* permitir que o idoso bloqueie o familiar caso não queira mais permitir a supervisão;
* garantir acesso restrito do familiar conforme as regras definidas;
* implementar a estrutura necessária para futura integração com o sistema de alertas.

Entregáveis:

* fluxo de vinculação familiar implementado;
* vínculo criado automaticamente após validação do `linkedElderEmail`;
* notificação enviada ao idoso após o estabelecimento do vínculo;
* mecanismo de bloqueio do familiar pelo idoso;
* permissões por perfil executadas;
* arquitetura preparada para futura implementação do sistema de alertas baseado em Inteligência Artificial.

### Fase 6 — Qualidade e entrega

Objetivos:

* validação de acessibilidade;
* testes e correções de usabilidade;
* revisão com a equipe e ajustes finais.

Entregáveis:

* MVP validado;
* integração com Firebase testada;
* documentação atualizada.

---

## 10. Estratégia de testes

### 10.1 Testes unitários

* validação de regras de idade, permissões, limite de solicitações e estados de vínculo;
* validação do `linkedElderEmail`;
* validação da criação automática do vínculo;
* validação do bloqueio e encerramento do vínculo;
* testes de utilidades e validadores.

### 10.2 Testes de widgets

* telas de login, cadastro, perfil, descoberta, amizade, chat e grupos;
* telas relacionadas ao vínculo familiar;
* validação de componentes acessíveis e responsivos;
* exibição correta das informações e ações relacionadas ao vínculo.

### 10.3 Testes de integração

* autenticação com Firebase;
* leitura e escrita de dados no Cloud Firestore;
* validação do `linkedElderEmail`;
* criação automática do vínculo familiar;
* envio da notificação ao idoso após a criação do vínculo;
* bloqueio do familiar pelo idoso;
* recebimento de notificações por FCM.

### 10.4 Testes manuais

* validação em Android, iOS e Web;
* checagem de fluxo completo para idoso e familiar;
* validação do vínculo utilizando um e-mail de idoso válido;
* validação de comportamento quando o e-mail informado não pertence a um idoso válido;
* validação do bloqueio do familiar pelo idoso;
* revisão visual contra o protótipo do Figma.

---

## 11. Riscos e mitigação

### Risco: complexidade de permissões

Mitigação:

* centralizar permissões em serviços ou repositórios compartilhados;
* validar regras de acesso por testes automatizados;
* garantir que o bloqueio do vínculo interrompa corretamente o acesso do familiar.

### Risco: divergência entre mobile e web

Mitigação:

* priorizar componentes e lógica compartilhada;
* tratar diferenças de UI por camadas específicas.

### Risco: alto volume de dados em chats e grupos

Mitigação:

* estruturar mensagens em subcoleções;
* aplicar paginação e consultas otimizadas.

### Risco: dependência de notificações push

Mitigação:

* testar em ambientes reais antes da entrega;
* garantir que o estabelecimento do vínculo gere corretamente a notificação destinada ao idoso.

### Risco: duplicação de estruturas de vínculo

Mitigação:

* reutilizar o `linkedElderEmail` e as estruturas existentes sempre que possível;
* evitar a criação de fluxos separados de solicitação, aprovação e recusa;
* manter uma única regra de negócio para estabelecimento e encerramento do vínculo.

---

## 12. Critérios de conclusão do plano

O plano estará concluído quando:

* a arquitetura técnica estiver definida e alinhada ao MVP;
* a organização do projeto estiver documentada;
* a estrutura do banco de dados estiver proposta;
* as integrações e padrões de desenvolvimento estiverem claros;
* a estratégia de implementação estiver dividida em fases executáveis;
* o fluxo de vínculo familiar estiver alinhado à decisão de criação automática por meio do `linkedElderEmail`;
* as regras de bloqueio e encerramento do vínculo estiverem contempladas.

Este plano servirá de base para a etapa seguinte do SDD, em que serão detalhadas as tasks e o checklist de implementação.
