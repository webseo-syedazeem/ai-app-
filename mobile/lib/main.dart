import 'package:flutter/material.dart';
import 'app/app_shell.dart';
import 'app/app_state.dart';
import 'app/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.init();
  runApp(AiDailyHelperApp(appState: appState));
}

class AiDailyHelperApp extends StatelessWidget {
  final AppState appState;
  final AppRoute initialRoute;

  const AiDailyHelperApp({
    super.key,
    required this.appState,
    this.initialRoute = AppRoute.splash,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Daily Helper',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      home: AppShell(appState: appState, initialRoute: initialRoute),
    );
  }
}
