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
      'Quais informaÃ§Ãµes aparecem no meu perfil?',
      'Como funciona a privacidade das minhas informaÃ§Ãµes?',
    ],
    'Amizades': [
      'Como encontrar uma pessoa?',
      'Como adicionar uma pessoa?',
      'Como aceitar uma solicitaÃ§Ã£o de amizade?',
      'Como recusar uma solicitaÃ§Ã£o de amizade?',
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
      'Como visualizar as informaÃ§Ãµes de um local?',
    ],
    'Encontros e lazer': [
      'Posso marcar um encontro pelo aplicativo?',
    ],
    'NotificaÃ§Ãµes': [
      'Onde posso ver minhas notificaÃ§Ãµes?',
      'Como saber se alguÃ©m comeÃ§ou a me seguir?',
      'Por que recebi uma notificaÃ§Ã£o sobre meu vÃ­nculo familiar?',
    ],
    'VÃ­nculo familiar': [
      'O que Ã© o vÃ­nculo familiar?',
      'Como saber se um familiar estÃ¡ vinculado Ã  minha conta?',
      'Como bloquear o acompanhamento de um familiar?',
      'O que acontece quando bloqueio meu familiar?',
      'Como encerrar o vÃ­nculo familiar?',
    ],
    'SeguranÃ§a': [
      'Como bloquear uma pessoa no chat?',
      'O que acontece quando bloqueio alguÃ©m?',
      'O que sÃ£o alertas de seguranÃ§a?',
      'O que fazer quando encontro uma situaÃ§Ã£o suspeita?',
    ],
  };

  final Map<String, List<String>> _familyTopics = {
    'Perfil do idoso': [
      'Quais informaÃ§Ãµes do idoso posso visualizar?',
      'Posso alterar o perfil do idoso?',
      'Quais informaÃ§Ãµes pessoais nÃ£o devem ser compartilhadas?',
    ],
    'VÃ­nculo familiar': [
      'Como vincular um idoso?',
      'O vÃ­nculo precisa de aprovaÃ§Ã£o do idoso?',
      'Como saber se o vÃ­nculo foi estabelecido?',
      'O idoso pode bloquear o acompanhamento?',
      'Posso remover meu vÃ­nculo como familiar?',
    ],
    'Acompanhamento': [
      'O que aparece no resumo do familiar?',
      'Posso ver a localizaÃ§Ã£o do idoso?',
      'Posso acessar as conversas do idoso?',
    ],
    'SeguranÃ§a e alertas': [
      'Que alertas de seguranÃ§a existem no aplicativo?',
      'O que posso fazer diante de uma situaÃ§Ã£o suspeita?',
    ],
    'NotificaÃ§Ãµes': [
      'Quais notificaÃ§Ãµes do vÃ­nculo familiar posso receber?',
    ],
    'Privacidade e permissÃµes': [
      'Posso fazer aÃ§Ãµes em nome do idoso?',
      'Quais dados do idoso sÃ£o privados?',
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
    'NotificaÃ§Ãµes': Icons.notifications_none,
    'VÃ­nculo familiar': Icons.family_restroom_outlined,
    'Acompanhamento': Icons.visibility_outlined,
    'SeguranÃ§a': Icons.shield_outlined,
    'SeguranÃ§a e alertas': Icons.shield_outlined,
    'Privacidade e permissÃµes': Icons.lock_outline,
  };

  final Map<String, String> _answers = {
    'Como criar meu perfil?':
        'No cadastro, escolha o perfil Idoso e preencha as informaÃ§Ãµes solicitadas. Depois, entre no aplicativo com seu e-mail e senha.',
    'Como alterar meu perfil?':
        'Abra Perfil e toque em Editar perfil. Ali vocÃª encontra as opÃ§Ãµes disponÃ­veis para atualizar seus dados.',
    'Como alterar minha foto?':
        'Em Perfil, toque em Editar perfil e escolha um dos avatares disponÃ­veis.',
    'Como adicionar ou alterar meus interesses?':
        'Abra Perfil, toque em Editar perfil e depois em Interesses. Escolha os interesses e salve as alteraÃ§Ãµes.',
    'Quais informaÃ§Ãµes aparecem no meu perfil?':
        'Seu perfil mostra seu nome, avatar, cidade, biografia e interesses cadastrados. O que aparece depende dos dados preenchidos.',
    'Como funciona a privacidade das minhas informaÃ§Ãµes?':
    'Suas informaÃ§Ãµes pessoais devem ser tratadas com cuidado. Evite compartilhar senhas, cÃ³digos de acesso ou outros dados confidenciais. VocÃª pode consultar as opÃ§Ãµes disponÃ­veis no seu perfil para conhecer as informaÃ§Ãµes cadastradas.',
    'Como encontrar uma pessoa?':
        'Na tela InÃ­cio, veja as sugestÃµes de pessoas. Toque em uma delas para abrir o perfil.',
    'Como adicionar uma pessoa?':
        'No perfil pÃºblico, o botÃ£o disponÃ­vel Ã© Seguir. NÃ£o encontrei nessa tela o envio de uma solicitaÃ§Ã£o de amizade.',
    'Como aceitar uma solicitaÃ§Ã£o de amizade?':
        'A documentaÃ§Ã£o prevÃª aceitar solicitaÃ§Ãµes, mas nÃ£o encontrei uma tela no aplicativo para fazer isso. Esse passo precisa ser conferido antes de contar com ele.',
    'Como recusar uma solicitaÃ§Ã£o de amizade?':
        'A documentaÃ§Ã£o prevÃª recusar solicitaÃ§Ãµes, mas nÃ£o encontrei uma tela no aplicativo para fazer isso. Esse passo precisa ser conferido antes de contar com ele.',
    'Como encontrar pessoas com interesses em comum?':
        'Na tela InÃ­cio, consulte as sugestÃµes de pessoas. Use a busca dessa tela para procurar por nome, cidade ou interesse.',
    'Como iniciar uma conversa?':
        'Abra o perfil da pessoa e toque no botÃ£o de conversa. A documentaÃ§Ã£o prevÃª conversas entre amigos, mas nÃ£o encontrei uma verificaÃ§Ã£o de amizade antes de abrir o chat nesta versÃ£o.',
    'Quem pode conversar comigo?':
        'A documentaÃ§Ã£o prevÃª conversas privadas entre amigos confirmados. Como o aplicativo nÃ£o confirma essa condiÃ§Ã£o antes de abrir um chat, nÃ£o posso garantir que essa regra esteja sendo aplicada.',
    'Como enviar uma mensagem?':
        'Abra a conversa, escreva sua mensagem no campo na parte de baixo da tela e toque em enviar. O chat aceita mensagens de texto.',
    'Como encontrar um grupo?':
        'A tela Conversas mostra os grupos dos quais vocÃª participa. NÃ£o encontrei um catÃ¡logo para pesquisar grupos pÃºblicos.',
    'Como participar de um grupo?':
        'NÃ£o encontrei no aplicativo uma tela para procurar e entrar em grupos disponÃ­veis. A documentaÃ§Ã£o prevÃª essa funÃ§Ã£o, mas ela precisa ser conferida na versÃ£o atual.',
    'Como criar um grupo?':
        'Em Conversas, toque no botÃ£o com o sinal de mais. Informe o nome, escolha uma foto e selecione pelo menos uma pessoa.',
    'Como sair de um grupo?':
        'Abra o grupo, entre nas informaÃ§Ãµes do grupo e escolha a opÃ§Ã£o para sair.',
    'Como enviar uma mensagem no grupo?':
        'Abra o grupo, escreva no campo de mensagem e toque em enviar.',
    'Como encontrar locais de lazer e atividades?':
        'Abra a tela de locais, pesquise pelo nome ou escolha a categoria Lazer. A lista mostra os locais cadastrados para cada cidade disponÃ­vel.',
    'Como pesquisar um local?':
        'Na tela de locais, use Pesquisar lugares para buscar por nome. Toque em Filtrar para escolher uma categoria ou cidade.',
    'Como visualizar as informaÃ§Ãµes de um local?':
        'Toque no cartÃ£o do local para abrir os detalhes disponÃ­veis, como descriÃ§Ã£o, endereÃ§o e horÃ¡rio de funcionamento.',
    'Posso marcar um encontro pelo aplicativo?':
        'NÃ£o encontrei uma agenda ou um botÃ£o para marcar encontros. A documentaÃ§Ã£o prevÃª combinar atividades, mas essa funÃ§Ã£o nÃ£o estÃ¡ confirmada na versÃ£o atual. O chat permite conversar por texto.',
    'Onde posso ver minhas notificaÃ§Ãµes?':
        'Abra NotificaÃ§Ãµes no menu inferior. A tela mostra os avisos disponÃ­veis para sua conta.',
    'Como saber se alguÃ©m comeÃ§ou a me seguir?':
        'Quando alguÃ©m comeÃ§a a seguir vocÃª, o aplicativo pode mostrar um aviso em NotificaÃ§Ãµes.',
    'Por que recebi uma notificaÃ§Ã£o sobre meu vÃ­nculo familiar?':
        'O aviso informa que um familiar foi vinculado, que o acompanhamento foi bloqueado ou que foi reativado.',
    'O que Ã© o vÃ­nculo familiar?':
        'Ã‰ a ligaÃ§Ã£o entre sua conta e a de um familiar. Quando ele informa seu e-mail no cadastro e a conta Ã© encontrada, o vÃ­nculo Ã© criado automaticamente, sem uma etapa de aprovaÃ§Ã£o.',
    'Como saber se um familiar estÃ¡ vinculado Ã  minha conta?':
        'Confira NotificaÃ§Ãµes. Quando o vÃ­nculo Ã© criado, vocÃª recebe um aviso com o nome do familiar.',
    'Como bloquear o acompanhamento de um familiar?':
        'Abra a notificaÃ§Ã£o do vÃ­nculo familiar e toque em Bloquear familiar. O aplicativo pede confirmaÃ§Ã£o antes de interromper o acompanhamento.',
    'O que acontece quando bloqueio meu familiar?':
        'O familiar deixa de ver o painel de acompanhamento e recebe um aviso. VocÃª pode reativar o vÃ­nculo depois, pela notificaÃ§Ã£o, usando Desbloquear familiar.',
    'Como encerrar o vÃ­nculo familiar?':
        'NÃ£o encontrei uma opÃ§Ã£o para remover o vÃ­nculo de forma permanente. Para interromper o acompanhamento, use Bloquear familiar em NotificaÃ§Ãµes; essa aÃ§Ã£o pode ser desfeita depois.',
    'Como bloquear uma pessoa no chat?':
        'Abra a conversa, toque nas informaÃ§Ãµes da conversa e escolha Bloquear usuÃ¡rio. O aplicativo informa que a pessoa nÃ£o poderÃ¡ enviar mensagens para vocÃª.',
    'O que acontece quando bloqueio alguÃ©m?':
        'O bloqueio disponÃ­vel Ã© da conversa privada: a pessoa deixa de poder enviar mensagens nessa conversa. NÃ£o encontrei confirmaÃ§Ã£o de que ele bloqueie pedidos de amizade ou interaÃ§Ãµes em grupos.',
    'O que sÃ£o alertas de seguranÃ§a?':
        'A tela Gerenciar Mensagens mostra exemplos de alertas, mas nÃ£o encontrei detecÃ§Ã£o real de riscos ou avisos ligados a conversas nesta versÃ£o. NÃ£o trate os exemplos da tela como alertas confirmados.',
    'O que fazer quando encontro uma situaÃ§Ã£o suspeita?':
        'NÃ£o compartilhe senhas, cÃ³digos ou dados bancÃ¡rios. Se houver uma conversa privada, vocÃª pode abrir as informaÃ§Ãµes dela e escolher Bloquear usuÃ¡rio. NÃ£o encontrei um botÃ£o para denunciar a situaÃ§Ã£o.',
    'Quais informaÃ§Ãµes do idoso posso visualizar?':
        'A documentaÃ§Ã£o prevÃª nome, foto, faixa etÃ¡ria, cidade, estado, interesses, amizades, grupos, atividades confirmadas e conversas sinalizadas. A tela atual mostra um resumo de acompanhamento; nÃ£o consegui confirmar que todos esses dados ou limites estejam aplicados.',
    'Posso alterar o perfil do idoso?':
        'NÃ£o. O perfil do familiar oferece ediÃ§Ã£o dos prÃ³prios dados. NÃ£o encontrei uma opÃ§Ã£o para alterar o perfil do idoso.',
    'Quais informaÃ§Ãµes pessoais nÃ£o devem ser compartilhadas?':
        'A documentaÃ§Ã£o prevÃª que senha, e-mail, telefone e data de nascimento completa nÃ£o sejam exibidos ao familiar. NÃ£o consigo confirmar esse bloqueio no aplicativo atual; evite compartilhar dados sensÃ­veis atÃ© que as permissÃµes sejam verificadas.',
    'Como vincular um idoso?':
        'No cadastro de Familiar, informe o e-mail usado pelo idoso no LaÃ§os. Se a conta for encontrada e ainda puder ser vinculada, o vÃ­nculo Ã© criado automaticamente.',
    'O vÃ­nculo precisa de aprovaÃ§Ã£o do idoso?':
        'NÃ£o. O cadastro cria o vÃ­nculo automaticamente quando encontra uma conta vÃ¡lida. O idoso recebe uma notificaÃ§Ã£o e pode bloquear o acompanhamento.',
    'Como saber se o vÃ­nculo foi estabelecido?':
        'Na conta do familiar, a tela InÃ­cio mostra o nome do idoso vinculado. O idoso tambÃ©m recebe uma notificaÃ§Ã£o sobre o novo vÃ­nculo.',
    'O idoso pode bloquear o acompanhamento?':
        'Sim. Na notificaÃ§Ã£o do vÃ­nculo, o idoso pode tocar em Bloquear familiar e confirmar a aÃ§Ã£o.',
    'Posso remover meu vÃ­nculo como familiar?':
        'A documentaÃ§Ã£o prevÃª que o familiar possa encerrar o vÃ­nculo, mas nÃ£o encontrei essa opÃ§Ã£o no aplicativo. Nesta versÃ£o, o idoso pode bloquear o acompanhamento pela tela NotificaÃ§Ãµes.',
    'O que aparece no resumo do familiar?':
        'A tela InÃ­cio mostra o nome do idoso e um resumo de conversas, Ãºltima interaÃ§Ã£o e atividade recente. NÃ£o encontrei ali uma lista completa de amizades, grupos e atividades confirmadas.',
    'Posso ver a localizaÃ§Ã£o do idoso?':
        'NÃ£o encontrei compartilhamento da localizaÃ§Ã£o do idoso. A documentaÃ§Ã£o diz que a localizaÃ§Ã£o em tempo real nÃ£o faz parte desta versÃ£o.',
    'Posso acessar as conversas do idoso?':
        'A documentaÃ§Ã£o prevÃª acesso apenas a conversas sinalizadas por alertas. Como nÃ£o encontrei um fluxo funcional de alertas e revisÃ£o de conversas, nÃ£o posso confirmar esse acesso no aplicativo atual.',
    'Que alertas de seguranÃ§a existem no aplicativo?':
        'A tela Gerenciar Mensagens contÃ©m exemplos prontos, mas os botÃµes de verificaÃ§Ã£o nÃ£o executam uma aÃ§Ã£o e os alertas nÃ£o vÃªm de uma anÃ¡lise real. A documentaÃ§Ã£o tambÃ©m deixa a geraÃ§Ã£o automÃ¡tica para uma versÃ£o futura.',
    'O que posso fazer diante de uma situaÃ§Ã£o suspeita?':
        'NÃ£o encontrei no perfil familiar uma aÃ§Ã£o para denunciar, bloquear alguÃ©m em nome do idoso ou resolver um alerta. A tela de alertas Ã© demonstrativa; nÃ£o conte com ela como proteÃ§Ã£o ativa.',
    'Quais notificaÃ§Ãµes do vÃ­nculo familiar posso receber?':
        'O familiar recebe avisos quando o idoso bloqueia ou reativa o acompanhamento. NÃ£o encontrei confirmaÃ§Ã£o de notificaÃ§Ãµes de alertas de seguranÃ§a nesta versÃ£o.',
    'Posso fazer aÃ§Ãµes em nome do idoso?':
        'A documentaÃ§Ã£o diz que o familiar nÃ£o pode editar o perfil, enviar mensagens nem enviar pedidos de amizade pelo idoso. NÃ£o encontrei essas aÃ§Ãµes disponÃ­veis no perfil familiar.',
    'Quais dados do idoso sÃ£o privados?':
        'A documentaÃ§Ã£o trata senha, credenciais, e-mail, telefone e data de nascimento completa como dados privados. As regras atuais do aplicativo nÃ£o permitem confirmar que esse limite seja aplicado em todos os acessos.',
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
            ? data['message'] ?? 'NÃ£o foi possÃ­vel obter uma resposta.'
            : 'Resposta invÃ¡lida do servidor.',
      );
    }
 } catch (e, stackTrace) {
    debugPrint('Erro ao enviar mensagem ao Assistente LaÃ§os: $e');
    debugPrintStack(stackTrace: stackTrace);

    if (!mounted) return;

    setState(() {
      _conversation.add({
        'role': 'bot',
        'text':
            'NÃ£o consegui responder agora. Verifique sua conexÃ£o e tente novamente.',
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
            'Esta informaÃ§Ã£o ainda precisa ser confirmada no aplicativo.';

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
                      'Assistente LaÃ§os',
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
                      'OlÃ¡! Eu sou o Assistente LaÃ§os. '
                      'Como posso ajudar vocÃª?',
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
                        hintText: 'Digite sua dÃºvida...',
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
