import 'package:consent_app/consent_app.dart';
import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

void main() {
  testWidgets("Decline test", (WidgetTester tester) async {
    final key = GlobalKey<ConsentAppState>();
    await tester.pumpWidget(MaterialApp(
      home: ConsentApp(
          key: key,
          pathToConsentDocument: "assets/consent.md",
          onAccept: () => Text("Hello World")),
    ));
    await tester.pumpAndSettle();

    await goToAuthorizePage(tester, key);

    expect(find.byKey(declineButtonKey), findsOneWidget);
    final ElevatedButton button =
        find.byKey(declineButtonKey).evaluate().first.widget as ElevatedButton;
    button.onPressed!();
    await tester.pumpAndSettle();
    expect(find.text('Consent (1 of ${key.currentState?.totalSections})'),
        findsOneWidget);
  });
}
