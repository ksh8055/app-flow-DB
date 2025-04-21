import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sample/providers/trip_data_provider.dart';
import 'package:sample/screen/login_page.dart';

void main() {
  testWidgets('Login Page UI Test', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => TripData(),
          child: const LoginPage(),
        ),
      ),
    );

    expect(find.text('Driver Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('Login Button Interaction', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => TripData(),
          child: const LoginPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).first, 'test');
    await tester.enterText(find.byType(TextFormField).last, 'test');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}