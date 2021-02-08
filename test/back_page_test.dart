import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// This is from the Flutter demo app
// and is not being used currently.
import 'package:consent_app/consent_app.dart';

import 'utils.dart';


void main() {

  testWidgets("Back page test", (WidgetTester tester) async {
    final key = await nextPageTest(tester);

    // Tap the next button;
    expect(find.byKey(backButtonKey), findsOneWidget);
    final ElevatedButton button = find.byKey(backButtonKey).evaluate().first.widget;
    button.onPressed();
    await tester.pumpAndSettle();
    expect(find.text('Consent (1 of ${key.currentState.totalSections})'), findsOneWidget);
  });

}
