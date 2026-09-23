import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_footer.dart';
import '../../../family_link/services/family_link_service.dart';
import '../../data/notification_service.dart';
import '../../domain/models/app_notification.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final _auth = FirebaseAuth.instance;
  final _notificationService = FamilyNotificationService();
  final _familyLinkService = FamilyLinkService();
  bool? _notificationsProfileIsElder;

  Future<void> _markAsRead(
      AppNotification notification, String uid, bool isElder) async {
    if (notification.isRead) return;
    if (isElder) {
      await _notificationService.markAsRead(
        elderUid: uid,
        notificationId: notification.id,
      );
    } else {
      await _notificationService.markFamilyNotificationAsRead(
        familyUid: uid,
        notificationId: notification.id,
      );
    }
  }

  Future<void> _confirmLinkToggle({
    required String elderUid,
    required String familyUid,
    required String familyName,
    required String familyLinkStatus,
  }) async {
    final isBlocked = familyLinkStatus == 'blocked';
    final actionLabel = isBlocked ? 'Desbloquear' : 'Bloquear';
    final successMessage = isBlocked
        ? 'Familiar desbloqueado com sucesso.'
        : 'Familiar bloqueado com sucesso.';
    final errorMessage = isBlocked
        ? 'Não foi possível desbloquear o familiar.'
        : 'Não foi possível bloquear o familiar.';
    final shouldBlock = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$actionLabel familiar'),
        content: Text(
          isBlocked
              ? 'Deseja reativar a supervisão de $familyName?'
              : 'Deseja encerrar a supervisão de $familyName? '
                  'Esse familiar perderá o acesso aos seus dados de acompanhamento.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionLabel),
          ),
        ],
      ),
    );

    if (shouldBlock != true || !mounted) return;

    try {
      if (isBlocked) {
        await _familyLinkService.unblockFamilyMember(
          elderUid: elderUid,
          familyUid: familyUid,
        );
      } else {
        await _familyLinkService.blockFamilyMember(
          elderUid: elderUid,
          familyUid: familyUid,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMessage),
          backgroundColor: const Color(0xFF0A395C),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final elderUid = _auth.currentUser?.uid;

    if (elderUid == null) {
      return const Scaffold(
        body: Center(child: Text('Usuário não autenticado.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/navigation/back_icon.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Container(
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
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Notificações',
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
              child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('idosos')
                    .doc(elderUid)
                    .snapshots(),
                builder: (context, profileSnapshot) {
                  if (profileSnapshot.hasError) {
                    return const Center(
                      child: Text('Não foi possível carregar as notificações.'),
                    );
                  }
                  if (!profileSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final isElder = profileSnapshot.data!.exists;
                  if (_notificationsProfileIsElder != isElder) {
                    _notificationsProfileIsElder = isElder;
                    _notificationService.markAllAsRead(
                      uid: elderUid,
                      isElder: isElder,
                    );
                  }
                  final notificationsStream = isElder
                      ? _notificationService.notificationsStream(elderUid)
                      : _notificationService
                          .familyNotificationsStream(elderUid);
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: notificationsStream.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                              'Não foi possível carregar as notificações.'),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Nenhuma notificação.'));
                      }

                      final notifications = snapshot.data!.docs
                          .map(AppNotification.fromDocument)
                          .toList();
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return _buildNotificationTile(
                            notification,
                            elderUid,
                            isElder,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomFooter(currentIndex: 0),
    );
  }

  Widget _buildNotificationTile(
    AppNotification notification,
    String uid,
    bool isElder,
  ) {
    final familyUid = notification.familyUid;
    final familyName = notification.familyName ?? 'o familiar';

    return InkWell(
      onTap: () => _markAsRead(notification, uid, isElder),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? const Color(0xFFF7F9FB)
              : const Color(0xFFEAF4FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDCEAF5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined,
                    color: Color(0xFF033B63)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    notification.title,
                    style: const TextStyle(
                      fontFamily: 'Quicksand',
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF033B63),
                    ),
                  ),
                ),
                if (!notification.isRead)
                  const Icon(Icons.circle, size: 10, color: Color(0xFF62B6CB)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              notification.message,
              style: const TextStyle(fontFamily: 'Raleway', height: 1.3),
            ),
            if (isElder &&
                notification.isFamilyLinkNotification &&
                familyUid != null) ...[
              const SizedBox(height: 14),
              StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('familiares')
                    .doc(familyUid)
                    .snapshots(),
                builder: (context, familySnapshot) {
                  if (familySnapshot.hasError) {
                    return const Text(
                      'Não foi possível carregar o estado do vínculo.',
                    );
                  }

                  if (!familySnapshot.hasData) {
                    return const Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  final familyData = familySnapshot.data!.data();
                  final familyLinkStatus =
                      familyData?['familyLinkStatus']?.toString();
                  if (familyLinkStatus != 'active' &&
                      familyLinkStatus != 'blocked') {
                    return const SizedBox.shrink();
                  }

                  final isBlocked = familyLinkStatus == 'blocked';
                  return Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => _confirmLinkToggle(
                        elderUid: uid,
                        familyUid: familyUid,
                        familyName: familyName,
                        familyLinkStatus: familyLinkStatus ?? 'active',
                      ),
                      icon: Icon(isBlocked ? Icons.lock_open : Icons.block),
                      label: Text(
                        isBlocked
                            ? 'Desbloquear familiar'
                            : 'Bloquear familiar',
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
