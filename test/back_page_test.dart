import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';


void main() {

  testWidgets("Back page test", (WidgetTester tester) async {
    final key = await nextPageTest(tester);

    // Tap the next button;
    expect(find.byKey(backButtonKey), findsOneWidget);
    final ElevatedButton button =
        find.byKey(backButtonKey).evaluate().first.widget as ElevatedButton;
    button.onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('Consent (1 of ${key.currentState?.totalSections})'),
        findsOneWidget);
  });

}
