import 'package:cap_advisor/view/home_view.dart';
import 'package:cap_advisor/view/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cap_advisor/main.dart';

void main() {
  group('App Initialization Tests', () {
    testWidgets('Login view is shown when not authenticated', (WidgetTester tester) async {
      // Build our app and trigger a frame with isAuthenticated set to false.
      await tester.pumpWidget(MyApp(isAuthenticated: false));

      // Verify that the login view is shown.
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('Home view is shown when authenticated', (WidgetTester tester) async {
      // Build our app and trigger a frame with isAuthenticated set to true.
      await tester.pumpWidget(MyApp(isAuthenticated: true));

      // Verify that the home view is shown.
      expect(find.byType(HomeView), findsOneWidget);
    });
  });
}
