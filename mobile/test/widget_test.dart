import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_daily_helper/app/app_shell.dart';
import 'package:ai_daily_helper/app/app_state.dart';
import 'package:ai_daily_helper/core/widgets/app_animations.dart';
import 'package:ai_daily_helper/main.dart';

Future<AppState> _createTestState({bool loops = false}) async {
  AppMotion.enableAmbientLoops = loops;
  GoogleFonts.config.allowRuntimeFetching = false;
  SharedPreferences.setMockInitialValues({});
  final state = AppState();
  await state.init(checkRemote: false);
  return state;
}

void main() {
  testWidgets('Full onboarding flow renders cleanly without overflow', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = await _createTestState();
    await tester.pumpWidget(AiDailyHelperApp(appState: state, initialRoute: AppRoute.splash));
    await tester.pump();
    expect(find.text('AI Daily Helper'), findsOneWidget);
    expect(find.text('Remember more. Do more.'), findsOneWidget);

    // Tap splash to enter Welcome
    await tester.tap(find.text('AI Daily Helper'));
    await tester.pumpAndSettle();
    expect(find.text('YOUR EVERYDAY SECOND BRAIN'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);

    // Enter What It Does
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('HOW IT WORKS'), findsOneWidget);
    expect(find.text('Capture naturally'), findsOneWidget);

    // Enter Create Account
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Create account'), findsNWidgets(2));

    // Enter Set Your Goals
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();
    expect(find.text('PERSONALIZE · 1 OF 2'), findsOneWidget);
    expect(find.text('Work & productivity'), findsOneWidget);

    // Enter Personalize
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('PERSONALIZE · 2 OF 2'), findsOneWidget);
    expect(find.text('PREFERRED TONE'), findsOneWidget);

    // Finish setup -> Home Today
    await tester.tap(find.text('Finish setup'));
    await tester.pumpAndSettle();
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('What am I forgetting?'), findsOneWidget);
  });

  testWidgets('Core tabs, Brain Dump, Settings, and Phase 2 screens work cleanly', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = await _createTestState();
    await tester.pumpWidget(AiDailyHelperApp(appState: state, initialRoute: AppRoute.mainTabs));
    await tester.pumpAndSettle();

    // Home Today
    expect(find.text('Send client proposal'), findsOneWidget);
    expect(find.text('Capture a thought'), findsOneWidget);

    // Tasks Tab
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    expect(find.text('TODAY · NOV 10'), findsOneWidget);

    // Speak (AI Chat) Tab
    await tester.tap(find.text('Speak'));
    await tester.pumpAndSettle();
    expect(find.text('Your assistant'), findsOneWidget);
    expect(find.text('Confirm reminder →'), findsOneWidget);

    // Confirm reminder updates state
    await tester.tap(find.text('Confirm reminder →'));
    await tester.pumpAndSettle();
    expect(find.text('Confirmed ✓'), findsOneWidget);

    // Shopping Tab
    await tester.tap(find.text('Shopping'));
    await tester.pumpAndSettle();
    expect(find.text('Shopping list'), findsOneWidget);
    expect(find.text('Eggs'), findsOneWidget);

    // Memory Tab
    await tester.tap(find.text('Memory'));
    await tester.pumpAndSettle();
    expect(find.text('Your memories'), findsOneWidget);
    expect(find.text('Mom’s birthday'), findsOneWidget);

    // Voice Recording Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.voiceRecording),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('VOICE CAPTURE'), findsOneWidget);

    // Brain Dump Review Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.brainDumpReview),
    );
    await tester.pumpAndSettle();
    expect(find.text('Review your voice note'), findsOneWidget);
    expect(find.text('Save 6 actions'), findsOneWidget);

    // Reminders Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.reminders),
    );
    await tester.pumpAndSettle();
    expect(find.text('Reminders'), findsOneWidget);
    expect(find.text('Dentist appointment'), findsOneWidget);

    // Keep for Later Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.keepForLater),
    );
    await tester.pumpAndSettle();
    expect(find.text('Keep for later'), findsOneWidget);

    // Goals Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.goals),
    );
    await tester.pumpAndSettle();
    expect(find.text('Goals & achievements'), findsOneWidget);

    // Affirmations Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.affirmations),
    );
    await tester.pumpAndSettle();
    expect(find.text('My affirmations'), findsOneWidget);

    // Settings & Privacy Screen
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.settings),
    );
    await tester.pumpAndSettle();
    expect(find.text('Profile & settings'), findsOneWidget);

    // Phase 2 Screens
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.budgeting),
    );
    await tester.pumpAndSettle();
    expect(find.text('Smart budgeting'), findsOneWidget);

    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.productivity),
    );
    await tester.pumpAndSettle();
    expect(find.text('Productivity insights'), findsOneWidget);

    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.emailReports),
    );
    await tester.pumpAndSettle();
    expect(find.text('Email reports'), findsOneWidget);

    // Empty state renders cleanly when all data cleared
    await state.deleteAllMyData();
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.mainTabs),
    );
    await tester.pumpAndSettle();
    expect(find.text('Create your first task'), findsOneWidget);
  });

  testWidgets('Ambient animations run smoothly on Splash, Welcome, and Voice Recording',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = await _createTestState(loops: true);
    addTearDown(() => AppMotion.enableAmbientLoops = true);

    await tester.pumpWidget(AiDailyHelperApp(appState: state, initialRoute: AppRoute.welcome));
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Today’s plan'), findsOneWidget);

    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.voiceRecording),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('VOICE CAPTURE'), findsOneWidget);
  });
}
