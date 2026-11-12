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

    // Inline validation on empty submit, then fill valid signup fields
    await tester.tap(find.text('Create account').last);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your full name.'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'Azeem');
    await tester.enterText(find.byType(TextField).at(1), 'azeem@example.com');
    await tester.enterText(find.byType(TextField).at(2), 'Secret123!');
    await tester.pumpAndSettle();
    expect(find.text('Strong password'), findsOneWidget);

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
    expect(find.textContaining('TODAY ·'), findsOneWidget);

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

  testWidgets('Interactive sheets, edits, and Phase 2 actions work cleanly', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = await _createTestState();

    // Home -> What am I forgetting spotlight card is visible above the fold
    await tester.pumpWidget(AiDailyHelperApp(appState: state, initialRoute: AppRoute.mainTabs));
    await tester.pumpAndSettle();
    await tester.tap(find.text('What am I forgetting?'));
    await tester.pumpAndSettle();
    expect(find.text('Listen aloud'), findsOneWidget);
    // Dismiss bottom sheet by tapping the barrier above the sheet
    await tester.tapAt(const Offset(20, 40));
    await tester.pumpAndSettle();

    // Settings -> Assistant tone sheet -> Professional
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.settings),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assistant tone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Professional'));
    await tester.pumpAndSettle();
    expect(state.user.preferredTone, 'professional');

    // Goals -> Achievement history sheet -> Back to goals
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.goals),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Achievement history'));
    await tester.pumpAndSettle();
    expect(find.text('Back to goals'), findsOneWidget);
    await tester.tap(find.text('Back to goals'));
    await tester.pumpAndSettle();

    // Budgeting -> Monthly budget sheet & template action, Daily tab, and Total & Folders
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.budgeting),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Use last month’s template'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use last month’s template'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bills'), findsAtLeastNWidgets(1));

    // Switch to Daily tab
    await tester.tap(find.text('Daily'));
    await tester.pumpAndSettle();
    expect(find.text('TODAY’S DAILY SPENDING'), findsOneWidget);

    // Switch to Total & Folders tab
    await tester.tap(find.text('Total & Folders'));
    await tester.pumpAndSettle();
    expect(find.text('TOTAL CALCULATION'), findsOneWidget);
    expect(find.text('= Combined Total'), findsOneWidget);
    expect(find.text('Daily Essentials'), findsOneWidget);

    // Settings -> Log out -> confirmation modal -> Welcome screen
    await state.signInExisting();
    await tester.pumpWidget(
      AiDailyHelperApp(appState: state, initialRoute: AppRoute.settings),
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -350));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out of account?'), findsOneWidget);
    await tester.tap(find.text('Log out').last);
    await tester.pumpAndSettle();
    expect(state.user.onboardingCompleted, isFalse);
    expect(find.text('Get started'), findsOneWidget);

    // Welcome -> Sign in -> Login screen -> Main Home
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    expect(find.text('Forgot password?'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'Secret123!');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sign in').last);
    await tester.pumpAndSettle();
    expect(state.user.onboardingCompleted, isTrue);
    expect(find.text('Due today'), findsOneWidget);
  });
}
