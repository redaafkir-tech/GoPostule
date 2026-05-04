import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// StatefulWidget car on a besoin d'animations qui changent dans le temps
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // AnimationController = le "chef d'orchestre" de toutes les animations
  // Il contrôle la durée et le timing
  late AnimationController _controller;

  // Animation du logo qui apparaît progressivement (0.0 = invisible → 1.0 = visible)
  late Animation<double> _fadeAnimation;

  // Animation du logo qui monte légèrement du bas vers sa position finale
  late Animation<double> _slideAnimation;

  // Animation du logo qui grossit légèrement au démarrage
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Le controller dure 1.5 secondes au total
    _controller = AnimationController(
      vsync: this, // vsync optimise les performances d'animation
      duration: const Duration(milliseconds: 1500),
    );

    // Fade : de transparent à opaque, pendant les 60% premiers du temps
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
        // Interval(0.0, 0.6) = joue entre 0% et 60% de la durée totale
      ),
    );

    // Slide : monte de 30px vers 0px (position normale)
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Scale : grossit de 0.8 à 1.0 (taille normale)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    // Lance l'animation dès que l'écran s'ouvre
    _controller.forward();

    // Après 3 secondes → naviguer vers Login
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // mounted vérifie que le widget existe encore avant de naviguer
        Navigator.pushReplacementNamed(context, '/login');
        // pushReplacement = remplace le splash, l'utilisateur ne peut pas revenir en arrière
      }
    });
  }

  @override
  void dispose() {
    // IMPORTANT : toujours libérer le controller sinon fuite mémoire
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fond bleu foncé
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          // AnimatedBuilder se reconstruit à chaque frame d'animation
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value, // Applique le fade
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value), // Applique le slide
                child: Transform.scale(
                  scale: _scaleAnimation.value, // Applique le scale
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo blanc — ColorFiltered rend l'image blanche sur fond bleu
              Image.asset(
                'assets/images/logo.png',
                width: 200,
              ),

              const SizedBox(height: 40),

              // Indicateur de chargement jaune en bas
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  color: AppColors.primary, // Jaune
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}