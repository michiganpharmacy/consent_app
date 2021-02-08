import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// This is from the Flutter demo app
// and is not being used currently.
import 'package:consent_app/consent_app.dart';

import 'utils.dart';


void main() {
  testWidgets('Consent smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final key = GlobalKey<ConsentAppState>();
    await tester.pumpWidget(ConsentApp(key: key, pathToConsentDocument: "assets/consent.md", child: Text("Hello World")));
    await tester.pump(Duration(seconds: 1));

    // Verify that our consent screen starts at 1 of {totalSections}.
    expect(find.text('Consent (1 of ${key.currentState.totalSections})'), findsOneWidget);
  });


}
