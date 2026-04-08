// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:stitch/main.dart';
import 'package:stitch/repositories/mood_repository.dart';
import 'package:stitch/repositories/auth_repository.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    final moodRepository = MoodRepository();
    final authRepository = AuthRepository();
    final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);
    await tester.pumpWidget(MoodLogApp(
      authRepository: authRepository,
      moodRepository: moodRepository,
      themeModeNotifier: themeModeNotifier,
    ));

    // Verify that our app name is present.
    expect(find.text('Mindful Canvas'), findsOneWidget);
  });
}
