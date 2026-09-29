import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';
import 'presentation/screens/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FintraApp());
}

class FintraApp extends StatelessWidget {
  const FintraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Fintra',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}