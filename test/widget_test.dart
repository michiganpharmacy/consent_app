import 'package:flutter_test/flutter_test.dart';

// This is from the Flutter demo app
// and is not being used currently.
import 'package:consent_app/consent_app.dart';

void main() {
  testWidgets('Consent smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(ConsentApp(pathToConsentDocument: "assets/consent.md"));
    await tester.pump(Duration(seconds: 1));

    // Verify that our consent screen starts at 1.
    expect(find.text('Consent (1 of 10)'), findsOneWidget);
    //expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    //await tester.tap(find.byIcon(Icons.add));
    //await tester.pump();

    // Verify that our counter has incremented.
    //expect(find.text('0'), findsNothing);
    //expect(find.text('1'), findsOneWidget);
  });
}
