import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/offres/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DioClient.init();
  runApp(const GoPostulApp());
}

class GoPostulApp extends StatelessWidget {
  const GoPostulApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoPostul',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}