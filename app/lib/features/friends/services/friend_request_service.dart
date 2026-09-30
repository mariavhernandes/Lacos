import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendRequestService {
  FriendRequestService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('friend_requests');

  String? get _currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // ENVIAR SOLICITAÇÃO
  // ============================================================

  Future<void> sendRequest(String receiverId) async {
    final String? senderId = _currentUserId;

    if (senderId == null) {
      throw Exception('Usuário não autenticado.');
    }

    if (receiverId.trim().isEmpty) {
      throw Exception('Usuário destinatário inválido.');
    }

    if (senderId == receiverId) {
      throw Exception(
        'Não é possível enviar uma solicitação para si mesmo.',
      );
    }

    final existingRequest = await _findRequest(
      senderId,
      receiverId,
    );

    if (existingRequest != null) {
      final data = existingRequest.data();
      final status = data['status']?.toString();

      if (status == 'pending') {
        throw Exception(
          'Já existe uma solicitação pendente entre esses usuários.',
        );
      }

      if (status == 'accepted') {
        throw Exception(
          'Vocês já são amigos.',
        );
      }

      if (status == 'rejected') {
        await existingRequest.reference.update({
          'senderId': senderId,
          'receiverId': receiverId,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        return;
      }
    }

    await _requests.add({
      'senderId': senderId,
      'receiverId': receiverId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ACEITAR SOLICITAÇÃO
  // ============================================================

  Future<void> acceptRequest(String requestId) async {
    final String? currentUserId = _currentUserId;

    if (currentUserId == null) {
      throw Exception('Usuário não autenticado.');
    }

    final requestRef = _requests.doc(requestId);
    final requestSnapshot = await requestRef.get();

    if (!requestSnapshot.exists ||
        requestSnapshot.data() == null) {
      throw Exception('Solicitação não encontrada.');
    }

    final data = requestSnapshot.data()!;

    final String? senderId =
        data['senderId']?.toString();

    final String? receiverId =
        data['receiverId']?.toString();

    if (senderId == null || receiverId == null) {
      throw Exception(
        'Dados da solicitação estão incompletos.',
      );
    }

    if (receiverId != currentUserId) {
      throw Exception(
        'Você não pode aceitar esta solicitação.',
      );
    }

    if (data['status']?.toString() != 'pending') {
      throw Exception(
        'Esta solicitação não está mais pendente.',
      );
    }

    // Primeiro marca a solicitação como aceita.
    await requestRef.update({
      'status': 'accepted',
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Depois cria a relação de amizade.
    await _createFriendship(
      senderId,
      receiverId,
    );
  }

  // ============================================================
  // CRIAR AMIZADE
  // ============================================================

  Future<void> _createFriendship(
    String userA,
    String userB,
  ) async {
    final friendshipId = _buildFriendshipId(
      userA,
      userB,
    );

    await _firestore
        .collection('friendships')
        .doc(friendshipId)
        .set({
      'userIds': [
        userA,
        userB,
      ],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Atualiza os contadores.
    await _incrementFollowing(userA);
    await _incrementFollowers(userA);

    await _incrementFollowing(userB);
    await _incrementFollowers(userB);
  }

  // ============================================================
  // ID ÚNICO DA AMIZADE
  // ============================================================

  String _buildFriendshipId(
    String userA,
    String userB,
  ) {
    final ids = [
      userA,
      userB,
    ]..sort();

    return '${ids[0]}_${ids[1]}';
  }

  // ============================================================
  // ATUALIZAR SEGUIDORES
  // ============================================================

  Future<void> _incrementFollowers(
    String uid,
  ) async {
    final userReference =
        await _findUserDocument(uid);

    if (userReference == null) {
      return;
    }

    await userReference.update({
      'followersCount':
          FieldValue.increment(1),
    });
  }

  // ============================================================
  // ATUALIZAR SEGUINDO
  // ============================================================

  Future<void> _incrementFollowing(
    String uid,
  ) async {
    final userReference =
        await _findUserDocument(uid);

    if (userReference == null) {
      return;
    }

    await userReference.update({
      'followingCount':
          FieldValue.increment(1),
    });
  }

  // ============================================================
  // ENCONTRAR USUÁRIO
  // ============================================================

  Future<DocumentReference<Map<String, dynamic>>?>
      _findUserDocument(
    String uid,
  ) async {
    final idosoReference = _firestore
        .collection('idosos')
        .doc(uid);

    final idosoSnapshot =
        await idosoReference.get();

    if (idosoSnapshot.exists) {
      return idosoReference;
    }

    final familiarReference = _firestore
        .collection('familiares')
        .doc(uid);

    final familiarSnapshot =
        await familiarReference.get();

    if (familiarSnapshot.exists) {
      return familiarReference;
    }

    return null;
  }

  // ============================================================
  // RECUSAR SOLICITAÇÃO
  // ============================================================

  Future<void> rejectRequest(
    String requestId,
  ) async {
    final String? currentUserId = _currentUserId;

    if (currentUserId == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    final requestRef =
        _requests.doc(requestId);

    final requestSnapshot =
        await requestRef.get();

    if (!requestSnapshot.exists ||
        requestSnapshot.data() == null) {
      throw Exception(
        'Solicitação não encontrada.',
      );
    }

    final data =
        requestSnapshot.data()!;

    if (data['receiverId']?.toString() !=
        currentUserId) {
      throw Exception(
        'Você não pode recusar esta solicitação.',
      );
    }

    if (data['status']?.toString() !=
        'pending') {
      throw Exception(
        'Esta solicitação não está mais pendente.',
      );
    }

    await requestRef.update({
      'status': 'rejected',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // CANCELAR SOLICITAÇÃO
  // ============================================================

  Future<void> cancelRequest(
    String requestId,
  ) async {
    final String? currentUserId =
        _currentUserId;

    if (currentUserId == null) {
      throw Exception(
        'Usuário não autenticado.',
      );
    }

    final requestRef =
        _requests.doc(requestId);

    final requestSnapshot =
        await requestRef.get();

    if (!requestSnapshot.exists ||
        requestSnapshot.data() == null) {
      throw Exception(
        'Solicitação não encontrada.',
      );
    }

    final data =
        requestSnapshot.data()!;

    if (data['senderId']?.toString() !=
        currentUserId) {
      throw Exception(
        'Você não pode cancelar esta solicitação.',
      );
    }

    if (data['status']?.toString() !=
        'pending') {
      throw Exception(
        'Esta solicitação não está mais pendente.',
      );
    }

    await requestRef.delete();
  }

  // ============================================================
  // BUSCAR SOLICITAÇÃO ENTRE DOIS USUÁRIOS
  // ============================================================

  Future<
      QueryDocumentSnapshot<
          Map<String, dynamic>>?> _findRequest(
    String userId,
    String otherUserId,
  ) async {
    final sentSnapshot =
        await _requests
            .where(
              'senderId',
              isEqualTo: userId,
            )
            .where(
              'receiverId',
              isEqualTo: otherUserId,
            )
            .limit(1)
            .get();

    if (sentSnapshot.docs.isNotEmpty) {
      return sentSnapshot.docs.first;
    }

    final receivedSnapshot =
        await _requests
            .where(
              'senderId',
              isEqualTo: otherUserId,
            )
            .where(
              'receiverId',
              isEqualTo: userId,
            )
            .limit(1)
            .get();

    if (receivedSnapshot.docs.isNotEmpty) {
      return receivedSnapshot.docs.first;
    }

    return null;
  }

  // ============================================================
  // VERIFICAR STATUS
  // ============================================================

  Future<String?> getRequestStatus(
    String otherUserId,
  ) async {
    final String? currentUserId =
        _currentUserId;

    if (currentUserId == null) {
      return null;
    }

    if (otherUserId.trim().isEmpty ||
        otherUserId == currentUserId) {
      return null;
    }

    final request =
        await _findRequest(
      currentUserId,
      otherUserId,
    );

    if (request == null) {
      return null;
    }

    return request
        .data()['status']
        ?.toString();
  }

  // ============================================================
  // SOLICITAÇÕES RECEBIDAS
  // ============================================================

  Stream<
      QuerySnapshot<
          Map<String, dynamic>>>
      getReceivedRequests() {
    final String? currentUserId =
        _currentUserId;

    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _requests
        .where(
          'receiverId',
          isEqualTo: currentUserId,
        )
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }

  // ============================================================
  // SOLICITAÇÕES ENVIADAS
  // ============================================================

  Stream<
      QuerySnapshot<
          Map<String, dynamic>>>
      getSentRequests() {
    final String? currentUserId =
        _currentUserId;

    if (currentUserId == null) {
      return const Stream.empty();
    }

    return _requests
        .where(
          'senderId',
          isEqualTo: currentUserId,
        )
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .orderBy(
          'createdAt',
          descending: true,
        )
        .snapshots();
  }
}