
import 'package:app/features/family_link/services/family_link_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FamilyLinkService.hasActiveLink', () {
    final elderData = {
      'email': 'idoso@example.com',
      'linkedFamilyUid': 'family-1',
      'familyLinkStatus': 'active',
    };

    final familyData = {
      'linkedElderUid': 'elder-1',
      'familyLinkStatus': 'active',
    };

    test('reconhece vínculo ativo com os identificadores corretos', () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-1',
        elderData: elderData,
        familyData: familyData,
      );

      expect(isActive, isTrue);
    });

    test('nega vínculo quando o idoso bloqueou o familiar', () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-1',
        elderData: {
          ...elderData,
          'familyLinkStatus': 'blocked',
        },
        familyData: familyData,
      );

      expect(isActive, isFalse);
    });

    test('nega vínculo quando o familiar está com status bloqueado', () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-1',
        elderData: elderData,
        familyData: {
          ...familyData,
          'familyLinkStatus': 'blocked',
        },
      );

      expect(isActive, isFalse);
    });

    test('nega vínculo quando o UID do idoso não corresponde', () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-2',
        familyUid: 'family-1',
        elderData: elderData,
        familyData: familyData,
      );

      expect(isActive, isFalse);
    });

    test('nega vínculo quando o UID do familiar não corresponde', () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-2',
        elderData: elderData,
        familyData: familyData,
      );

      expect(isActive, isFalse);
    });

    test('aceita vínculo por e-mail quando não há UID do idoso vinculado',
        () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-1',
        elderData: {
          'email': 'idoso@example.com',
        },
        familyData: {
          'linkedElderEmail': 'idoso@example.com',
          'familyLinkStatus': 'active',
        },
      );

      expect(isActive, isTrue);
    });

    test('ignora espaços extras ao comparar e-mails no vínculo por e-mail',
        () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-1',
        elderData: {
          'email': '  idoso@example.com  ',
        },
        familyData: {
          'linkedElderEmail': '  idoso@example.com  ',
          'familyLinkStatus': 'active',
        },
      );

      expect(isActive, isTrue);
    });

    test('nega vínculo por e-mail quando os e-mails são diferentes', () {
      final isActive = FamilyLinkService.hasActiveLink(
        elderUid: 'elder-1',
        familyUid: 'family-1',
        elderData: {
          'email': 'idoso@example.com',
        },
        familyData: {
          'linkedElderEmail': 'outra@example.com',
          'familyLinkStatus': 'active',
        },
      );

      expect(isActive, isFalse);
    });
  });
}
