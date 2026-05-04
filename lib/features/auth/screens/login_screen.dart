import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // _formKey permet de valider tous les champs du formulaire d'un coup
  final _formKey = GlobalKey<FormState>();

  // Controllers — récupèrent ce que l'utilisateur tape dans chaque champ
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();

  // Contrôle si le mot de passe est visible ou caché
  bool _obscurePassword = true;

  // Contrôle l'affichage du loading pendant l'appel API
  bool _isLoading = false;

  @override
  void dispose() {
    // Libérer la mémoire des controllers quand l'écran se ferme
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fonction appelée quand l'utilisateur appuie sur "Se connecter"
  Future<void> _handleLogin() async {
    // Vérifie que tous les champs sont valides avant d'envoyer
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true); // Affiche le loading

    // TODO Phase 2 : appel API auth_service.dart
    await Future.delayed(const Duration(seconds: 2)); // Simulation

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        // SafeArea évite que le contenu se cache derrière la barre de statut
        child: SingleChildScrollView(
          // SingleChildScrollView permet de scroller si le clavier s'ouvre
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),

                // Logo en haut
                Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 160,
                  ),
                ),

                const SizedBox(height: 48),

                // Titre
                const Text(
                  'Connexion',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textGrey,
                  ),
                ),

                const SizedBox(height: 32),

                // Champ Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  // validator = fonction appelée lors de la validation du form
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email obligatoire';
                    }
                    if (!value.contains('@')) {
                      return 'Email invalide';
                    }
                    return null; // null = pas d'erreur
                  },
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                // Champ Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword, // Cache ou affiche le texte
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Mot de passe obligatoire';
                    }
                    if (value.length < 6) {
                      return 'Minimum 6 caractères';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    // Bouton œil pour afficher/cacher le mot de passe
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Bouton Se connecter
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  // null désactive le bouton pendant le chargement
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Se connecter'),
                ),

                const SizedBox(height: 16),

                // Lien vers Register
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      // RichText permet d'avoir deux styles dans une même ligne
                      text: const TextSpan(
                        text: "Pas encore de compte ? ",
                        style: TextStyle(color: AppColors.textGrey),
                        children: [
                          TextSpan(
                            text: 'Inscription',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}