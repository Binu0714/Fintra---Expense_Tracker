import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FintraApp());
}

class FintraApp extends StatelessWidget {
  const FintraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintra',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}