import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kyfr/main.dart';

void main() {
  Future<void> login(WidgetTester tester) async {
    await tester.pumpWidget(const KyfrApp());

    await tester.enterText(find.byType(EditableText).at(0), 'rishi@test.com');
    await tester.enterText(find.byType(EditableText).at(1), 'password');
    await tester.tap(find.text('Login').last);
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
  }

  testWidgets('Shows the authentication screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KyfrApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Login'), findsWidgets);
    expect(find.text('Signup'), findsOneWidget);
  });

  testWidgets('Can add money from the dashboard', (WidgetTester tester) async {
    await login(tester);

    expect(find.text('Rs 12500'), findsOneWidget);

    await tester.tap(find.text('Add money'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(EditableText).last, '500');
    await tester.tap(find.text('Add to wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Rs 13000'), findsOneWidget);
  });

  testWidgets('Send money requires valid email and amount', (
    WidgetTester tester,
  ) async {
    await login(tester);

    await tester.tap(find.text('Send').last);
    await tester.pumpAndSettle();

    ElevatedButton button() {
      return tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Send money'),
      );
    }

    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(EditableText).at(0), 'not-an-email');
    await tester.enterText(find.byType(EditableText).at(1), '100');
    await tester.pump();

    expect(button().onPressed, isNull);

    await tester.enterText(find.byType(EditableText).at(0), 'priya@test.com');
    await tester.pump();

    expect(button().onPressed, isNotNull);

    await tester.enterText(find.byType(EditableText).at(1), '12.3.4');
    await tester.pump();

    expect(find.text('12.3.4'), findsNothing);
  });
}
