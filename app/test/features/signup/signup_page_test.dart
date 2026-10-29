import 'package:app/features/signup/presentation/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('valida o e-mail antes de avançar no cadastro', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Maria Silva');
    await tester.enterText(fields.at(1), 'email-invalido');
    await tester.enterText(fields.at(2), 'senha123');
    final continueButton = find.widgetWithText(ElevatedButton, 'Avançar');
    await tester.ensureVisible(continueButton);
    await tester.pumpAndSettle();
    await tester.tap(continueButton);
    await tester.pump();

    expect(find.text('Por favor, insira um e-mail válido.'), findsOneWidget);
  });

  testWidgets('valida linkedElderEmail no cadastro de familiar',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    final familyFlowToggle = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('É um familiar?'),
    );
    await tester.tap(familyFlowToggle);
    await tester.pumpAndSettle();

    var fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Maria Silva');
    await tester.enterText(fields.at(1), 'maria@example.com');
    await tester.enterText(fields.at(2), 'senha123');
    final continueButton = find.widgetWithText(ElevatedButton, 'Avançar');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filho(a)').last);
    await tester.pumpAndSettle();

    final termsCheckbox = find.byType(Checkbox);
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pump();

    fields = find.byType(TextField);
    await tester.enterText(fields.last, 'email-invalido');
    final createButton = find.widgetWithText(ElevatedButton, 'Criar');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pump();

    expect(
      find.text('Por favor, insira um e-mail válido para o idoso.'),
      findsOneWidget,
    );
  });

  testWidgets('aceita linkedElderEmail com espaços externos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupPage()));

    final familyFlowToggle = find.byWidgetPredicate(
      (widget) =>
          widget is RichText &&
          widget.text.toPlainText().contains('É um familiar?'),
    );
    await tester.tap(familyFlowToggle);
    await tester.pumpAndSettle();

    var fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Maria Silva');
    await tester.enterText(fields.at(1), 'maria@example.com');
    await tester.enterText(fields.at(2), 'senha123');
    final continueButton = find.widgetWithText(ElevatedButton, 'Avançar');
    await tester.ensureVisible(continueButton);
    await tester.tap(continueButton);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownMenu<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Filho(a)').last);
    await tester.pumpAndSettle();

    final termsCheckbox = find.byType(Checkbox);
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pump();

    fields = find.byType(TextField);
    await tester.enterText(fields.last, '  elder@example.com  ');
    final createButton = find.widgetWithText(ElevatedButton, 'Criar');
    await tester.ensureVisible(createButton);
    await tester.tap(createButton);
    await tester.pump();

    expect(
      find.text('Por favor, insira um e-mail válido para o idoso.'),
      findsNothing,
    );
  });
}
