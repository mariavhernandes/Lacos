# Especificação funcional do MVP do Laços

## Visão geral

O Laços é uma plataforma mobile e web voltada para apoiar a socialização de pessoas idosas, permitindo encontrar pessoas e locais de interesse, participar de grupos e manter comunicação simples com contatos confirmados. A primeira versão concentra-se em um uso acessível, seguro e alinhado ao protótipo desenvolvido pela equipe.

## Objetivo do sistema

Permitir que idosos ampliem sua rede social, participem de atividades presenciais e mantenham contato com pessoas que compartilham interesses em comum, além de oferecer um ambiente seguro para acompanhamento por familiares ou responsáveis.

## Escopo do MVP

O MVP inclui:

* cadastro, login e recuperação de senha;
* criação e edição de perfil com informações pessoais, interesses e seleção de avatar;
* busca e visualização de locais de lazer e atividades;
* sugestões de amizades com base nos interesses cadastrados;
* envio, aceite e recusa de solicitações de amizade;
* chat privado entre usuários amigos;
* criação e participação em grupos de interesse;
* notificações relevantes;
* central de ajuda com orientações básicas de uso;
* cadastro, login e vínculo entre familiar e idoso por meio do e-mail do idoso;
* visualização das informações e funcionalidades disponíveis ao perfil de familiar, conforme as regras definidas pelo sistema.

O MVP **não inclui**:

* chamadas de áudio ou vídeo;
* chat com inteligência artificial;
* compartilhamento de localização em tempo real;
* funcionalidades não previstas na Constitution.

# Requisitos funcionais por módulo

## Autenticação e conta

* O sistema deve permitir cadastro como idoso ou familiar/responsável.
* O sistema deve permitir login utilizando e-mail e senha.
* O sistema deve permitir recuperação de senha por e-mail.
* O sistema deve permitir edição dos dados do perfil após o cadastro.

## Perfil e interesses

* O idoso deve informar nome, data de nascimento, e-mail, senha, interesses relevantes e selecionar um avatar entre as opções disponíveis.
* O sistema deve exibir o perfil do usuário com as informações cadastradas.
* O usuário poderá editar suas informações de perfil sempre que desejar.
* O usuário poderá selecionar um avatar entre as opções disponibilizadas pela aplicação durante o cadastro ou na edição do perfil.

## Descoberta de locais e atividades

* O usuário deve pesquisar locais e atividades por categoria e localização.
* O sistema deve exibir detalhes do local, incluindo descrição, endereço, horário de funcionamento e demais informações disponíveis.

## Conexões e amizades

* O usuário deve enviar solicitação de amizade para outro usuário.
* O destinatário deve aceitar ou recusar a solicitação.
* Apenas usuários confirmados como amigos devem poder trocar mensagens privadas.
* O sistema deve sugerir amizades com base principalmente nos interesses cadastrados pelos usuários.

## Chat e grupos

* Usuários amigos devem poder trocar mensagens privadas de texto.
* Usuários idosos devem poder criar grupos de interesse.
* Todos os usuários poderão visualizar e participar dos grupos disponíveis na plataforma.
* O sistema deve informar eventos relevantes sobre mensagens e atualizações de grupos.

## Acompanhamento familiar (detalhamento do MVP)

* O familiar ou responsável poderá informar o e-mail de um idoso no campo `linkedElderEmail`.
* O sistema deverá verificar se o e-mail informado corresponde a uma conta de idoso válida.
* Quando o e-mail informado corresponder a uma conta de idoso válida, o vínculo entre o familiar e o idoso será criado automaticamente.
* Não haverá fluxo de solicitação de vínculo aguardando aprovação ou recusa do idoso.
* Após o estabelecimento automático do vínculo, o idoso receberá uma notificação informando que aquele familiar ou responsável passou a supervisioná-lo.
* Cada idoso poderá ter no máximo um familiar vinculado; cada familiar poderá estar vinculado a no máximo um idoso. Não são permitidos múltiplos vínculos simultâneos para o mesmo idoso ou familiar.
* O idoso poderá bloquear o familiar vinculado caso não queira mais permitir a supervisão.
* O familiar também poderá remover o próprio vínculo a qualquer momento.
* A desvinculação ou bloqueio deverá ocorrer imediatamente, encerrando o acesso do familiar às funcionalidades de acompanhamento.
* A estrutura existente do projeto, especialmente o campo `linkedElderEmail`, deverá ser reutilizada para realizar o vínculo, evitando a criação de um fluxo ou estrutura duplicada sem necessidade.

### Informações disponíveis ao familiar

Enquanto o vínculo estiver ativo, o familiar terá acesso exclusivamente às informações e funcionalidades previstas para o perfil de familiar.

**Pode visualizar:**

