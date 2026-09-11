class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final DateTime createdAt;
  final bool isCurrentUser;
  final String status; // 'sent', 'delivered', 'read'

  const MessageModel({
    required this.id,
    required this.text,
    required this.senderId,
    required this.createdAt,
    required this.isCurrentUser,
    this.status = 'sent',
  });

  String get time {
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  factory MessageModel.fromMap(
    Map<String, dynamic> map,
    String currentUserId,
  ) {
    final rawCreatedAt = map['createdAt'];
    final createdAt = rawCreatedAt is DateTime
        ? rawCreatedAt
        : rawCreatedAt is String
            ? DateTime.tryParse(rawCreatedAt) ??
                DateTime.fromMillisecondsSinceEpoch(0)
            : rawCreatedAt?.toDate() as DateTime? ??
                DateTime.fromMillisecondsSinceEpoch(0);
    final senderId = map['senderId'] as String? ?? '';

    return MessageModel(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      senderId: senderId,
      createdAt: createdAt,
      isCurrentUser: senderId == currentUserId,
      status: map['status'] as String? ?? 'sent',
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'text': text,
      'senderId': senderId,
      'createdAt': createdAt,
      'status': status,
    };
  }
}