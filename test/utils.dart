import 'package:consent_app/consent_app.dart';
import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<GlobalKey<ConsentAppState>> nextPageTest(WidgetTester tester) async {
  final key = GlobalKey<ConsentAppState>();
  await tester.pumpWidget(ConsentApp(key: key, pathToConsentDocument: "assets/consent.md", child: Text("Hello World"),));
  await tester.pumpAndSettle();

  // Tap the next button;
  expect(find.byKey(nextButtonKey), findsOneWidget);
  final ElevatedButton button = find.byKey(nextButtonKey).evaluate().first.widget;
  button.onPressed();
  await tester.pumpAndSettle();
  expect(find.text('Consent (2 of ${key.currentState.totalSections})'), findsOneWidget);
  return key;
}

Future<void> goToAuthorizePage(WidgetTester tester, GlobalKey<ConsentAppState> key) async {
  for(int i = 0; i<key.currentState.totalSections - 1;i++){
    expect(find.byKey(nextButtonKey), findsOneWidget);
    final ElevatedButton button = find.byKey(nextButtonKey).evaluate().first.widget;
    button.onPressed();
    await tester.pumpAndSettle();
  }
}