* nome completo;
* foto de perfil;
* faixa etária (exibida no perfil público);
* cidade e estado;
* interesses cadastrados;
* lista de amigos do idoso;
* grupos dos quais o idoso participa;
* eventos/atividades confirmadas pelo idoso;
* conversas ou mensagens sinalizadas como suspeitas pelo painel de alerta.

**Não pode:**

* editar qualquer informação do perfil do idoso;
* acessar senha ou credenciais;
* acessar configurações da conta do idoso;
* criar, editar ou excluir grupos em nome do idoso;
* enviar solicitações de amizade em nome do idoso;
* enviar mensagens em nome do idoso;
* manter rede social própria no lugar do idoso.

### Mensagens sinalizadas

* O sistema pode sinalizar tanto conversas privadas (1:1) quanto mensagens em grupos.
* Quando uma conversa for sinalizada, o familiar terá acesso ao histórico completo da conversa relacionada ao alerta enquanto o vínculo estiver ativo e conforme as regras de segurança definidas pelo sistema.
* Ao visualizar participantes de conversas sinalizadas, o familiar verá somente os campos de perfil públicos (nome, foto, cidade, faixa etária e interesses).
* Dados de contato privados (e-mail e telefone) não são exibidos ao familiar, salvo se o próprio usuário os marcar como públicos.

### Acesso e logs

* O acesso do familiar às conversas sinalizadas será mantido enquanto o vínculo estiver ativo e conforme as regras de resolução de alertas.
* Todas as ações relevantes do familiar, incluindo visualização de conversas, bloqueios, marcação de alertas como resolvidos e desvinculação, devem ser registradas em logs de auditoria para fins de conformidade e moderação.

## Ações disponíveis ao familiar sobre alertas e participantes

### Marcação de alerta como resolvido

* O familiar pode marcar um alerta como resolvido.
* Ao marcar como resolvido, o sistema registra a resolução e oculta ou remove o acesso do familiar apenas à conversa sinalizada correspondente.
* A ação não afeta outras conversas sinalizadas.

### Bloqueio de participante

* O familiar pode bloquear um participante em nome do idoso, conforme as permissões previstas para o perfil familiar.
* O bloqueio aplica-se à conta do idoso.
* O participante é automaticamente removido da lista de amigos do idoso e removido de todos os grupos em comum com o idoso.
* O participante não poderá enviar novas mensagens, solicitações de amizade ou realizar outras interações com o idoso.
* O histórico de conversas permanece armazenado para fins de auditoria e alertas de segurança.

### Bloqueio do familiar pelo idoso

* O idoso poderá bloquear um familiar atualmente vinculado.
* Ao bloquear o familiar, o vínculo será encerrado imediatamente.
* O familiar perderá o acesso às informações e funcionalidades de acompanhamento do idoso.
* O bloqueio deverá ser registrado em log de auditoria quando aplicável.

## Central de ajuda

* O sistema deve disponibilizar orientações básicas de uso e informações relevantes para o usuário.
* A central de ajuda não deve oferecer canal de envio de solicitações de suporte.

## Notificações

* O sistema deve enviar notificações para eventos importantes, como:

  * solicitações de amizade;
  * aceite ou recusa de amizade;
  * novas mensagens;
  * convites e atualizações de grupos;
  * estabelecimento de vínculo familiar;
  * bloqueio ou encerramento de vínculo familiar, quando aplicável;
  * avisos importantes da plataforma.

### Notificação de vínculo familiar

Quando um familiar informar um `linkedElderEmail` válido e o vínculo for estabelecido automaticamente, o idoso deverá receber uma notificação informando que aquele familiar ou responsável passou a supervisioná-lo.

# Segurança / Regras operacionais (complemento)

* Apenas usuários confirmados como amigos podem trocar mensagens privadas entre si (regra válida entre usuários idosos). O familiar não participa do fluxo de troca privada habitual entre usuários.
* Sinalizações de segurança podem originar-se de conversas privadas (1:1) ou de grupos; o sistema deve registrar sinalizações e permitir a visualização por familiares conforme regras acima.
* Limitação de envio de solicitações de amizade (anti-spam):

  * Cada usuário pode enviar até 20 solicitações de amizade por período.
  * Ao atingir o limite, o sistema impede o envio de novas solicitações e exibe mensagem informando que o limite diário foi alcançado.
  * O envio de novas solicitações é liberado 24 horas após o momento em que o usuário atingiu o limite (janela móvel).
* Dados de nascimento e privacidade:

  * O sistema armazena a data de nascimento completa para cálculo de idade e validação interna.
  * Em perfis públicos será exibida apenas a faixa etária (ex.: 60–69); a data de nascimento completa não é exibida a outros usuários nem ao familiar.
