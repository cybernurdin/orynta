import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/localization/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'data/services/app_repository.dart';
import 'data/services/local_auth_service.dart';
import 'features/auth/login_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/shell/app_shell.dart';

class OryntaApp extends StatelessWidget {
  const OryntaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()..load()),
        ChangeNotifierProvider(create: (_) => ThemeModeProvider()..load()),
        ChangeNotifierProvider(create: (_) => AppRepository()..load()),
      ],
      child: Consumer2<LocaleProvider, ThemeModeProvider>(
        builder: (context, locale, themeMode, _) {
          return MaterialApp(
            title: 'Orynta',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode.mode,
            locale: locale.locale,
            supportedLocales: const [Locale('en'), Locale('fr')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const _StartupGate(),
          );
        },
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  const _StartupGate();

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

enum _StartupDestination { onboarding, login, home }

class _StartupGateState extends State<_StartupGate> {
  _StartupDestination? _destination;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool(onboardingDoneKey) ?? false;
    if (!onboardingDone) {
      if (mounted) setState(() => _destination = _StartupDestination.onboarding);
      return;
    }
    final session = await LocalAuthService().currentSession();
    if (mounted) {
      setState(() => _destination = session == null ? _StartupDestination.login : _StartupDestination.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_destination) {
      null => const Scaffold(body: Center(child: CircularProgressIndicator())),
      _StartupDestination.onboarding => const OnboardingScreen(),
      _StartupDestination.login => const LoginScreen(),
      _StartupDestination.home => const AppShell(),
    };
  }
}
