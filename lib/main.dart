// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/services/storage_service.dart';

// ── AUTH ──────────────────────────────────────────────
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/profil_screen.dart';

// ── HOME & NAVIGATION ─────────────────────────────────
import 'features/home/screens/home_screen.dart';
import 'features/navigation/main_navigation.dart';

// ── OFFRES ────────────────────────────────────────────
import 'features/offres/screens/offres_screen.dart';
import 'features/offres/screens/offres_saved_screen.dart';

// ── CANDIDATURES ──────────────────────────────────────
import 'features/candidatures/screens/candidatures_screen.dart';
import 'features/candidatures/screens/application_hub_screen.dart';

// ── NOUVEAUX ÉCRANS (Quick Actions) ───────────────────
import 'features/entretiens/screens/entretiens_screen.dart';
import 'features/notifications/screens/notifications_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const GoPostuleApp());
}

class GoPostuleApp extends StatelessWidget {
  const GoPostuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoPostule',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',

      // ✅ ROUTES STATIQUES (sans arguments)
      routes: {
        // ── AUTH ──────────────────────────────────────
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profil': (context) => const ProfilScreen(),

        // ── NAVIGATION PRINCIPALE ─────────────────────
        '/home': (context) => const MainNavigation(),

        // ── OFFRES ────────────────────────────────────
        '/offres': (context) => const OffresScreen(),
        '/offres/saved': (context) => const OffresSavedScreen(),

        // ── CANDIDATURES ──────────────────────────────
        '/candidatures': (context) => const CandidaturesScreen(),

        // ── QUICK ACTIONS ─────────────────────────────
        '/entretiens': (context) => const EntretiensScreen(),
        '/notifications': (context) => const NotificationsScreen(),
      },

      // ✅ ROUTES DYNAMIQUES (avec arguments)
      onGenerateRoute: (settings) {
        switch (settings.name) {
        // Hub de candidature avec ID
          case '/application-hub':
            final candidatureId = settings.arguments as String? ?? '';
            return MaterialPageRoute(
              builder: (_) => ApplicationHubScreen(
                candidatureId: candidatureId,
              ),
            );

        // Route par défaut
          default:
            return null; // Laisse onUnknownRoute gérer
        }
      },

      // ✅ GESTION DES ROUTES INCONNUES (CORRIGÉ)
      onUnknownRoute: (settings) {
        debugPrint('❌ Route inconnue: ${settings.name}');
        return MaterialPageRoute(
          builder: (context) => Scaffold(  // ← context maintenant disponible ici
            appBar: AppBar(
              title: const Text('Page non trouvée'),
              backgroundColor: AppTheme.theme.primaryColor,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Page "${settings.name}" introuvable',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // ✅ Utilise le context du builder
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Text('Retour à l\'accueil'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}