# Constitution do Projeto Laços

## Visão Geral

O Laços é uma plataforma composta por um aplicativo mobile e uma aplicação web desenvolvidos em Flutter, destinada a combater o isolamento social entre pessoas idosas. A plataforma promove socialização, bem-estar e qualidade de vida, permitindo que idosos encontrem pessoas com interesses em comum, participem de grupos, conversem por chat e descubram locais de lazer adequados às suas preferências.

O sistema também oferece uma área para familiares ou responsáveis, permitindo o acompanhamento das informações autorizadas pelo idoso, melhorando a segurança e a tranquilidade da família.

## Objetivo

A Constitution define as regras, o escopo e os princípios que regerão o desenvolvimento da primeira versão do Laços, com foco no MVP, no público idoso e nos familiares ou responsáveis.

## Público-Alvo

- Público principal: pessoas da terceira idade que desejam ampliar seu círculo social e participar de atividades presenciais.
- Público secundário: familiares e responsáveis que desejam acompanhar e apoiar o uso da plataforma de forma segura.

## Escopo da Primeira Versão

A primeira versão do Laços deverá priorizar as funcionalidades essenciais que promovam socialização e acompanhamento seguro, entregues de forma simples, acessível e segura.

### Funcionalidades para idosos

- Cadastro e login de usuários.
- Recuperação de senha.
- Criação e edição de perfil com informações pessoais e interesses.
- Pesquisa de locais de lazer e atividades voltadas à terceira idade, com filtros por categoria e localização.
- Visualização de informações detalhadas dos locais de lazer (descrição, endereço, horário de funcionamento e avaliações).
- Sistema de sugestões de amizades baseado em interesses em comum.
- Chat privado entre usuários amigos.
- Criação e participação em grupos de interesse.
- Sistema de notificações.
- Central de ajuda.

### Funcionalidades para familiares ou responsáveis

- Cadastro e login.
- Associação ao perfil do idoso mediante autorização explícita.
- Visualização das informações autorizadas pelo idoso.
- Gerenciamento de contatos.
- Recebimento de notificações relacionadas à segurança.
- Configuração de preferências de acompanhamento.

## Regras de Privacidade e Autorização

- O idoso é o proprietário de seus dados e controla a vinculação de familiares ou responsáveis à sua conta.
- O vínculo somente será estabelecido mediante autorização explícita do idoso, que poderá aceitar ou recusar a solicitação.
- Após aprovação, o familiar terá acesso às informações e funcionalidades padronizadas pelo sistema para seu perfil.
- As informações disponíveis ao familiar serão somente aquelas necessárias para promover segurança e acompanhamento, respeitando a LGPD.
- Dados sensíveis como senha, credenciais de acesso e demais informações restritas permanecerão inacessíveis a outros usuários.

## Tecnologias e Integrações

- Plataforma mobile: Flutter para Android e iOS.
- Aplicação web responsiva: Flutter Web.
- Linguagem: Dart.
- Backend e banco de dados: Firebase Authentication, Cloud Firestore e Firebase Storage.
- Integrações: serviço de mapas para exibição de locais de lazer e atividades; notificações push para avisos, solicitações de vínculo, mensagens e atualizações.
- IDE: Visual Studio Code.
- Versionamento: GitHub.
- Assistente de desenvolvimento: GitHub Copilot.
- Metodologia: Spec-Driven Development (SDD).

## Qualidade de Experiência

### Usabilidade

- Interface simples, intuitiva e consistente.
- Navegação com poucos passos para ações importantes.
- Botões grandes e fáceis de selecionar.
- Linguagem clara e objetiva, sem termos técnicos.
- Feedback visual para todas as ações (confirmações, erros e carregamentos).
- Fidelidade ao protótipo no Figma.

### Acessibilidade

- Fontes legíveis com possibilidade de ampliação.
- Alto contraste entre textos e elementos.
- Ícones acompanhados de textos explicativos sempre que possível.
- Áreas de toque amplas.
- Compatibilidade com recursos de acessibilidade de Android, iOS e navegadores.

### Desempenho

- Tempo de carregamento reduzido para telas principais.
- Navegação fluida entre telas.
- Consultas ao banco de dados otimizadas.
- Componentes reutilizáveis.
- Funcionalidade responsiva na web.

## Exclusões do MVP

Ficam fora do escopo da primeira versão do Laços:

- Chamadas de áudio e vídeo entre usuários.
- Chat de ajuda baseado em inteligência artificial.
- Compartilhamento de localização em tempo real.

## Regras de Relacionamento Social

