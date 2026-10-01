import 'package:app/features/family_link/services/family_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reconhece vinculo ativo com os novos identificadores', () {
    final isActive = FamilyLinkService.hasActiveLink(
      elderUid: 'elder-1',
      familyUid: 'family-1',
      elderData: {
        'email': 'idoso@example.com',
        'linkedFamilyUid': 'family-1',
        'familyLinkStatus': 'active',
      },
      familyData: {
        'linkedElderUid': 'elder-1',
        'familyLinkStatus': 'active',
      },
    );

    expect(isActive, isTrue);
  });

  test('nega supervisao quando o idoso bloqueou o familiar', () {
    final isActive = FamilyLinkService.hasActiveLink(
      elderUid: 'elder-1',
      familyUid: 'family-1',
      elderData: {
        'email': 'idoso@example.com',
        'linkedFamilyUid': 'family-1',
        'familyLinkStatus': 'blocked',
      },
      familyData: {
        'linkedElderUid': 'elder-1',
        'familyLinkStatus': 'blocked',
      },
    );

    expect(isActive, isFalse);
  });
}
