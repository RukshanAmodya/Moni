import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/finance_provider.dart';
import 'theme/moni_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/navigation_holder.dart';
import 'screens/pin_lock_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final financeProvider = FinanceProvider();
  await financeProvider.init();

  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('moni_onboarding_seen') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => financeProvider,
      child: MyApp(hasSeenOnboarding: hasSeenOnboarding),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;

  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    final finance = Provider.of<FinanceProvider>(context);

    Widget homeWidget;
    if (finance.pinEnabled) {
      homeWidget = PinLockScreen(
        isSettingPin: false,
        onSuccess: () {
          // Once authenticated, go to appropriate screen
          if (hasSeenOnboarding) {
            _goToNavigation(context);
          } else {
            _goToOnboarding(context);
          }
        },
      );
    } else {
      homeWidget = hasSeenOnboarding 
          ? const NavigationHolder() 
          : const OnboardingScreen();
    }

    return MaterialApp(
      title: 'Moni',
      debugShowCheckedModeBanner: false,
      theme: MoniTheme.lightTheme,
      home: homeWidget,
    );
  }

  void _goToNavigation(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const NavigationHolder()),
    );
  }

  void _goToOnboarding(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
    );
  }
}
