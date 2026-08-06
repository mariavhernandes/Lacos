# Constitution do Projeto La�os

## Vis�o Geral

O La�os � uma plataforma composta por um aplicativo mobile e uma aplica��o web desenvolvidos em Flutter, destinada a combater o isolamento social entre pessoas idosas. A plataforma promove socializa��o, bem-estar e qualidade de vida, permitindo que idosos encontrem pessoas com interesses em comum, participem de grupos, conversem por chat e descubram locais de lazer adequados �s suas prefer�ncias.

O sistema tamb�m oferece uma �rea para familiares ou respons�veis, permitindo o acompanhamento das informa��es autorizadas pelo idoso, melhorando a seguran�a e a tranquilidade da fam�lia.

## Objetivo

A Constitution define as regras, o escopo e os princ�pios que reger�o o desenvolvimento da primeira vers�o do La�os, com foco no MVP, no p�blico idoso e nos familiares ou respons�veis.

## P�blico-Alvo

- P�blico principal: pessoas da terceira idade que desejam ampliar seu c�rculo social e participar de atividades presenciais.
- P�blico secund�rio: familiares e respons�veis que desejam acompanhar e apoiar o uso da plataforma de forma segura.

## Escopo da Primeira Vers�o

A primeira vers�o do La�os dever� priorizar as funcionalidades essenciais que promovam socializa��o e acompanhamento seguro, entregues de forma simples, acess�vel e segura.

### Funcionalidades para idosos

- Cadastro e login de usu�rios.
- Recupera��o de senha.
- Cria��o e edi��o de perfil com informa��es pessoais e interesses.
- Pesquisa de locais de lazer e atividades voltadas � terceira idade, com filtros por categoria e localiza��o.
- Visualiza��o de informa��es detalhadas dos locais de lazer (descri��o, endere�o, hor�rio de funcionamento e avalia��es).
- Sistema de sugest�es de amizades baseado em interesses em comum.
- Chat privado por mensagens de texto entre usuários amigos.
- Cria��o e participa��o em grupos de interesse.
- Sistema de notifica��es.
- Central de ajuda.

### Funcionalidades para familiares ou respons�veis

- Cadastro e login.
- Associa��o ao perfil do idoso mediante autoriza��o expl�cita.
- Visualiza��o das informa��es autorizadas pelo idoso.
- Gerenciamento de contatos.
- Recebimento de notifica��es relacionadas � seguran�a.
- Configura��o de prefer�ncias de acompanhamento.

## Regras de Privacidade e Autoriza��o

- O idoso � o propriet�rio de seus dados e controla a vincula��o de familiares ou respons�veis � sua conta.
- O v�nculo somente ser� estabelecido mediante autoriza��o expl�cita do idoso, que poder� aceitar ou recusar a solicita��o.
- Ap�s aprova��o, o familiar ter� acesso �s informa��es e funcionalidades padronizadas pelo sistema para seu perfil.
- As informa��es dispon�veis ao familiar ser�o somente aquelas necess�rias para promover seguran�a e acompanhamento, respeitando a LGPD.
- Dados sens�veis como senha, credenciais de acesso e demais informa��es restritas permanecer�o inacess�veis a outros usu�rios.

## Tecnologias e Integra��es

- Plataforma mobile: Flutter para Android e iOS.
- Aplica��o web responsiva: Flutter Web.
- Linguagem: Dart.
Backend e banco de dados: Firebase Authentication e Cloud Firestore para autenticação e gerenciamento dos dados internos da aplicação. Para a funcionalidade de descoberta de locais e atividades, o sistema utilizará uma API externa como fonte de dados.
- Integra��es: servi�o de mapas para exibi��o de locais de lazer e atividades; notifica��es push para avisos, solicita��es de v�nculo, mensagens e atualiza��es.
- IDE: Visual Studio Code.
- Versionamento: GitHub.
- Assistente de desenvolvimento: GitHub Copilot.
- Metodologia: Spec-Driven Development (SDD).
- Recursos gráficos da aplicação (ícones, ilustrações e avatares) serão incluídos como assets do Flutter.

## Qualidade de Experi�ncia

### Usabilidade

- Interface simples, intuitiva e consistente.
- Navega��o com poucos passos para a��es importantes.
- Bot�es grandes e f�ceis de selecionar.
- Linguagem clara e objetiva, sem termos t�cnicos.
- Feedback visual para todas as a��es (confirma��es, erros e carregamentos).
- Fidelidade ao prot�tipo no Figma.

### Acessibilidade

- Fontes leg�veis com possibilidade de amplia��o.
- Alto contraste entre textos e elementos.
- �cones acompanhados de textos explicativos sempre que poss�vel.
- �reas de toque amplas.
- Compatibilidade com recursos de acessibilidade de Android, iOS e navegadores.

### Desempenho

- Tempo de carregamento reduzido para telas principais.
- Navega��o fluida entre telas.
- Consultas ao banco de dados otimizadas.
- Recursos gráficos locais (assets) para reduzir dependência de serviços externos.
- Funcionalidade responsiva na web.

## Exclus�es do MVP

Ficam fora do escopo da primeira vers�o do La�os:

- Chamadas de �udio e v�deo entre usu�rios.
- Chat de ajuda baseado em intelig�ncia artificial.
- Compartilhamento de localiza��o em tempo real.

## Regras de Relacionamento Social

