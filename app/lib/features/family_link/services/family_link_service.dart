import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../notifications/data/notification_service.dart';

class FamilyLinkService {
  FamilyLinkService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static bool hasActiveLink({
    required Map<String, dynamic> elderData,
    required Map<String, dynamic> familyData,
    required String familyUid,
    required String elderUid,
  }) {
    if (elderData['familyLinkStatus'] == 'blocked' ||
        familyData['familyLinkStatus'] == 'blocked') {
      return false;
    }

    final familyLinkUid = familyData['linkedElderUid']?.toString();
    final elderLinkUid = elderData['linkedFamilyUid']?.toString();
    if (familyLinkUid != null && familyLinkUid.isNotEmpty) {
      return familyLinkUid == elderUid && elderLinkUid == familyUid;
    }

    return familyData['linkedElderEmail']?.toString().trim() ==
        elderData['email']?.toString().trim();
  }

  Future<Map<String, dynamic>?> getActiveElderForFamily({
    String? familyUid,
  }) async {
    final uid = familyUid ?? _auth.currentUser?.uid;
    if (uid == null) return null;

    final familySnapshot =
        await _firestore.collection('familiares').doc(uid).get();
    if (!familySnapshot.exists) return null;

    final familyData = familySnapshot.data() ?? <String, dynamic>{};
    if (familyData['familyLinkStatus'] == 'blocked' ||
        familyData['familyLinkStatus'] == 'none') {
      return null;
    }

    final elderUid = familyData['linkedElderUid']?.toString();
    DocumentSnapshot<Map<String, dynamic>>? elderSnapshot;

    if (elderUid != null && elderUid.isNotEmpty) {
      elderSnapshot = await _firestore.collection('idosos').doc(elderUid).get();
    } else {
      final linkedEmail = familyData['linkedElderEmail']?.toString().trim();
      if (linkedEmail == null || linkedEmail.isEmpty) return null;

      final query = await _firestore
          .collection('idosos')
          .where('email', isEqualTo: linkedEmail)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) elderSnapshot = query.docs.first;
    }

    if (elderSnapshot == null || !elderSnapshot.exists) return null;

    final elderData = elderSnapshot.data() ?? <String, dynamic>{};
    if (!hasActiveLink(
      elderData: elderData,
      familyData: familyData,
      familyUid: uid,
      elderUid: elderSnapshot.id,
    )) {
      return null;
    }

    return <String, dynamic>{
      ...elderData,
      'uid': elderSnapshot.id,
      'familyUid': uid,
    };
  }

  Future<void> blockFamilyMember({
    required String elderUid,
    required String familyUid,
  }) async {
    final elderReference = _firestore.collection('idosos').doc(elderUid);
    final familyReference = _firestore.collection('familiares').doc(familyUid);
    final notificationService =
        FamilyNotificationService(firestore: _firestore);

    await _firestore.runTransaction((transaction) async {
      final elderSnapshot = await transaction.get(elderReference);
      final familySnapshot = await transaction.get(familyReference);
      final elderData = elderSnapshot.data() ?? <String, dynamic>{};
      final familyData = familySnapshot.data() ?? <String, dynamic>{};

      if (!elderSnapshot.exists ||
          !familySnapshot.exists ||
          elderData['linkedFamilyUid'] != familyUid ||
          familyData['linkedElderUid'] != elderUid ||
          !hasActiveLink(
            elderData: elderData,
            familyData: familyData,
            familyUid: familyUid,
            elderUid: elderUid,
          )) {
        throw StateError('O vínculo familiar ativo não foi encontrado.');
      }

      final blockedData = <String, dynamic>{
        'familyLinkStatus': 'blocked',
        'familyLinkBlockedAt': FieldValue.serverTimestamp(),
        'familyLinkBlockedBy': elderUid,
      };
      transaction.update(elderReference, blockedData);
      transaction.update(familyReference, blockedData);
      notificationService.setFamilyLinkStatusNotification(
        transaction: transaction,
        familyUid: familyUid,
        elderUid: elderUid,
        elderName: elderData['name']?.toString().trim() ?? 'O idoso',
        status: 'blocked',
      );
    });
  }

  Future<void> unblockFamilyMember({
    required String elderUid,
    required String familyUid,
  }) async {
    final elderReference = _firestore.collection('idosos').doc(elderUid);
    final familyReference = _firestore.collection('familiares').doc(familyUid);
    final notificationService =
        FamilyNotificationService(firestore: _firestore);

    await _firestore.runTransaction((transaction) async {
      final elderSnapshot = await transaction.get(elderReference);
      final familySnapshot = await transaction.get(familyReference);
      final elderData = elderSnapshot.data() ?? <String, dynamic>{};
      final familyData = familySnapshot.data() ?? <String, dynamic>{};

      if (!elderSnapshot.exists ||
          !familySnapshot.exists ||
          elderData['linkedFamilyUid'] != familyUid ||
          familyData['linkedElderUid'] != elderUid ||
          elderData['familyLinkStatus'] != 'blocked' ||
          familyData['familyLinkStatus'] != 'blocked') {
        throw StateError('O vínculo familiar bloqueado não foi encontrado.');
      }

      final activeData = <String, dynamic>{
        'familyLinkStatus': 'active',
        'familyLinkBlockedAt': FieldValue.delete(),
        'familyLinkBlockedBy': FieldValue.delete(),
      };
      transaction.update(elderReference, activeData);
      transaction.update(familyReference, activeData);
      notificationService.setFamilyLinkStatusNotification(
        transaction: transaction,
        familyUid: familyUid,
        elderUid: elderUid,
        elderName: elderData['name']?.toString().trim() ?? 'O idoso',
        status: 'active',
      );
    });
  }
}
