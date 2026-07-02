# Especificação funcional do MVP do Laços

## Visão geral

O Laços é uma plataforma mobile e web voltada para apoiar a socialização de pessoas idosas, permitindo encontrar pessoas e locais de interesse, participar de grupos e manter comunicação simples com contatos confirmados. A primeira versão concentra-se em um uso acessível, seguro e alinhado ao protótipo desenvolvido pela equipe.


## Objetivo do sistema

Permitir que idosos ampliem sua rede social, participem de atividades presenciais e mantenham contato com pessoas que compartilham interesses em comum, além de oferecer um ambiente seguro para acompanhamento por familiares ou responsáveis.


## Escopo do MVP

O MVP inclui:

- cadastro, login e recuperação de senha;
- criação e edição de perfil com informações pessoais e interesses;
- busca e visualização de locais de lazer e atividades;
- sugestões de amizades com base nos interesses cadastrados;
- envio, aceite e recusa de solicitações de amizade;
- chat privado entre usuários amigos;
- criação e participação em grupos de interesse;
- notificações relevantes;
- central de ajuda com orientações básicas de uso;
- cadastro, login e vínculo entre familiar e idoso mediante autorização do idoso;
- visualização das informações e funcionalidades disponíveis ao perfil de familiar, conforme as regras definidas pelo sistema.

O MVP **não inclui**:

- chamadas de áudio ou vídeo;
- chat com inteligência artificial;
- compartilhamento de localização em tempo real;
- funcionalidades não previstas na Constitution.


# Requisitos funcionais por módulo

## Autenticação e conta

- O sistema deve permitir cadastro como idoso ou familiar/responsável.
- O sistema deve permitir login utilizando e-mail e senha.
- O sistema deve permitir recuperação de senha por e-mail.
- O sistema deve permitir edição dos dados do perfil após o cadastro.


## Perfil e interesses

- O idoso deve informar nome, data de nascimento, e-mail, senha e interesses relevantes.
- O sistema deve exibir o perfil do usuário com as informações cadastradas.
- O usuário poderá editar suas informações de perfil sempre que desejar.


## Descoberta de locais e atividades

- O usuário deve pesquisar locais e atividades por categoria e localização.
- O sistema deve exibir detalhes do local, incluindo descrição, endereço, horário de funcionamento e demais informações disponíveis.


## Conexões e amizades

- O usuário deve enviar solicitação de amizade para outro usuário.
- O destinatário deve aceitar ou recusar a solicitação.
- Apenas usuários confirmados como amigos devem poder trocar mensagens privadas.
- O sistema deve sugerir amizades com base principalmente nos interesses cadastrados pelos usuários.


## Chat e grupos

- Usuários amigos devem poder trocar mensagens privadas.
- Usuários idosos devem poder criar grupos de interesse.
- Todos os usuários poderão visualizar e participar dos grupos disponíveis na plataforma.
- O sistema deve informar eventos relevantes sobre mensagens e atualizações de grupos.


## Acompanhamento familiar

- O familiar deve poder solicitar vínculo ao perfil do idoso.
- O idoso deve aceitar ou recusar a solicitação de vínculo.
- Após a aprovação, o familiar deverá visualizar apenas as informações e funcionalidades previstas para seu perfil, conforme as regras definidas pelo sistema.


## Central de ajuda

- O sistema deve disponibilizar orientações básicas de uso e informações relevantes para o usuário.
- A central de ajuda não deve oferecer canal de envio de solicitações de suporte.


## Notificações

- O sistema deve enviar notificações para eventos importantes, como:
  - solicitações de amizade;
  - aceite ou recusa de amizade;
  - novas mensagens;
  - convites e atualizações de grupos;
  - solicitações e respostas de vínculo familiar;
  - avisos importantes da plataforma.


## Segurança

- Apenas usuários confirmados como amigos podem iniciar conversas privadas.
- O sistema deve permitir que um usuário bloqueie outro usuário.
- O sistema deve limitar o envio excessivo de solicitações de amizade para reduzir práticas de spam.


# Fluxos principais

1. Cadastro.
2. Login.
3. Recuperação de senha.
4. Criação e edição de perfil.
5. Busca de locais e atividades.
6. Envio e resposta de solicitações de amizade.
7. Conversa privada entre amigos.
8. Criação e participação em grupos.
9. Solicitação e aprovação de vínculo familiar.
10. Acesso à central de ajuda.
11. Recebimento de notificações.


# Regras de negócio

- O idoso é responsável por aceitar ou recusar solicitações de vínculo enviadas por familiares.
- O vínculo somente será estabelecido após aprovação explícita do idoso.
- Apenas amigos confirmados podem trocar mensagens privadas.
- Usuários podem bloquear outros usuários para impedir novas interações.
- O sistema deve limitar o envio excessivo de solicitações de amizade para reduzir spam.
- O sistema deve priorizar notificações relevantes, evitando excesso de alertas.
- O familiar terá acesso apenas às funcionalidades e informações previstas para o seu perfil.
- O sistema deverá respeitar a Lei Geral de Proteção de Dados (LGPD) durante o tratamento dos dados pessoais.

# Critérios de aceite

- O cadastro, login e recuperação de senha funcionam corretamente.
- O idoso consegue criar e editar seu perfil com informações pessoais e interesses.
- O usuário consegue localizar e visualizar detalhes de locais e atividades.
- O fluxo de amizade é concluído com sucesso por meio de aceite ou recusa.
- A troca de mensagens privadas funciona apenas entre amigos confirmados.
- Usuários idosos conseguem criar grupos e todos os usuários conseguem participar dos grupos disponíveis.
- O vínculo familiar é estabelecido somente após autorização do idoso.
- As notificações são exibidas apenas para eventos relevantes.
- A central de ajuda apresenta orientações básicas de uso, sem oferecer canal de suporte.
- O sistema respeita as permissões de cada tipo de usuário (idoso e familiar).
- A interface implementada corresponde ao protótipo desenvolvido no Figma.
- A experiência atende aos requisitos de acessibilidade definidos para o MVP.