- A conexão entre idosos será baseada em solicitação e aceitação de amizade.
- Um usuário pode enviar solicitação de amizade para outro.
- O destinatário pode aceitar ou recusar a solicitação.
- Apenas amigos confirmados podem trocar mensagens privadas.
- Usuários podem participar de grupos de interesse para conhecer novas pessoas.
- O sistema sugere amizades com base em interesses, faixa etária semelhante, cidade/região e participação em grupos ou atividades em comum.
- Usuários podem bloquear outros usuários. Após o bloqueio:
  - Não é possível enviar novas solicitações de amizade.
  - Não é possível trocar mensagens pelo chat.
  - O usuário bloqueado não pode visualizar determinadas interações privadas.

## Notificações

As notificações devem ser utilizadas apenas para eventos importantes, evitando excesso de alertas.

### Para idosos

- Recebimento de solicitação de amizade.
- Aceitação de solicitação de amizade.
- Novas mensagens no chat.
- Convites ou atualizações de grupos.
- Solicitações de vínculo enviadas por familiares ou responsáveis.
- Avisos importantes da plataforma.

### Para familiares ou responsáveis

- Aprovação ou recusa da solicitação de vínculo pelo idoso.
- Alertas de segurança do sistema.
- Avisos importantes relacionados ao perfil do idoso.
- Comunicados da plataforma.

### Diretrizes de envio

- Enviar apenas notificações relevantes.
- Agrupar notificações repetidas sempre que possível.
- Exibir mensagens claras e objetivas.

## Critérios de Aceitação

Uma funcionalidade será considerada concluída quando:

- Estiver implementada conforme a especificação da etapa Specify.
- Atender aos requisitos funcionais e não funcionais.
- Seguir fielmente o protótipo do Figma.
- Estiver integrada corretamente ao Firebase quando necessário.
- Funcionar corretamente em Flutter Mobile e Flutter Web.
- Apresentar interface acessível e intuitiva.
- Não apresentar erros de execução ou falhas críticas.
- Seguir os padrões de código e arquitetura da equipe.
- For revisada por outro integrante antes da integração à branch principal.
- For aprovada na Checklist do SDD antes da implementação final.

### Indicadores de sucesso

- Implementação de todas as funcionalidades previstas para o MVP.
- Compatibilidade entre mobile e web.
- Interface fiel ao protótipo.
- Navegação simples e intuitiva.
- Integração completa com Firebase.
- Código organizado, reutilizável e documentado.
- Desenvolvimento seguindo as etapas do Spec-Driven Development.

## Processo de Acesso

### Cadastro

- O usuário escolhe entre criar conta como Idoso ou Familiar/Responsável.
- O cadastro solicita apenas as informações necessárias: nome, data de nascimento, e-mail, senha e dados do perfil.
- Durante o cadastro do idoso, é possível informar interesses.
- Após concluir o cadastro, o usuário acessa imediatamente a plataforma.

### Login

- Acesso com e-mail e senha via Firebase Authentication.

### Recuperação de senha

- O usuário pede recuperação informando o e-mail cadastrado.
- Será enviado um link de redefinição de senha por e-mail.

### Primeiro acesso

- O usuário recebe uma breve introdução sobre as funcionalidades.
- Em seguida, é direcionado para a tela inicial.

### Vinculação idoso-familiar

- O familiar envia solicitação de vínculo ao idoso.
- O idoso aceita ou recusa.
- Após aprovação, o vínculo é estabelecido e o familiar recebe acesso às funcionalidades previstas.

## Segurança e Moderação

- Usuários podem bloquear outros para impedir interações, solicitações de amizade e mensagens.
- Apenas amigos confirmados podem enviar mensagens privadas.
- Solicitações de amizade podem ser aceitas ou recusadas.
- O sistema limita o envio excessivo de solicitações em curto período para reduzir spam.
- Links suspeitos ou não autorizados podem ser bloqueados pelo sistema.
- Familiares têm acesso apenas às funcionalidades previstas para o seu perfil.
- Todas as interações devem respeitar as políticas de uso da plataforma e a LGPD.
- Moderação automática avançada e sistemas complexos de denúncias são previstos para versões futuras.

## Práticas de Desenvolvimento

- O desenvolvimento segue a metodologia SDD: Constitution, Specify, Clarify, Plan, Tasks, Analyze, Checklist e Implement.
- Nenhuma funcionalidade será implementada antes da aprovação de sua especificação.
- O desenvolvimento será incremental, priorizando o MVP.
- GitHub será usado para versionamento.
- Cada funcionalidade será desenvolvida em branch própria (`feature/nome-da-funcionalidade`).
- Alterações diretas na branch `main` são proibidas.
- Integração por Pull Requests revisados por pelo menos um integrante.
- Código deve seguir padrões definidos pela equipe e ser organizado, legível e reutilizável.
- Mobile e web devem compartilhar o máximo de código possível.
- Regras de negócio centralizadas para evitar comportamentos diferentes entre plataformas.
- Integração com Firebase testada antes do merge.
- Documentação atualizada sempre que houver alterações relevantes.

## Idioma

- O MVP será lançado apenas em português.
