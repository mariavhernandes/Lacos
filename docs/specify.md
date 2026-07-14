# Especificação funcional do MVP do Laços

## Visão geral

O Laços é uma plataforma mobile e web voltada para apoiar a socialização de pessoas idosas, permitindo encontrar pessoas e locais de interesse, participar de grupos e manter comunicação simples com contatos confirmados. A primeira versão concentra-se em um uso acessível, seguro e alinhado ao protótipo desenvolvido pela equipe.


## Objetivo do sistema

Permitir que idosos ampliem sua rede social, participem de atividades presenciais e mantenham contato com pessoas que compartilham interesses em comum, além de oferecer um ambiente seguro para acompanhamento por familiares ou responsáveis.


## Escopo do MVP

O MVP inclui:

- cadastro, login e recuperação de senha;
- criação e edição de perfil com informações pessoais, interesses e seleção de avatar;
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

- O idoso deve informar nome, data de nascimento, e-mail, senha, interesses relevantes e selecionar um avatar entre as opções disponíveis.
- O sistema deve exibir o perfil do usuário com as informações cadastradas.
- O usuário poderá editar suas informações de perfil sempre que desejar.
- O usuário poderá selecionar um avatar entre as opções disponibilizadas pela aplicação durante o cadastro ou na edição do perfil.


## Descoberta de locais e atividades

- O usuário deve pesquisar locais e atividades por categoria e localização.
- O sistema deve exibir detalhes do local, incluindo descrição, endereço, horário de funcionamento e demais informações disponíveis.


## Conexões e amizades

- O usuário deve enviar solicitação de amizade para outro usuário.
- O destinatário deve aceitar ou recusar a solicitação.
- Apenas usuários confirmados como amigos devem poder trocar mensagens privadas.
- O sistema deve sugerir amizades com base principalmente nos interesses cadastrados pelos usuários.


## Chat e grupos

- Usuários amigos devem poder trocar mensagens privadas de texto.
- Usuários idosos devem poder criar grupos de interesse.
- Todos os usuários poderão visualizar e participar dos grupos disponíveis na plataforma.
- O sistema deve informar eventos relevantes sobre mensagens e atualizações de grupos.


## Acompanhamento familiar (detalhamento do MVP)

- O familiar pode solicitar vínculo ao perfil do idoso; o idoso aceita ou recusa.  
- Cada idoso poderá ter no máximo um familiar vinculado; cada familiar poderá estar vinculado a no máximo um idoso. Não são permitidos múltiplos vínculos para o mesmo idoso.  
- Tanto o idoso quanto o familiar podem remover o vínculo a qualquer momento; a desvinculação ocorre imediatamente, sem confirmação adicional, encerrando automaticamente o acesso do familiar às funcionalidades de acompanhamento.  
- Após a aprovação do vínculo, o familiar terá acesso exclusivamente às informações e funcionalidades previstas para o perfil de familiar:
  - Pode visualizar: nome completo, foto de perfil, faixa etária (exibida no perfil público), cidade e estado, interesses cadastrados, lista de amigos do idoso, grupos dos quais o idoso participa, eventos/atividades confirmadas pelo idoso, e conversas ou mensagens sinalizadas como suspeitas pelo painel de alerta.
  - Não pode: editar qualquer informação do perfil do idoso; acessar senha ou credenciais; acessar configurações da conta do idoso; criar, editar ou excluir grupos em nome do idoso; enviar solicitações de amizade em nome do idoso; enviar mensagens em nome do idoso; ou manter rede social própria no lugar do idoso.
- Mensagens sinalizadas:
  - O sistema pode sinalizar tanto conversas privadas (1:1) quanto mensagens em grupos.
  - Quando uma conversa for sinalizada, o familiar terá acesso ao histórico completo da conversa relacionada ao alerta, enquanto o vínculo existir.
  - Ao visualizar participantes de conversas sinalizadas, o familiar verá somente os campos de perfil públicos (nome, foto, cidade, faixa etária, interesses). Dados de contato privados (e‑mail, telefone) não são exibidos ao familiar, salvo se o próprio usuário os marcar como públicos.
- Acesso e logs:
  - O acesso do familiar às conversas sinalizadas é mantido indefinidamente enquanto o vínculo existir; todas as ações do familiar (visualização de conversas, bloqueios, marcação de alertas como resolvidos, desvinculação) devem ser registradas em logs de auditoria para conformidade e moderação.

Ações disponíveis ao familiar sobre alertas e participantes
- O familiar pode marcar um alerta como resolvido.
  - Ao marcar como resolvido o sistema registra a resolução e oculta/remova o acesso do familiar apenas à conversa sinalizada correspondente (não afeta outras conversas sinalizadas).
- O familiar pode bloquear um participante em nome do idoso.
  - O bloqueio aplica‑se à conta do idoso: o participante é automaticamente removido da lista de amigos do idoso e removido de todos os grupos em comum com o idoso; não poderá enviar novas mensagens, solicitações de amizade ou realizar outras interações ao idoso. O histórico de conversas permanece armazenado para fins de auditoria/alertas de segurança.


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


## Segurança / Regras operacionais (complemento)

- Apenas usuários confirmados como amigos podem trocar mensagens privadas entre si (regra válida entre usuários idosos). O familiar não participa do fluxo de troca privada habitual entre usuários.  
- Sinalizações de segurança podem originar‑se de conversas privadas (1:1) ou de grupos; o sistema deve registrar sinalizações e permitir a visualização por familiares conforme regras acima.  
- Limitação de envio de solicitações de amizade (anti‑spam):
  - Cada usuário pode enviar até 20 solicitações de amizade por período.
  - Ao atingir o limite, o sistema impede o envio de novas solicitações e exibe mensagem informando que o limite diário foi alcançado.
  - O envio de novas solicitações é liberado 24 horas após o momento em que o usuário atingiu o limite (janela móvel).
- Dados de nascimento e privacidade:
  - O sistema armazena a data de nascimento completa para cálculo de idade e validação interna.
  - Em perfis públicos será exibida apenas a faixa etária (ex.: 60–69); a data de nascimento completa não é exibida a outros usuários nem ao familiar.
- Auditoria e rastreabilidade:
  - Todas as ações relevantes realizadas pelo familiar, como visualização de informações autorizadas, alterações de configurações, marcação de alertas e desvinculação, devem ficar registradas em logs de auditoria.


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
- O usuário consegue selecionar e visualizar seu avatar em seu perfil e nas demais telas da aplicação.