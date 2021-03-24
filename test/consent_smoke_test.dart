// This is from the Flutter demo app
// and is not being used currently.
import 'package:consent_app/consent_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Consent smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final key = GlobalKey<ConsentAppState>();
    await tester.pumpWidget(MaterialApp(
      home: ConsentApp(
          key: key,
          pathToConsentDocument: "assets/consent.md",
          onAccept: () => Text("Hello World")),
    ));
    await tester.pumpAndSettle(Duration(seconds: 1));

    // Verify that our consent screen starts at 1 of {totalSections}.
    expect(find.text('Consent (1 of ${key.currentState?.totalSections})'),
        findsOneWidget);
  });
}
