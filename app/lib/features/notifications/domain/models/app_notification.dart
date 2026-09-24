import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.familyUid,
    this.familyName,
    this.elderUid,
    this.elderName,
    this.isRead = false,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final DateTime? createdAt;
  final String? familyUid;
  final String? familyName;
  final String? elderUid;
  final String? elderName;
  final bool isRead;

  bool get isFamilyLinkNotification => type == 'family_link_created';

  factory AppNotification.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? <String, dynamic>{};
    final createdAtValue = data['createdAt'];

    return AppNotification(
      id: document.id,
      type: data['type']?.toString() ?? 'general',
      title: data['title']?.toString() ?? 'Notificação',
      message: data['message']?.toString() ?? '',
      createdAt: createdAtValue is Timestamp ? createdAtValue.toDate() : null,
      familyUid: data['familyUid']?.toString(),
      familyName: data['familyName']?.toString(),
      elderUid: data['elderUid']?.toString(),
      elderName: data['elderName']?.toString(),
      isRead: data['read'] == true,
    );
  }
}
