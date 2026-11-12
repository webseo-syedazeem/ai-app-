import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import '../core/widgets/warm_scaffold.dart';
import '../features/assistant/ai_chat_screen.dart';
import '../features/assistant/brain_dump_review_screen.dart';
import '../features/assistant/voice_recording_screen.dart';
import '../features/growth/affirmations_screen.dart';
import '../features/growth/goals_screen.dart';
import '../features/home/home_today_screen.dart';
import '../features/memory/keep_for_later_screen.dart';
import '../features/memory/memory_screen.dart';
import '../features/onboarding/create_account_screen.dart';
import '../features/onboarding/personalize_screen.dart';
import '../features/onboarding/set_goals_screen.dart';
import '../features/onboarding/splash_screen.dart';
import '../features/onboarding/welcome_screen.dart';
import '../features/onboarding/what_it_does_screen.dart';
import '../features/phase2/budgeting_screen.dart';
import '../features/phase2/email_reports_screen.dart';
import '../features/phase2/productivity_screen.dart';
import '../features/planner/reminders_screen.dart';
import '../features/planner/shopping_screen.dart';
import '../features/planner/tasks_screen.dart';
import '../features/settings/settings_privacy_screen.dart';
import 'app_state.dart';

enum AppRoute {
  splash,
  welcome,
  whatItDoes,
  createAccount,
  signIn,
  setGoals,
  personalize,
  mainTabs,
  voiceRecording,
  brainDumpReview,
  reminders,
  keepForLater,
  goals,
  affirmations,
  settings,
  budgeting,
  productivity,
  emailReports,
}

class AppShell extends StatefulWidget {
  final AppState appState;
  final AppRoute initialRoute;

