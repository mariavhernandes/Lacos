import 'package:app/features/chat/screens/manage_messages_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('altera os switches visuais locais de links e alertas',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ManageMessagesScreen()),
    );

    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(2));
    expect(tester.widget<Switch>(switches.at(0)).value, isFalse);
    expect(tester.widget<Switch>(switches.at(1)).value, isTrue);

    await tester.ensureVisible(switches.at(0));
    await tester.pumpAndSettle();
    await tester.tap(switches.at(0));
    await tester.pump();
    await tester.ensureVisible(switches.at(1));
    await tester.pumpAndSettle();
    await tester.tap(switches.at(1));
    await tester.pump();

    expect(tester.widget<Switch>(switches.at(0)).value, isTrue);
    expect(tester.widget<Switch>(switches.at(1)).value, isFalse);
  });
}
