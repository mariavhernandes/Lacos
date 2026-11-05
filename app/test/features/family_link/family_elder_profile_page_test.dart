import 'package:app/features/family_link/presentation/family_elder_profile_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FamilyElderProfilePage.titleForSection', () {
    test('usa dinamicamente o nome do idoso nos títulos', () {
      expect(
        FamilyElderProfilePage.titleForSection(
          FamilyElderProfileSection.interests,
          'Maria Silva',
        ),
        'Interesses de Maria Silva',
      );
      expect(
        FamilyElderProfilePage.titleForSection(
          FamilyElderProfileSection.friends,
          'Maria Silva',
        ),
        'Amigos de Maria Silva',
      );
      expect(
        FamilyElderProfilePage.titleForSection(
          FamilyElderProfileSection.linkInfo,
          'Maria Silva',
        ),
        'Informações do vínculo',
      );
    });
  });

  group('FamilyElderProfilePage.extractInterestsForDisplay', () {
    test('normaliza uma lista e remove itens vazios', () {
      expect(
        FamilyElderProfilePage.extractInterestsForDisplay(
          [' Dominó ', '', 'Caminhada'],
        ),
        ['Dominó', 'Caminhada'],
      );
    });

    test('aceita mapas e strings separados por vírgula', () {
      expect(
        FamilyElderProfilePage.extractInterestsForDisplay({
          'one': 'Jardinagem',
          'two': ' Dança ',
        }),
        ['Jardinagem', 'Dança'],
      );
      expect(
        FamilyElderProfilePage.extractInterestsForDisplay('Dominó, Caminhada'),
        ['Dominó', 'Caminhada'],
      );
    });

    test('retorna lista vazia para interesses ausentes', () {
      expect(FamilyElderProfilePage.extractInterestsForDisplay(null), isEmpty);
      expect(FamilyElderProfilePage.extractInterestsForDisplay('  '), isEmpty);
    });
  });
}
