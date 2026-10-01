import 'package:app/features/notifications/data/notification_service.dart';
import 'package:app/features/notifications/domain/models/app_notification.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cria payload claro para novo vinculo familiar', () {
    final payload = FamilyNotificationService.familyLinkCreatedPayload(
      familyUid: 'family-1',
      familyName: 'Maria Silva',
    );

    expect(payload['type'], 'family_link_created');
    expect(payload['title'], 'Novo familiar vinculado');
    expect(
      payload['message'],
      'Maria Silva passou a supervisionar você como familiar/responsável.',
    );
    expect(payload['familyUid'], 'family-1');
    expect(payload['read'], isFalse);
  });

  test('identifica notificacao de vinculo pelo tipo', () {
    const notification = AppNotification(
      id: 'notification-1',
      type: 'family_link_created',
      title: 'Novo familiar vinculado',
      message: 'Mensagem',
      createdAt: null,
    );

    expect(notification.isFamilyLinkNotification, isTrue);
  });

  test('cria notificacao de bloqueio com o nome do idoso', () {
    final payload = FamilyNotificationService.familyLinkStatusPayload(
      familyUid: 'family-1',
      elderUid: 'elder-1',
      elderName: 'João Silva',
      status: 'blocked',
    );

    expect(payload['type'], 'family_link_blocked');
    expect(payload['title'], 'Vínculo familiar bloqueado');
    expect(
      payload['message'],
      'João Silva bloqueou seu acesso ao vínculo familiar.',
    );
  });

  test('cria notificacao de reativacao com o nome do idoso', () {
    final payload = FamilyNotificationService.familyLinkStatusPayload(
      familyUid: 'family-1',
      elderUid: 'elder-1',
      elderName: 'João Silva',
      status: 'active',
    );

    expect(payload['type'], 'family_link_reactivated');
    expect(payload['title'], 'Vínculo familiar reativado');
    expect(
      payload['message'],
      'João Silva reativou seu acesso ao vínculo familiar.',
    );
  });
}
