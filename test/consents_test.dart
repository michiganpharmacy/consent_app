import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// This is from the Flutter demo app
// and is not being used currently.
import 'package:consent_app/consent_app.dart';

import 'utils.dart';


void main() {

  testWidgets("Consents test", (WidgetTester tester) async {
    final key = GlobalKey<ConsentAppState>();
    await tester.pumpWidget(ConsentApp(key: key, pathToConsentDocument: "assets/consent.md", child: Text("Hello World")));
    await tester.pumpAndSettle();

    await goToAuthorizePage(tester, key);

    expect(find.byKey(consentsButtonKey), findsOneWidget);
    final ElevatedButton button = find.byKey(consentsButtonKey).evaluate().first.widget;
    button.onPressed();
    await tester.pumpAndSettle();
    expect(find.text('Hello World'), findsOneWidget);
  });

}
