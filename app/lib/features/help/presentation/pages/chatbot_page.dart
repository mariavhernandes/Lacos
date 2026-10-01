import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  String? _userRole;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String? _selectedTopic;
  String? _selectedQuestion;

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
      'Como bloquear uma pessoa?',
      'O que acontece quando bloqueio alguém?',
    ],
    'Conversas': [
      'Como conversar com um amigo?',
      'Quem pode conversar comigo?',
      'Como enviar uma mensagem?',
      'Como funciona o chat?',
      'O que acontece quando bloqueio alguém?',
    ],
    'Grupos': [
      'Como encontrar um grupo?',
      'Como participar de um grupo?',
      'Como criar um grupo?',
      'Como sair de um grupo?',
      'Como funcionam as mensagens do grupo?',
    ],
    'Interesses e atividades': [
      'Como adicionar meus interesses?',
      'Como encontrar pessoas com os mesmos interesses?',
      'Como encontrar atividades?',
      'Como encontrar locais de lazer?',
      'Como pesquisar um local?',
      'Como visualizar as informações de um local?',
    ],
    'Encontros e lazer': [
      'Como marcar um encontro?',
      'Como combinar uma atividade com outra pessoa?',
      'Como escolher um local para o encontro?',
      'Como encontrar sugestões de lugares?',
      'Como visualizar informações do local?',
    ],
    'Notificações': [
      'Como funcionam as notificações?',
      'Como saber se recebi uma solicitação de amizade?',
      'Como saber se aceitaram minha solicitação?',
      'Como visualizar novas mensagens?',
      'Como receber atualizações dos grupos?',
      'Por que recebi uma notificação sobre meu vínculo familiar?',
    ],
    'Vínculo familiar': [
      'O que é o vínculo familiar?',
      'Como funciona o vínculo familiar?',
      'O que meu familiar pode visualizar?',
      'Como saber se um familiar está vinculado à minha conta?',
      'Como bloquear um familiar?',
      'O que acontece quando bloqueio meu familiar?',
      'Como encerrar o vínculo familiar?',
    ],
    'Segurança': [
      'Como bloquear uma pessoa?',
      'O que acontece quando bloqueio alguém?',
      'O que são alertas de segurança?',
      'Como funciona a proteção do aplicativo?',
      'O que fazer quando encontro uma situação suspeita?',
    ],
  };

  final Map<String, List<String>> _familyTopics = {
    'Perfil do idoso': [
      'Quais informações do idoso posso visualizar?',
      'Posso alterar o perfil do idoso?',
      'Posso alterar os dados do idoso?',
      'Quais informações são privadas?',
      'Posso visualizar os interesses do idoso?',
    ],
    'Vínculo familiar': [
      'O que é o vínculo familiar?',
      'Como vincular um idoso?',
      'O que é o linkedElderEmail?',
      'Como saber se o vínculo foi estabelecido?',
      'Como encerrar o vínculo?',
      'O que acontece quando o vínculo é encerrado?',
      'O idoso pode bloquear o vínculo?',
    ],
    'Acompanhamento': [
      'O que posso acompanhar do idoso?',
      'Quais informações posso visualizar?',
      'Posso visualizar as amizades?',
      'Posso visualizar os grupos?',
      'Posso visualizar as atividades?',
      'Posso visualizar a localização permitida?',
      'Posso acompanhar as informações do perfil?',
    ],
    'Segurança e alertas': [
      'O que são os alertas de segurança?',
      'Como visualizar um alerta?',
      'Como marcar um alerta como resolvido?',
      'Como bloquear um participante?',
      'O que acontece quando bloqueio um participante?',
      'O que acontece com a conversa após um bloqueio?',
    ],
    'Notificações': [
      'Quando recebo uma notificação?',
      'Como saber se o vínculo foi estabelecido?',
      'Quais alertas posso receber?',
      'Quais avisos importantes posso receber?',
    ],
    'Privacidade e permissões': [
      'O que posso acessar?',
      'O que não posso acessar?',
      'Posso alterar o perfil do idoso?',
      'Posso enviar mensagens pelo idoso?',
      'Posso enviar solicitações de amizade pelo idoso?',
      'O que acontece quando o vínculo termina?',
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
        'Para criar seu perfil, preencha as informações solicitadas durante o cadastro no Laços.',

    'Como alterar meu perfil?':
        'Você pode acessar seu perfil e selecionar a opção de editar perfil para alterar suas informações.',

    'Como alterar minha foto?':
        'Acesse a edição do seu perfil para alterar sua foto.',

    'Como adicionar ou alterar meus interesses?':
        'Acesse a área de edição do seu perfil para adicionar ou alterar seus interesses.',

    'Quais informações aparecem no meu perfil?':
        'Seu perfil apresenta as informações permitidas pelas configurações de privacidade do Laços.',

    'Como funciona a privacidade das minhas informações?':
        'Suas informações são apresentadas de acordo com as regras de privacidade e permissões do aplicativo.',

    'Como encontrar uma pessoa?':
        'Você pode utilizar as funcionalidades de descoberta do Laços para encontrar outras pessoas.',

    'Como adicionar uma pessoa?':
        'Acesse o perfil da pessoa e utilize a opção disponível para enviar uma solicitação de amizade.',

    'Como aceitar uma solicitação de amizade?':
        'Acesse suas solicitações de amizade e selecione a opção para aceitar.',

    'Como recusar uma solicitação de amizade?':
        'Acesse suas solicitações de amizade e selecione a opção para recusar.',

    'Como encontrar pessoas com interesses em comum?':
        'O Laços permite encontrar pessoas que compartilham interesses em comum.',

    'Como bloquear uma pessoa?':
        'Você pode utilizar a opção de bloqueio disponível para impedir novas interações com a pessoa.',

    'O que acontece quando bloqueio alguém?':
        'Ao bloquear uma pessoa, as interações entre vocês ficam restritas de acordo com as regras de segurança do aplicativo.',

    'Como conversar com um amigo?':
        'Abra a conversa com um amigo confirmado para iniciar uma conversa privada.',

    'Quem pode conversar comigo?':
        'As conversas privadas são destinadas aos amigos confirmados no aplicativo.',

    'Como enviar uma mensagem?':
        'Abra a conversa com um amigo e utilize o campo de mensagem para enviar um texto.',

    'Como funciona o chat?':
        'O Laços possui conversas privadas por texto entre amigos confirmados.',

    'Como encontrar um grupo?':
        'Você pode utilizar as funcionalidades de grupos do Laços para encontrar grupos de interesse.',

    'Como participar de um grupo?':
        'Acesse um grupo disponível e utilize a opção de participação quando estiver disponível.',

    'Como criar um grupo?':
        'Utilize a funcionalidade de grupos do Laços para criar um novo grupo.',

    'Como sair de um grupo?':
        'Acesse o grupo e utilize a opção disponível para sair.',

    'Como funcionam as mensagens do grupo?':
        'Os participantes podem utilizar as mensagens do grupo para interagir entre si.',

    'Como adicionar meus interesses?':
        'Acesse a edição do seu perfil para adicionar seus interesses.',

    'Como encontrar atividades?':
        'Utilize a busca de atividades do Laços para encontrar opções de acordo com seus interesses e localização.',

    'Como encontrar locais de lazer?':
        'Utilize a busca de locais de lazer para encontrar opções disponíveis.',

    'Como pesquisar um local?':
        'Você pode pesquisar locais utilizando os filtros disponíveis no aplicativo.',

    'Como visualizar as informações de um local?':
        'Selecione o local desejado para visualizar suas informações.',

    'Como marcar um encontro?':
        'Depois de encontrar uma pessoa com interesses em comum, você pode combinar uma atividade e um encontro.',

    'Como combinar uma atividade com outra pessoa?':
        'Depois de encontrar uma pessoa, vocês podem combinar uma atividade para realizar juntos.',

    'Como escolher um local para o encontro?':
        'Você pode escolher um local entre as opções de lazer disponíveis no aplicativo.',

    'Como encontrar sugestões de lugares?':
        'Utilize a busca de locais e os filtros disponíveis para encontrar opções de lazer.',

    'Como visualizar informações do local?':
        'Selecione um local para visualizar suas informações.',

    'Como funcionam as notificações?':
        'As notificações informam sobre acontecimentos importantes, como amizades, mensagens, grupos e vínculo familiar.',

    'Como saber se recebi uma solicitação de amizade?':
        'Você receberá uma notificação quando houver uma nova solicitação de amizade.',

    'Como saber se aceitaram minha solicitação?':
        'Você receberá uma notificação quando sua solicitação de amizade for aceita.',

    'Como visualizar novas mensagens?':
        'As notificações podem informar quando você recebe novas mensagens.',

    'Como receber atualizações dos grupos?':
        'As notificações informam sobre atualizações relacionadas aos grupos.',

    'Por que recebi uma notificação sobre meu vínculo familiar?':
        'Você pode receber notificações relacionadas ao estabelecimento, bloqueio ou encerramento do vínculo familiar.',

    'O que é o vínculo familiar?':
        'O vínculo familiar permite que um familiar autorizado acompanhe informações permitidas pelo aplicativo, respeitando as regras de privacidade e segurança.',

    'Como funciona o vínculo familiar?':
        'O vínculo familiar permite que um familiar autorizado acompanhe informações permitidas pelo aplicativo.',

    'O que meu familiar pode visualizar?':
        'O familiar pode visualizar somente as informações permitidas pelo vínculo e pelas configurações de privacidade.',

    'Como saber se um familiar está vinculado à minha conta?':
        'As informações do vínculo familiar ficam disponíveis na área correspondente do aplicativo.',

    'Como bloquear um familiar?':
        'Você pode bloquear o vínculo familiar utilizando a opção disponível no aplicativo.',

    'O que acontece quando bloqueio meu familiar?':
        'Quando o familiar é bloqueado, o acesso dele às informações autorizadas é encerrado.',

    'Como encerrar o vínculo familiar?':
        'O vínculo familiar pode ser encerrado de acordo com as opções disponíveis para o usuário.',

    'O que são alertas de segurança?':
        'São avisos relacionados a situações que podem exigir atenção para proteger os usuários do Laços.',

    'Como funciona a proteção do aplicativo?':
        'O Laços possui recursos de segurança e proteção para ajudar a restringir interações consideradas inadequadas ou suspeitas.',

    'O que fazer quando encontro uma situação suspeita?':
        'Observe os alertas e recursos de segurança disponíveis no aplicativo e, quando aplicável, utilize as opções de proteção disponíveis.',

    'Quais informações do idoso posso visualizar?':
        'O familiar pode visualizar somente as informações autorizadas pelo vínculo e pelas configurações de privacidade.',

    'Posso alterar o perfil do idoso?':
        'Não. O familiar pode visualizar as informações autorizadas, mas não pode alterar o perfil do idoso.',

    'Posso alterar os dados do idoso?':
        'Não. O familiar não pode alterar os dados do perfil do idoso.',

    'Quais informações são privadas?':
        'O acesso do familiar é limitado às informações autorizadas pelas regras de privacidade e pelo vínculo familiar.',

    'Posso visualizar os interesses do idoso?':
        'Sim, quando essa informação estiver entre as informações autorizadas para acompanhamento.',

    'Como vincular um idoso?':
        'O vínculo familiar utiliza o e-mail do idoso para estabelecer a relação entre as contas.',

    'O que é o linkedElderEmail?':
        'É o e-mail utilizado para identificar o idoso que será vinculado à conta do familiar.',

    'Como saber se o vínculo foi estabelecido?':
        'Você poderá verificar o vínculo na área destinada ao acompanhamento familiar.',

    'Como encerrar o vínculo?':
        'O familiar pode utilizar a opção disponível para encerrar seu próprio vínculo com o idoso.',

    'O que acontece quando o vínculo é encerrado?':
        'Quando o vínculo é encerrado, o acesso do familiar às informações autorizadas do idoso é encerrado.',

    'O idoso pode bloquear o vínculo?':
        'Sim. O idoso pode bloquear o vínculo familiar, encerrando o acesso de acompanhamento.',

    'O que posso acompanhar do idoso?':
        'O familiar pode acompanhar as informações autorizadas, como perfil, interesses, amizades, grupos, atividades e localização quando permitido.',

    'Quais informações posso visualizar?':
        'O familiar pode visualizar somente as informações autorizadas pelo vínculo.',

    'Posso visualizar as amizades?':
        'Sim, quando essa informação estiver autorizada para acompanhamento.',

    'Posso visualizar os grupos?':
        'Sim, quando essa informação estiver autorizada para acompanhamento.',

    'Posso visualizar as atividades?':
        'Sim, quando essa informação estiver autorizada para acompanhamento.',

    'Posso visualizar a localização permitida?':
        'A localização pode ser visualizada pelo familiar de acordo com o nível de localização autorizado.',

    'Posso acompanhar as informações do perfil?':
        'Sim, o familiar pode visualizar as informações do perfil que estiverem autorizadas.',

    'Como visualizar um alerta?':
        'Acesse a área de alertas de segurança para visualizar os alertas disponíveis.',

    'Como marcar um alerta como resolvido?':
        'O familiar pode marcar um alerta de segurança como resolvido após verificar a situação.',

    'Como bloquear um participante?':
        'O familiar pode bloquear um participante relacionado a uma situação de segurança.',

    'O que acontece quando bloqueio um participante?':
        'O participante bloqueado deixa de poder interagir de acordo com as regras de segurança do aplicativo.',

    'O que acontece com a conversa após um bloqueio?':
        'A conversa pode ser mantida para fins de auditoria, enquanto o participante bloqueado deixa de poder interagir.',

    'Quando recebo uma notificação?':
        'As notificações são utilizadas para informar acontecimentos importantes relacionados ao vínculo e à segurança.',

    'Quais alertas posso receber?':
        'Você pode receber alertas relacionados a situações de segurança e ao acompanhamento permitido.',

    'Quais avisos importantes posso receber?':
        'Você pode receber avisos relacionados ao vínculo familiar, segurança e outras informações importantes.',

    'O que posso acessar?':
        'O familiar pode acessar somente as informações autorizadas pelo vínculo e pelas regras de privacidade.',

    'O que não posso acessar?':
        'O familiar não possui acesso às informações ou ações que não estejam autorizadas pelo vínculo.',

    'Posso enviar mensagens pelo idoso?':
        'Não. O familiar não pode enviar mensagens em nome do idoso.',

    'Posso enviar solicitações de amizade pelo idoso?':
        'Não. O familiar não pode realizar solicitações de amizade em nome do idoso.',

    'O que acontece quando o vínculo termina?':
        'Quando o vínculo termina, o acesso do familiar às informações autorizadas do idoso também é encerrado.',
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
      if (_selectedQuestion != null) {
        _selectedQuestion = null;
      } else if (_selectedTopic != null) {
        _selectedTopic = null;
      }
    });
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    _messageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Escolha uma das opções disponíveis para encontrar uma resposta.',
        ),
      ),
    );
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
    final topics =
        _userRole == 'familiar' ? _familyTopics : _elderlyTopics;

    final questions =
        _selectedTopic == null ? <String>[] : topics[_selectedTopic] ?? [];

    final answer = _selectedQuestion == null
        ? null
        : _answers[_selectedQuestion] ??
            'Essa informação será disponibilizada no Assistente Laços.';

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
                      if (_selectedQuestion != null ||
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

                    if (_selectedTopic == null) ...[
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
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Digite sua dúvida...',
                        hintStyle: const TextStyle(
                          fontFamily: 'Raleway',
                          color: Color(0xFF888888),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF4F5F7),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: Color(0xFF033B63),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 21,
                      ),
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