- A conex�o entre idosos ser� baseada em solicita��o e aceita��o de amizade.
- Um usu�rio pode enviar solicita��o de amizade para outro.
- O destinat�rio pode aceitar ou recusar a solicita��o.
- Apenas amigos confirmados podem trocar mensagens privadas.
- Usu�rios podem participar de grupos de interesse para conhecer novas pessoas.
- O sistema sugere amizades com base em interesses, faixa et�ria semelhante, cidade/regi�o e participa��o em grupos ou atividades em comum.
- Usu�rios podem bloquear outros usu�rios. Ap�s o bloqueio:
  - N�o � poss�vel enviar novas solicita��es de amizade.
  - N�o � poss�vel trocar mensagens pelo chat.
  - O usu�rio bloqueado n�o pode visualizar determinadas intera��es privadas.

## Notifica��es

As notifica��es devem ser utilizadas apenas para eventos importantes, evitando excesso de alertas.

### Para idosos

- Recebimento de solicita��o de amizade.
- Aceita��o de solicita��o de amizade.
- Novas mensagens no chat.
- Convites ou atualiza��es de grupos.
- Solicita��es de v�nculo enviadas por familiares ou respons�veis.
- Avisos importantes da plataforma.

### Para familiares ou respons�veis

- Aprova��o ou recusa da solicita��o de v�nculo pelo idoso.
- Alertas de seguran�a do sistema.
- Avisos importantes relacionados ao perfil do idoso.
- Comunicados da plataforma.

### Diretrizes de envio

- Enviar apenas notifica��es relevantes.
- Agrupar notifica��es repetidas sempre que poss�vel.
- Exibir mensagens claras e objetivas.

## Crit�rios de Aceita��o

Uma funcionalidade ser� considerada conclu�da quando:

- Estiver implementada conforme a especifica��o da etapa Specify.
- Atender aos requisitos funcionais e n�o funcionais.
- Seguir fielmente o prot�tipo do Figma.
- Estiver integrada corretamente ao Firebase Authentication, Cloud Firestore e Firebase Cloud Messaging quando necessário. A funcionalidade de descoberta de locais e atividades deverá consumir os dados por meio de uma API externa.
- Funcionar corretamente em Flutter Mobile e Flutter Web.
- Apresentar interface acess�vel e intuitiva.
- N�o apresentar erros de execu��o ou falhas cr�ticas.
- Seguir os padr�es de c�digo e arquitetura da equipe.
- For revisada por outro integrante antes da integra��o � branch principal.
- For aprovada na Checklist do SDD antes da implementa��o final.

### Indicadores de sucesso

- Implementa��o de todas as funcionalidades previstas para o MVP.
- Compatibilidade entre mobile e web.
- Interface fiel ao prot�tipo.
- Navega��o simples e intuitiva.
- Integração completa com Firebase Authentication, Cloud Firestore e Firebase Cloud Messaging.
- C�digo organizado, reutiliz�vel e documentado.
- Desenvolvimento seguindo as etapas do Spec-Driven Development.

## Processo de Acesso

### Cadastro

- O usu�rio escolhe entre criar conta como Idoso ou Familiar/Respons�vel.
- O cadastro solicita apenas as informa��es necess�rias: nome, data de nascimento, e-mail, senha e dados do perfil.
- Durante o cadastro do idoso, � poss�vel informar interesses.
- Ap�s concluir o cadastro, o usu�rio acessa imediatamente a plataforma.

### Login

- Acesso com e-mail e senha via Firebase Authentication.

### Recupera��o de senha

- O usu�rio pede recupera��o informando o e-mail cadastrado.
- Ser� enviado um link de redefini��o de senha por e-mail.

### Primeiro acesso

- O usu�rio recebe uma breve introdu��o sobre as funcionalidades.
- Em seguida, � direcionado para a tela inicial.

### Vincula��o idoso-familiar

- O familiar envia solicita��o de v�nculo ao idoso.
- O idoso aceita ou recusa.
- Ap�s aprova��o, o v�nculo � estabelecido e o familiar recebe acesso �s funcionalidades previstas.

## Seguran�a e Modera��o

- Usu�rios podem bloquear outros para impedir intera��es, solicita��es de amizade e mensagens.
- Apenas amigos confirmados podem enviar mensagens privadas.
- Solicita��es de amizade podem ser aceitas ou recusadas.
- O sistema limita o envio excessivo de solicita��es em curto per�odo para reduzir spam.
- Links suspeitos ou n�o autorizados podem ser bloqueados pelo sistema.
- Familiares t�m acesso apenas �s funcionalidades previstas para o seu perfil.
- Todas as intera��es devem respeitar as pol�ticas de uso da plataforma e a LGPD.
- Modera��o autom�tica avan�ada e sistemas complexos de den�ncias s�o previstos para vers�es futuras.

## Pr�ticas de Desenvolvimento

- O desenvolvimento segue a metodologia SDD: Constitution, Specify, Clarify, Plan, Tasks, Analyze, Checklist e Implement.
- Nenhuma funcionalidade ser� implementada antes da aprova��o de sua especifica��o.
- O desenvolvimento ser� incremental, priorizando o MVP.
- GitHub ser� usado para versionamento.
- Cada funcionalidade ser� desenvolvida em branch pr�pria (`feature/nome-da-funcionalidade`).
- Altera��es diretas na branch `main` s�o proibidas.
- Integra��o por Pull Requests revisados por pelo menos um integrante.
- C�digo deve seguir padr�es definidos pela equipe e ser organizado, leg�vel e reutiliz�vel.
- Mobile e web devem compartilhar o m�ximo de c�digo poss�vel.
- Regras de neg�cio centralizadas para evitar comportamentos diferentes entre plataformas.
- Integração com Firebase Authentication, Cloud Firestore e Firebase Cloud Messaging testada antes do merge.
- Documenta��o atualizada sempre que houver altera��es relevantes.

## Idioma

- O MVP ser� lan�ado apenas em portugu�s.
