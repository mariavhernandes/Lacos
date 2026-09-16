import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_footer.dart';

class ManageMessagesScreen extends StatefulWidget {
  const ManageMessagesScreen({super.key});

  @override
  State<ManageMessagesScreen> createState() => _ManageMessagesScreenState();
}

class _ManageMessagesScreenState extends State<ManageMessagesScreen> {
  bool _blockExternalLinks = false;
  bool _alertNewRisks = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const CustomFooter(
        currentIndex: 2,
        isFamily: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // =====================================================
            // CABEÇALHO PADRONIZADO (SEM SETA)
            // =====================================================
            const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Center(
                child: Text(
                  'Gerenciar Mensagens',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Quicksand',
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF777777),
                  ),
                ),
              ),
            ),

            // =====================================================
            // CONTEÚDO COM SCROLL
            // =====================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // SEÇÃO - PAINEL DE ALERTAS
                    // =================================================
                    const Text(
                      'Painel de Alertas',
                      style: TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card 1: Link suspeito
                    _buildAlertCard(
                      imageAsset:
                          'assets/icons/notifications/suspicious_message_warning_icon.png',
                      title: 'Envio de Link suspeito:',
                      description:
                          'Detectamos um link potencialmente perigoso na conversa. Ele pode levar a sites falsos ou roubar dados pessoais.',
                      onVerify: () {},
                    ),
                    const SizedBox(height: 14),

                    // Card 2: Golpe identificado
                    _buildAlertCard(
                      imageAsset:
                          'assets/icons/notifications/suspicious_message_alert_icon.png',
                      title: 'Mensagem de Golpe Identificada:',
                      description:
                          'Detectamos um pedido de PIX suspeito. Pode ser uma tentativa de golpe financeiro.',
                      onVerify: () {},
                    ),
                    const SizedBox(height: 14),

                    // Card 3: Contato confiável
                    _buildAlertCard(
                      imageAsset:
                          'assets/icons/notifications/trusted_contact_icon.png',
                      title: 'Contato Confiável:',
                      description: 'Éder Barros',
                      onVerify: () {},
                    ),
                    const SizedBox(height: 28),

                    // =================================================
                    // SEÇÃO - FILTROS
                    // =================================================
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 5,
                            offset: Offset(2, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Text(
                              'Filtros',
                              style: TextStyle(
                                fontFamily: 'Raleway',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF033B63),
                              ),
                            ),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 0.8,
                            color: Color(0xFF999999),
                          ),

                          // Opção 1: Bloquear Contatos
                          _buildFilterActionTile(
                            imageAsset:
                                'assets/images/family/block_contacts_icon.png',
                            fallbackIcon: Icons.lock_outline_rounded,
                            label: 'Bloquear Contatos',
                            onTap: () {},
                          ),

                          // Opção 2: Bloquear Links externos
                          _buildFilterSwitchTile(
                            imageAsset:
                                'assets/images/family/block_contacts_icon.png',
                            fallbackIcon: Icons.link_rounded,
                            label: 'Bloquear Links externos',
                            value: _blockExternalLinks,
                            onChanged: (val) {
                              setState(() {
                                _blockExternalLinks = val;
                              });
                            },
                          ),

                          // Opção 3: Alertar novas chances de riscos
                          _buildFilterSwitchTile(
                            imageAsset:
                                'assets/images/family/risk_alert_icon.png',
                            fallbackIcon: Icons.notifications_none_rounded,
                            label: 'Alertar novas chances de riscos',
                            value: _alertNewRisks,
                            onChanged: (val) {
                              setState(() {
                                _alertNewRisks = val;
                              });
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Card de alerta com suporte a assets de imagem
  Widget _buildAlertCard({
    required String imageAsset,
    required String title,
    required String description,
    required VoidCallback onVerify,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F0FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC2DCFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                imageAsset,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 22,
                      color: Color(0xFF033B63),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Raleway',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF033B63),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontSize: 13,
                        color: Color(0xFF4A5568),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onVerify,
              child: const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Verificar',
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF033B63),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tile dos Filtros com clique simples
  Widget _buildFilterActionTile({
    required String imageAsset,
    required IconData fallbackIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Image.asset(
        imageAsset,
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFD9EEFF),
              shape: BoxShape.circle,
            ),
            child: Icon(fallbackIcon, size: 20, color: const Color(0xFF033B63)),
          );
        },
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
    );
  }

  // Tile dos Filtros com botão Toggle/Switch sem bordas pretas
  Widget _buildFilterSwitchTile({
    required String imageAsset,
    required IconData fallbackIcon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Image.asset(
        imageAsset,
        width: 34,
        height: 34,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0xFFD9EEFF),
              shape: BoxShape.circle,
            ),
            child: Icon(fallbackIcon, size: 20, color: const Color(0xFF033B63)),
          );
        },
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF333333),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: const Color(0xFF80C4FF),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFCBD5E0),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        trackOutlineWidth: WidgetStateProperty.all(0),
      ),
    );
  }
}