* Auditoria e rastreabilidade:

  * Todas as ações relevantes realizadas pelo familiar, como visualização de informações autorizadas, alterações de configurações, marcação de alertas, bloqueios e desvinculação, devem ficar registradas em logs de auditoria.
* O sistema deve validar o `linkedElderEmail` antes de criar um vínculo familiar.
* Um vínculo familiar somente poderá ser criado quando o e-mail informado corresponder a uma conta de idoso válida.
* O sistema não deve criar solicitações de vínculo pendentes nem exigir aprovação ou recusa do idoso para estabelecer o vínculo.
* O idoso deve possuir mecanismo para interromper o vínculo por meio de bloqueio do familiar.
* Após o encerramento do vínculo, o familiar não poderá continuar acessando as informações ou funcionalidades de acompanhamento.

# Fluxos principais

1. Cadastro.
2. Login.
3. Recuperação de senha.
4. Criação e edição de perfil.
5. Busca de locais e atividades.
6. Envio e resposta de solicitações de amizade.
7. Conversa privada entre amigos.
8. Criação e participação em grupos.
9. Vinculação automática entre familiar e idoso por meio do `linkedElderEmail`.
10. Notificação do idoso após o estabelecimento do vínculo.
11. Bloqueio ou desvinculação do vínculo familiar.
12. Acesso à central de ajuda.
13. Recebimento de notificações.

# Regras de negócio

* O familiar ou responsável informa o `linkedElderEmail` para identificar o idoso que deseja supervisionar.
* O sistema deve validar o e-mail informado antes de estabelecer o vínculo.
* Quando o `linkedElderEmail` corresponder a uma conta de idoso válida, o vínculo familiar será estabelecido automaticamente.
* O estabelecimento do vínculo não depende de aprovação ou recusa do idoso.
* Após o estabelecimento do vínculo, o idoso deve receber uma notificação informando que o familiar ou responsável passou a supervisioná-lo.
* Cada idoso poderá possuir no máximo um familiar vinculado simultaneamente.
* Cada familiar poderá estar vinculado a no máximo um idoso simultaneamente.
* O idoso poderá bloquear o familiar vinculado para encerrar a supervisão.
* O familiar poderá remover o próprio vínculo.
* O encerramento do vínculo deve ocorrer imediatamente e interromper o acesso do familiar às informações e funcionalidades de acompanhamento.
* Apenas amigos confirmados podem trocar mensagens privadas.
* Usuários podem bloquear outros usuários para impedir novas interações.
* O sistema deve limitar o envio excessivo de solicitações de amizade para reduzir spam.
* O sistema deve priorizar notificações relevantes, evitando excesso de alertas.
* O familiar terá acesso apenas às funcionalidades e informações previstas para o seu perfil enquanto o vínculo estiver ativo.
* O sistema deverá reutilizar o `linkedElderEmail` e as estruturas existentes do projeto sempre que possível, evitando fluxos ou estruturas duplicadas.
* O sistema deverá respeitar a Lei Geral de Proteção de Dados (LGPD) durante o tratamento dos dados pessoais.

# Critérios de aceite

* O cadastro, login e recuperação de senha funcionam corretamente.
* O idoso consegue criar e editar seu perfil com informações pessoais e interesses.
* O usuário consegue localizar e visualizar detalhes de locais e atividades.
* O fluxo de amizade é concluído com sucesso por meio de aceite ou recusa.
* A troca de mensagens privadas funciona apenas entre amigos confirmados.
* Usuários idosos conseguem criar grupos e todos os usuários conseguem participar dos grupos disponíveis.
* O familiar consegue informar o `linkedElderEmail`.
* O sistema valida se o `linkedElderEmail` corresponde a uma conta de idoso válida.
* Quando o e-mail for válido, o vínculo familiar é criado automaticamente.
* O sistema não cria uma solicitação pendente nem exige aprovação ou recusa do idoso para estabelecer o vínculo.
* O idoso recebe uma notificação informando que o familiar ou responsável passou a supervisioná-lo após o estabelecimento do vínculo.
* O idoso consegue bloquear o familiar vinculado.
* O familiar consegue remover o próprio vínculo.
* Após o bloqueio ou desvinculação, o acesso do familiar às funcionalidades de acompanhamento é encerrado imediatamente.
* O sistema respeita a regra de no máximo um familiar por idoso e um idoso por familiar.
* As notificações são exibidas apenas para eventos relevantes.
* A central de ajuda apresenta orientações básicas de uso, sem oferecer canal de suporte.
* O sistema respeita as permissões de cada tipo de usuário (idoso e familiar).
* A interface implementada corresponde ao protótipo desenvolvido no Figma.
* A experiência atende aos requisitos de acessibilidade definidos para o MVP.
* O usuário consegue selecionar e visualizar seu avatar em seu perfil e nas demais telas da aplicação.
