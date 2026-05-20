// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/offres/screens/home_screen.dart';
import 'features/offres/screens/offres_screen.dart';
import 'features/candidatures/screens/candidatures_screen.dart';
import 'features/candidatures/screens/application_hub_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();

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

      // Routes nommées pour navigation simple
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/offres': (context) => const OffresScreen(),
        '/candidatures': (context) => const CandidaturesScreen(),
      },

      // ✅ CORRECT : Routes avec paramètres
      onGenerateRoute: (settings) {
        switch (settings.name) {
        // Route pour ApplicationHubScreen avec ID de candidature
          case '/application-hub':
            final candidatureId = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => ApplicationHubScreen(
                candidatureId: candidatureId,  // ← String, PAS dynamic
              ),
            );

          default:
            return null; // Utilise les routes nommées ci-dessus
        }
      },
    );
  }
}