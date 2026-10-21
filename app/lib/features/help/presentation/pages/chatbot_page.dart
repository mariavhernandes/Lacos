import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  String? _userRole;

  bool _isSending = false;
  final List<Map<String, String>> _conversation = [];

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedTopic;
  String? _selectedQuestion;
  bool _isFreeChat = false;

  final Map<String, List<String>> _elderlyTopics = {
    'Meu perfil': [
      'Como criar meu perfil?',
      'Como alterar meu perfil?',
      'Como alterar minha foto?',
      'Como adicionar ou alterar meus interesses?',
      'Quais informações aparecem no meu perfil?',
      'Como funciona a privacidade das minhas informações?',
    ],
    'Amizades': [
      'Como encontrar uma pessoa?',
      'Como adicionar uma pessoa?',
      'Como aceitar uma solicitação de amizade?',
      'Como recusar uma solicitação de amizade?',
      'Como encontrar pessoas com interesses em comum?',
    ],
    'Conversas': [
      'Como iniciar uma conversa?',
      'Quem pode conversar comigo?',
      'Como enviar uma mensagem?',
    ],
    'Grupos': [
      'Como encontrar um grupo?',
      'Como participar de um grupo?',
      'Como criar um grupo?',
      'Como sair de um grupo?',
      'Como enviar uma mensagem no grupo?',
    ],
    'Interesses e atividades': [
      'Como encontrar locais de lazer e atividades?',
      'Como pesquisar um local?',
      'Como visualizar as informações de um local?',
    ],
    'Encontros e lazer': [
      'Posso marcar um encontro pelo aplicativo?',
    ],
    'Notificações': [
      'Onde posso ver minhas notificações?',
      'Como saber se alguém começou a me seguir?',
      'Por que recebi uma notificação sobre meu vínculo familiar?',
    ],
    'Vínculo familiar': [
      'O que é o vínculo familiar?',
      'Como saber se um familiar está vinculado à minha conta?',
      'Como bloquear o acompanhamento de um familiar?',
      'O que acontece quando bloqueio meu familiar?',
      'Como encerrar o vínculo familiar?',
    ],
    'Segurança': [
      'Como bloquear uma pessoa no chat?',
      'O que acontece quando bloqueio alguém?',
      'O que são alertas de segurança?',
      'O que fazer quando encontro uma situação suspeita?',
    ],
  };

  final Map<String, List<String>> _familyTopics = {
    'Perfil do idoso': [
      'Quais informações do idoso posso visualizar?',
      'Posso alterar o perfil do idoso?',
      'Quais informações pessoais não devem ser compartilhadas?',
    ],
    'Vínculo familiar': [
      'Como vincular um idoso?',
      'O vínculo precisa de aprovação do idoso?',
      'Como saber se o vínculo foi estabelecido?',
      'O idoso pode bloquear o acompanhamento?',
      'Posso remover meu vínculo como familiar?',
    ],
    'Acompanhamento': [
      'O que aparece no resumo do familiar?',
      'Posso ver a localização do idoso?',
      'Posso acessar as conversas do idoso?',
    ],
    'Segurança e alertas': [
      'Que alertas de segurança existem no aplicativo?',
      'O que posso fazer diante de uma situação suspeita?',
    ],
    'Notificações': [
      'Quais notificações do vínculo familiar posso receber?',
    ],
    'Privacidade e permissões': [
      'Posso fazer ações em nome do idoso?',
      'Quais dados do idoso são privados?',
    ],
  };

  final Map<String, IconData> _topicIcons = {
    'Meu perfil': Icons.person_outline,
    'Perfil do idoso': Icons.person_outline,
    'Amizades': Icons.people_outline,
    'Conversas': Icons.chat_bubble_outline,
    'Grupos': Icons.groups_outlined,
    'Interesses e atividades': Icons.interests_outlined,
    'Encontros e lazer': Icons.location_on_outlined,
    'Notificações': Icons.notifications_none,
    'Vínculo familiar': Icons.family_restroom_outlined,
    'Acompanhamento': Icons.visibility_outlined,
    'Segurança': Icons.shield_outlined,
    'Segurança e alertas': Icons.shield_outlined,
    'Privacidade e permissões': Icons.lock_outline,
  };

  final Map<String, String> _answers = {
    'Como criar meu perfil?':
        'No cadastro, escolha o perfil Idoso e preencha as informações solicitadas. Depois, entre no aplicativo com seu e-mail e senha.',
    'Como alterar meu perfil?':
        'Abra Perfil e toque em Editar perfil. Ali você encontra as opções disponíveis para atualizar seus dados.',
    'Como alterar minha foto?':
        'Em Perfil, toque em Editar perfil e escolha um dos avatares disponíveis.',
    'Como adicionar ou alterar meus interesses?':
        'Abra Perfil, toque em Editar perfil e depois em Interesses. Escolha os interesses e salve as alterações.',
    'Quais informações aparecem no meu perfil?':
        'Seu perfil mostra seu nome, avatar, cidade, biografia e interesses cadastrados. O que aparece depende dos dados preenchidos.',
    'Como funciona a privacidade das minhas informações?':
        'Suas informações pessoais devem ser tratadas com cuidado. Evite compartilhar senhas, códigos de acesso ou outros dados confidenciais. Você pode consultar as opções disponíveis no seu perfil para conhecer as informações cadastradas.',
    'Como encontrar uma pessoa?':
        'Na tela Início, veja as sugestões de pessoas. Toque em uma delas para abrir o perfil.',
    'Como adicionar uma pessoa?':
        'No perfil público, o botão disponível é Seguir. Não encontrei nessa tela o envio de uma solicitação de amizade.',
    'Como aceitar uma solicitação de amizade?':
        'A documentação prevê aceitar solicitações, mas não encontrei uma tela no aplicativo para fazer isso. Esse passo precisa ser conferido antes de contar com ele.',
    'Como recusar uma solicitação de amizade?':
        'A documentação prevê recusar solicitações, mas não encontrei uma tela no aplicativo para fazer isso. Esse passo precisa ser conferido antes de contar com ele.',
    'Como encontrar pessoas com interesses em comum?':
        'Na tela Início, consulte as sugestões de pessoas. Use a busca dessa tela para procurar por nome, cidade ou interesse.',
    'Como iniciar uma conversa?':
        'Abra o perfil da pessoa e toque no botão de conversa. A documentação prevê conversas entre amigos, mas não encontrei uma verificação de amizade antes de abrir o chat nesta versão.',
    'Quem pode conversar comigo?':
        'A documentação prevê conversas privadas entre amigos confirmados. Como o aplicativo não confirma essa condição antes de abrir um chat, não posso garantir que essa regra esteja sendo aplicada.',
    'Como enviar uma mensagem?':
        'Abra a conversa, escreva sua mensagem no campo na parte de baixo da tela e toque em enviar. O chat aceita mensagens de texto.',
    'Como encontrar um grupo?':
        'A tela Conversas mostra os grupos dos quais você participa. Não encontrei um catálogo para pesquisar grupos públicos.',
    'Como participar de um grupo?':
        'Não encontrei no aplicativo uma tela para procurar e entrar em grupos disponíveis. A documentação prevê essa função, mas ela precisa ser conferida na versão atual.',
    'Como criar um grupo?':
        'Em Conversas, toque no botão com o sinal de mais. Informe o nome, escolha uma foto e selecione pelo menos uma pessoa.',
    'Como sair de um grupo?':
        'Abra o grupo, entre nas informações do grupo e escolha a opção para sair.',
    'Como enviar uma mensagem no grupo?':
        'Abra o grupo, escreva no campo de mensagem e toque em enviar.',
    'Como encontrar locais de lazer e atividades?':
        'Abra a tela de locais, pesquise pelo nome ou escolha a categoria Lazer. A lista mostra os locais cadastrados para cada cidade disponível.',
    'Como pesquisar um local?':
        'Na tela de locais, use Pesquisar lugares para buscar por nome. Toque em Filtrar para escolher uma categoria ou cidade.',
    'Como visualizar as informações de um local?':
        'Toque no cartão do local para abrir os detalhes disponíveis, como descrição, endereço e horário de funcionamento.',
    'Posso marcar um encontro pelo aplicativo?':
        'Não encontrei uma agenda ou um botão para marcar encontros. A documentação prevê combinar atividades, mas essa função não está confirmada na versão atual. O chat permite conversar por texto.',
    'Onde posso ver minhas notificações?':
        'Abra Notificações no menu inferior. A tela mostra os avisos disponíveis para sua conta.',
    'Como saber se alguém começou a me seguir?':
        'Quando alguém começa a seguir você, o aplicativo pode mostrar um aviso em Notificações.',
    'Por que recebi uma notificação sobre meu vínculo familiar?':
        'O aviso informa que um familiar foi vinculado, que o acompanhamento foi bloqueado ou que foi reativado.',
    'O que é o vínculo familiar?':
        'É a ligação entre sua conta e a de um familiar. Quando ele informa seu e-mail no cadastro e a conta é encontrada, o vínculo é criado automaticamente, sem uma etapa de aprovação.',
    'Como saber se um familiar está vinculado à minha conta?':
        'Confira Notificações. Quando o vínculo é criado, você recebe um aviso com o nome do familiar.',
    'Como bloquear o acompanhamento de um familiar?':
        'Abra a notificação do vínculo familiar e toque em Bloquear familiar. O aplicativo pede confirmação antes de interromper o acompanhamento.',
    'O que acontece quando bloqueio meu familiar?':
        'O familiar deixa de ver o painel de acompanhamento e recebe um aviso. Você pode reativar o vínculo depois, pela notificação, usando Desbloquear familiar.',
    'Como encerrar o vínculo familiar?':
        'Não encontrei uma opção para remover o vínculo de forma permanente. Para interromper o acompanhamento, use Bloquear familiar em Notificações; essa ação pode ser desfeita depois.',
    'Como bloquear uma pessoa no chat?':
        'Abra a conversa, toque nas informações da conversa e escolha Bloquear usuário. O aplicativo informa que a pessoa não poderá enviar mensagens para você.',
    'O que acontece quando bloqueio alguém?':
        'O bloqueio disponível é da conversa privada: a pessoa deixa de poder enviar mensagens nessa conversa. Não encontrei confirmação de que ele bloqueie pedidos de amizade ou interações em grupos.',
    'O que são alertas de segurança?':
        'A tela Gerenciar Mensagens mostra exemplos de alertas, mas não encontrei detecção real de riscos ou avisos ligados a conversas nesta versão. Não trate os exemplos da tela como alertas confirmados.',
    'O que fazer quando encontro uma situação suspeita?':
        'Não compartilhe senhas, códigos ou dados bancários. Se houver uma conversa privada, você pode abrir as informações dela e escolher Bloquear usuário. Não encontrei um botão para denunciar a situação.',
    'Quais informações do idoso posso visualizar?':
        'A documentação prevê nome, foto, faixa etária, cidade, estado, interesses, amizades, grupos, atividades confirmadas e conversas sinalizadas. A tela atual mostra um resumo de acompanhamento; não consegui confirmar que todos esses dados ou limites estejam aplicados.',
    'Posso alterar o perfil do idoso?':
        'Não. O perfil do familiar oferece edição dos próprios dados. Não encontrei uma opção para alterar o perfil do idoso.',
    'Quais informações pessoais não devem ser compartilhadas?':
        'A documentação prevê que senha, e-mail, telefone e data de nascimento completa não sejam exibidos ao familiar. Não consigo confirmar esse bloqueio no aplicativo atual; evite compartilhar dados sensíveis até que as permissões sejam verificadas.',
    'Como vincular um idoso?':
        'No cadastro de Familiar, informe o e-mail usado pelo idoso no Laços. Se a conta for encontrada e ainda puder ser vinculada, o vínculo é criado automaticamente.',
    'O vínculo precisa de aprovação do idoso?':
        'Não. O cadastro cria o vínculo automaticamente quando encontra uma conta válida. O idoso recebe uma notificação e pode bloquear o acompanhamento.',
    'Como saber se o vínculo foi estabelecido?':
        'Na conta do familiar, a tela Início mostra o nome do idoso vinculado. O idoso também recebe uma notificação sobre o novo vínculo.',
    'O idoso pode bloquear o acompanhamento?':
        'Sim. Na notificação do vínculo, o idoso pode tocar em Bloquear familiar e confirmar a ação.',
    'Posso remover meu vínculo como familiar?':
        'A documentação prevê que o familiar possa encerrar o vínculo, mas não encontrei essa opção no aplicativo. Nesta versão, o idoso pode bloquear o acompanhamento pela tela Notificações.',
    'O que aparece no resumo do familiar?':
        'A tela Início mostra o nome do idoso e um resumo de conversas, última interação e atividade recente. Não encontrei ali uma lista completa de amizades, grupos e atividades confirmadas.',
    'Posso ver a localização do idoso?':
        'Não encontrei compartilhamento da localização do idoso. A documentação diz que a localização em tempo real não faz parte desta versão.',
    'Posso acessar as conversas do idoso?':
        'A documentação prevê acesso apenas a conversas sinalizadas por alertas. Como não encontrei um fluxo funcional de alertas e revisão de conversas, não posso confirmar esse acesso no aplicativo atual.',
    'Que alertas de segurança existem no aplicativo?':
        'A tela Gerenciar Mensagens contém exemplos prontos, mas os botões de verificação não executam uma ação e os alertas não vêm de uma análise real. A documentação também deixa a geração automática para uma versão futura.',
    'O que posso fazer diante de uma situação suspeita?':
        'Não encontrei no perfil familiar uma ação para denunciar, bloquear alguém em nome do idoso ou resolver um alerta. A tela de alertas é demonstrativa; não conte com ela como proteção ativa.',
    'Quais notificações do vínculo familiar posso receber?':
        'O familiar recebe avisos quando o idoso bloqueia ou reativa o acompanhamento. Não encontrei confirmação de notificações de alertas de segurança nesta versão.',
    'Posso fazer ações em nome do idoso?':
        'A documentação diz que o familiar não pode editar o perfil, enviar mensagens nem enviar pedidos de amizade pelo idoso. Não encontrei essas ações disponíveis no perfil familiar.',
    'Quais dados do idoso são privados?':
        'A documentação trata senha, credenciais, e-mail, telefone e data de nascimento completa como dados privados. As regras atuais do aplicativo não permitem confirmar que esse limite seja aplicado em todos os acessos.',
  };

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final uid = AuthService.currentUser?.uid;

    if (uid == null) return;

    final role = await AuthService.getUserRole(uid);

    if (!mounted) return;

    setState(() {
      _userRole = role;
    });
  }

  void _selectTopic(String topic) {
    setState(() {
      _selectedTopic = topic;
      _selectedQuestion = null;
    });

    _scrollToBottom();
  }

  void _selectQuestion(String question) {
    setState(() {
      _selectedQuestion = question;
    });

    _scrollToBottom();
  }

  void _goBack() {
    setState(() {
      if (_isFreeChat) {
        _isFreeChat = false;
        _conversation.clear();
      } else if (_selectedQuestion != null) {
        _selectedQuestion = null;
      } else if (_selectedTopic != null) {
        _selectedTopic = null;
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isFreeChat = true;
      _selectedTopic = null;
      _selectedQuestion = null;
      _isSending = true;

      _conversation.add({
        'role': 'user',
        'text': message,
      });
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final response = await http
          .post(
            Uri.parse('http://localhost:3000/api/chatbot.php'),
            headers: {'Content-Type': 'application/json; charset=utf-8'},
            body: jsonEncode({'message': message}),
          )
          .timeout(const Duration(seconds: 40));

      debugPrint('STATUS HTTP: ${response.statusCode}');
      debugPrint('RESPOSTA BRUTA DO PHP: ${response.body}');

      final data = jsonDecode(utf8.decode(response.bodyBytes));

      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['success'] == true &&
          data['answer'] is String) {
        if (!mounted) return;

        setState(() {
          _conversation.add({
            'role': 'bot',
            'text': data['answer'] as String,
          });
        });
      } else {
        throw Exception(
          data is Map<String, dynamic>
              ? data['message'] ?? 'Não foi possível obter uma resposta.'
              : 'Resposta inválida do servidor.',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Erro ao enviar mensagem ao Assistente Laços: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _conversation.add({
          'role': 'bot',
          'text':
              'Não consegui responder agora. Verifique sua conexão e tente novamente.',
        });
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final topics = _userRole == 'familiar' ? _familyTopics : _elderlyTopics;

    final questions =
        _selectedTopic == null ? <String>[] : topics[_selectedTopic] ?? [];

    final answer = _selectedQuestion == null
        ? null
        : _answers[_selectedQuestion] ??
            'Esta informação ainda precisa ser confirmada no aplicativo.';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_isFreeChat ||
                          _selectedQuestion != null ||
                          _selectedTopic != null) {
                        _goBack();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Image.asset(
                      'assets/icons/navigation/back_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDCEAF5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF033B63),
                          ),
                        );
                      },
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Assistente Laços',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF555555),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBotMessage(
                      'Olá! Eu sou o Assistente Laços. '
                      'Como posso ajudar você?',
                    ),
                    const SizedBox(height: 20),
                    ..._conversation.map((message) {
                      if (message['role'] == 'user') {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildUserMessage(message['text'] ?? ''),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _buildBotMessage(message['text'] ?? ''),
                      );
                    }),
                    if (_isSending)
                      _buildBotMessage('Estou preparando uma resposta...'),
                    const SizedBox(height: 20),
                    if (_isFreeChat) ...[
                      const SizedBox.shrink(),
                    ] else if (_selectedTopic == null) ...[
                      const Text(
                        'Escolha um assunto:',
                        style: TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...topics.keys.map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildTopicButton(topic),
                        ),
                      ),
                    ] else if (_selectedQuestion == null) ...[
                      GestureDetector(
                        onTap: _goBack,
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: Color(0xFF033B63),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Voltar aos assuntos',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF033B63),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        _selectedTopic!,
                        style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...questions.map(
                        (question) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildQuestionButton(question),
                        ),
                      ),
                    ] else ...[
                      GestureDetector(
                        onTap: _goBack,
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Icon(
                                Icons.arrow_back_ios_new,
                                size: 16,
                                color: Color(0xFF033B63),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Voltar para as perguntas',
                                style: TextStyle(
                                  fontFamily: 'Raleway',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF033B63),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      _buildUserMessage(_selectedQuestion!),
                      const SizedBox(height: 10),
                      _buildBotMessage(answer!),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      cursorColor: const Color(0xFF8A8A8A),
                      style: const TextStyle(
                        color: Color(0xFF8A8A8A),
                        fontSize: 14,
                        fontFamily: 'Quicksand',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Digite sua dúvida...',
                        hintStyle: const TextStyle(
                          color: Color(0xFFB8B8B8),
                          fontSize: 15,
                          fontFamily: 'Quicksand',
                        ),
                        filled: true,
                        fillColor: const Color(0xFFEAEAEA),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Image.asset(
                      'assets/images/elderly/send.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicButton(String topic) {
    final icon = _topicIcons[topic] ?? Icons.help_outline;

    return GestureDetector(
      onTap: () => _selectTopic(topic),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFDCEAF5),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFDCEAF5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF033B63),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                topic,
                style: const TextStyle(
                  fontFamily: 'Raleway',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF033B63),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF4C7296),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionButton(String question) {
    return GestureDetector(
      onTap: () => _selectQuestion(question),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFDCEAF5),
          ),
        ),
        child: Text(
          question,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF033B63),
          ),
        ),
      ),
    );
  }

  Widget _buildBotMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFDCEAF5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF333333),
          ),
        ),
      ),
    );
  }

  Widget _buildUserMessage(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 13,
        ),
        constraints: const BoxConstraints(
          maxWidth: 320,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF033B63),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Raleway',
            fontSize: 14,
            height: 1.4,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}