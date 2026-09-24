import 'package:cloud_firestore/cloud_firestore.dart';

class FamilyNotificationService {
  FamilyNotificationService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> notificationsForElder(
    String elderUid,
  ) {
    return _firestore
        .collection('idosos')
        .doc(elderUid)
        .collection('notificacoes');
  }

  CollectionReference<Map<String, dynamic>> notificationsForFamily(
    String familyUid,
  ) {
    return _firestore
        .collection('familiares')
        .doc(familyUid)
        .collection('notificacoes');
  }

  Query<Map<String, dynamic>> notificationsStream(String elderUid) {
    return notificationsForElder(elderUid)
        .orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> familyNotificationsStream(String familyUid) {
    return notificationsForFamily(familyUid)
        .orderBy('createdAt', descending: true);
  }

  Query<Map<String, dynamic>> unreadNotificationsStream({
    required String uid,
    required bool isElder,
  }) {
    final notifications =
        isElder ? notificationsForElder(uid) : notificationsForFamily(uid);
    return notifications.where('read', isEqualTo: false);
  }

  Future<void> markAsRead({
    required String elderUid,
    required String notificationId,
  }) async {
    await notificationsForElder(elderUid).doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> markFamilyNotificationAsRead({
    required String familyUid,
    required String notificationId,
  }) async {
    await notificationsForFamily(familyUid).doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> markAllAsRead({
    required String uid,
    required bool isElder,
  }) async {
    final notifications =
        isElder ? notificationsForElder(uid) : notificationsForFamily(uid);
    final snapshot = await notifications.where('read', isEqualTo: false).get();
    if (snapshot.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.update(document.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<int> unreadCount(String elderUid) async {
    final snapshot = await notificationsForElder(elderUid)
        .where('read', isEqualTo: false)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  static Map<String, dynamic> familyLinkCreatedPayload({
    required String familyUid,
    required String familyName,
  }) {
    return {
      'type': 'family_link_created',
      'title': 'Novo familiar vinculado',
      'message':
          '$familyName passou a supervisionar você como familiar/responsável.',
      'familyUid': familyUid,
      'familyName': familyName,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  static Map<String, dynamic> familyLinkStatusPayload({
    required String familyUid,
    required String elderUid,
    required String elderName,
    required String status,
  }) {
    final isBlocked = status == 'blocked';
    return {
      'type': isBlocked ? 'family_link_blocked' : 'family_link_reactivated',
      'title': isBlocked
          ? 'Vínculo familiar bloqueado'
          : 'Vínculo familiar reativado',
      'message': isBlocked
          ? '$elderName bloqueou seu acesso ao vínculo familiar.'
          : '$elderName reativou seu acesso ao vínculo familiar.',
      'familyUid': familyUid,
      'elderUid': elderUid,
      'elderName': elderName,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  void setFamilyLinkCreatedNotification({
    required Transaction transaction,
    required String elderUid,
    required String familyUid,
    required String familyName,
  }) {
    final notificationReference = notificationsForElder(elderUid).doc();
    transaction.set(
      notificationReference,
      familyLinkCreatedPayload(
        familyUid: familyUid,
        familyName: familyName,
      ),
    );
  }

  void setFamilyLinkStatusNotification({
    required Transaction transaction,
    required String familyUid,
    required String elderUid,
    required String elderName,
    required String status,
  }) {
    final notificationReference = notificationsForFamily(familyUid).doc();
    transaction.set(
      notificationReference,
      familyLinkStatusPayload(
        familyUid: familyUid,
        elderUid: elderUid,
        elderName: elderName,
        status: status,
      ),
    );
  }
}