  const AppShell({
    super.key,
    required this.appState,
    this.initialRoute = AppRoute.splash,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late AppRoute _route;
  int _tabIndex = 0;
  StreamSubscription<Uri>? _deepLinkSub;
  final AppLinks _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _route = widget.initialRoute;
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleIncomingUri(initial);
      }
      _deepLinkSub = _appLinks.uriLinkStream.listen(_handleIncomingUri);
    } catch (_) {
      // Ignored in headless widget tests without platform channels.
    }
  }

  Future<void> _handleIncomingUri(Uri uri) async {
    if (uri.scheme != 'aidailyhelper' || uri.host != 'auth') return;
    final err = await widget.appState.handleAuthDeepLink(uri);
    if (!mounted) return;
    if (err != null && err.isNotEmpty) {
      showAppToast(context, err);
      return;
    }
    showAppToast(context, 'Signed in as ${widget.appState.user.fullName}');
    _switchTab(0);
  }

  @override
  void dispose() {
    _deepLinkSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialRoute != widget.initialRoute) {
      _route = widget.initialRoute;
      if (widget.initialRoute == AppRoute.mainTabs) {
        _tabIndex = 0;
      }
    }
  }

  void _go(AppRoute route) {
    setState(() => _route = route);
  }

  void _switchTab(int index) {
    setState(() {
      _tabIndex = index;
      _route = AppRoute.mainTabs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        if (!widget.appState.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final routeKey = _route == AppRoute.mainTabs
            ? ValueKey('tab_$_tabIndex')
            : ValueKey(_route.name);

        final isVerticalOverlay = _route == AppRoute.voiceRecording;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          reverseDuration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetBegin = isVerticalOverlay
                ? const Offset(0.0, 0.06)
                : const Offset(0.035, 0.0);
            final slide = Tween<Offset>(
              begin: offsetBegin,
              end: Offset.zero,
            ).animate(animation);
            final scale = Tween<double>(begin: 0.985, end: 1.0).animate(animation);
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );
          },
          child: KeyedSubtree(
            key: routeKey,
            child: _buildCurrentScreen(),
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen() {
    switch (_route) {
          case AppRoute.splash:
            return SplashScreen(
              onFinished: () => _go(
                widget.appState.user.onboardingCompleted
                    ? AppRoute.mainTabs
                    : AppRoute.welcome,
              ),
            );
          case AppRoute.welcome:
            return WelcomeScreen(
              onGetStarted: () => _go(AppRoute.whatItDoes),
              onSignIn: () => _go(AppRoute.signIn),
            );
          case AppRoute.whatItDoes:
            return WhatItDoesScreen(
              onBack: () => _go(AppRoute.welcome),
              onContinue: () => _go(AppRoute.createAccount),
            );
          case AppRoute.createAccount:
            return _buildAuthScreen(
              signInMode: false,
              initialName: '',
              initialEmail: '',
              onBack: () => _go(AppRoute.whatItDoes),
            );
          case AppRoute.signIn:
            return _buildAuthScreen(
              signInMode: true,
              initialName: widget.appState.user.fullName,
              initialEmail: widget.appState.user.email,
              onBack: () => _go(AppRoute.welcome),
            );
          case AppRoute.setGoals:
            return SetYourGoalsScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.createAccount),
              onContinue: () => _go(AppRoute.personalize),
            );
          case AppRoute.personalize:
            return PersonalizeScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.setGoals),
              onFinish: () => _switchTab(0),
            );
          case AppRoute.voiceRecording:
            return VoiceRecordingScreen(
              appState: widget.appState,
              onClose: () => _go(AppRoute.mainTabs),
              onCompleteSingle: (transcript) async {
                _switchTab(2);
                await widget.appState.sendChatMessage(transcript, speakReply: true);
              },
              onCompleteBrainDump: (_) => _go(AppRoute.brainDumpReview),
            );
          case AppRoute.brainDumpReview:
            return BrainDumpReviewScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
              onSaved: () => _switchTab(1),
            );
          case AppRoute.reminders:
            return RemindersScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
              onSwitchTab: _switchTab,
            );
          case AppRoute.keepForLater:
            return KeepForLaterScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
            );
          case AppRoute.goals:
            return GoalsScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
              onSwitchTab: _switchTab,
            );
          case AppRoute.affirmations:
            return AffirmationsScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
            );
          case AppRoute.settings:
            return SettingsPrivacyScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
              onSwitchTab: _switchTab,
              onLogOut: () async {
                await widget.appState.logOut();
                _tabIndex = 0;
                _go(AppRoute.welcome);
              },
            );
          case AppRoute.budgeting:
            return BudgetingScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
              onSwitchTab: _switchTab,
            );
          case AppRoute.productivity:
            return ProductivityScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
              onSwitchTab: _switchTab,
            );
          case AppRoute.emailReports:
            return EmailReportsScreen(
              appState: widget.appState,
              onBack: () => _go(AppRoute.mainTabs),
            );
          case AppRoute.mainTabs:
            return _buildTab(_tabIndex);
        }
  }

  Widget _buildAuthScreen({
    required bool signInMode,
    required String initialName,
    required String initialEmail,
    required VoidCallback onBack,
  }) {
    return CreateAccountScreen(
      initialName: initialName,
      initialEmail: initialEmail,
      initialSignInMode: signInMode,
      onBack: onBack,
      onCreate: (name, email, password) async {
        final err = await widget.appState.updateOnboardingAccount(
          fullName: name,
          email: email,
          password: password,
        );
        if (err == null) {
          _go(AppRoute.setGoals);
        }
        return err;
      },
      onSignIn: (email, password) async {
        final err = await widget.appState.signInExisting(
          email: email,
          password: password,
        );
        if (err == null) {
          _switchTab(0);
        }
        return err;
      },
      onForgotPassword: (email) => widget.appState.requestPasswordReset(email),
      onResetPassword: (email, code, newPassword) async {
        final err = await widget.appState.resetPasswordWithCode(
          email: email,
          code: code,
          newPassword: newPassword,
        );
        if (err == null) {
          _switchTab(0);
        }
        return err;
      },
      onGoogleSignIn: () => widget.appState.startGoogleOAuth(),
    );
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 1:
        return TasksScreen(
          appState: widget.appState,
          onSwitchTab: _switchTab,
        );
      case 2:
        return AiChatScreen(
          appState: widget.appState,
          onBack: () => _switchTab(0),
          onSwitchTab: _switchTab,
          onOpenVoice: () => _go(AppRoute.voiceRecording),
          onOpenBrainDump: () => _go(AppRoute.brainDumpReview),
        );
      case 3:
        return ShoppingScreen(
          appState: widget.appState,
          onSwitchTab: _switchTab,
          onOpenVoice: () => _go(AppRoute.voiceRecording),
        );
      case 4:
        return MemoryScreen(
          appState: widget.appState,
          onSwitchTab: _switchTab,
        );
      case 0:
      default:
        return HomeTodayScreen(
          appState: widget.appState,
          onSwitchTab: _switchTab,
          onOpenVoice: () => _go(AppRoute.voiceRecording),
          onOpenReminders: () => _go(AppRoute.reminders),
          onOpenGoals: () => _go(AppRoute.goals),
          onOpenKeepForLater: () => _go(AppRoute.keepForLater),
          onOpenAffirmations: () => _go(AppRoute.affirmations),
          onOpenSettings: () => _go(AppRoute.settings),
          onOpenBrainDump: () => _go(AppRoute.brainDumpReview),
          onOpenBudgeting: () => _go(AppRoute.budgeting),
          onOpenProductivity: () => _go(AppRoute.productivity),
          onOpenEmailReports: () => _go(AppRoute.emailReports),
        );
    }
  }
}
