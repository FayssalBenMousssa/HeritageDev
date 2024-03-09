// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:heritage/main.dart';

void main() {
  testWidgets('Store Data in Firebase test', (WidgetTester tester) async {
    // Build your app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Find the email and password text fields and enter the credentials.
    await tester.enterText(find.byKey(const Key('emailTextField')), 'HeritageBookApp@gmail.com');
    await tester.enterText(find.byKey(const Key('passwordTextField')), 'AbirBerbeche');

    // Tap the login button and trigger a frame.
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pump();

    // Verify that the user is logged in successfully.
    expect(find.text('Welcome to the Home Page!'), findsOneWidget);
    expect(find.text('User Email: HeritageBookApp@gmail.com'), findsOneWidget);

    // Tap the button to store data in Firebase.
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

  });


}
