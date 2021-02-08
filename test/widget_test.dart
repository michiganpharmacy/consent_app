import 'package:consent_app/src/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// This is from the Flutter demo app
// and is not being used currently.
import 'package:consent_app/consent_app.dart';

void main() {
  testWidgets('Consent smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final key = GlobalKey<ConsentAppState>();
    await tester.pumpWidget(ConsentApp(key: key, pathToConsentDocument: "assets/consent.md", child: Text("Hello World")));
    await tester.pump(Duration(seconds: 1));

    // Verify that our consent screen starts at 1 of {totalSections}.
    expect(find.text('Consent (1 of ${key.currentState.totalSections})'), findsOneWidget);
    //expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    //await tester.tap(find.byIcon(Icons.add));
    //await tester.pump();

    // Verify that our counter has incremented.
    //expect(find.text('0'), findsNothing);
    //expect(find.text('1'), findsOneWidget);
  });


  Future<GlobalKey<ConsentAppState>> _nextPageTest(WidgetTester tester) async {
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

  testWidgets("Next page test", _nextPageTest);

  testWidgets("Back page test", (WidgetTester tester) async {
    final key = await _nextPageTest(tester);

    // Tap the next button;
    expect(find.byKey(backButtonKey), findsOneWidget);
    final ElevatedButton button = find.byKey(backButtonKey).evaluate().first.widget;
    button.onPressed();
    await tester.pumpAndSettle();
    expect(find.text('Consent (1 of ${key.currentState.totalSections})'), findsOneWidget);
  });

  testWidgets("Consents test", (WidgetTester tester) async {
    final key = GlobalKey<ConsentAppState>();
    await tester.pumpWidget(ConsentApp(key: key, pathToConsentDocument: "assets/consent.md", child: Text("Hello World")));
    await tester.pumpAndSettle();

    // Tap the next button;
    for(int i = 0; i<key.currentState.totalSections - 1;i++){
      expect(find.byKey(nextButtonKey), findsOneWidget);
      final ElevatedButton button = find.byKey(nextButtonKey).evaluate().first.widget;
      button.onPressed();
      await tester.pumpAndSettle();
    }

    expect(find.byKey(consentsButtonKey), findsOneWidget);
    final ElevatedButton button = find.byKey(consentsButtonKey).evaluate().first.widget;
    button.onPressed();
    await tester.pumpAndSettle();
    expect(find.text('Hello World'), findsOneWidget);
  });
}
