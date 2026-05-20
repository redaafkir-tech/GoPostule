// lib/features/auth/screens/register_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers pour chaque champ
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // ✅ NOUVEAU: Variable pour stocker le numéro complet
  String _fullPhoneNumber = '';

  // États UI
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // 📝 VALIDATION DU FORMULAIRE
  // ─────────────────────────────────────────────────────────────
  String? _validateNom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nom obligatoire';
    if (value.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? _validatePrenom(String? value) {
    if (value == null || value.trim().isEmpty) return 'Prénom obligatoire';
    if (value.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email obligatoire';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value.trim())) {
      return 'Email invalide (ex: user@email.com)';
    }
    return null;
  }

  // ✅ PLUS BESOIN de _validateTelephone - géré par IntlPhoneField

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Mot de passe obligatoire';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value == null || value.isEmpty) return 'Confirmation obligatoire';
    if (value != _passwordController.text) return 'Les mots de passe ne correspondent pas';
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // 🚀 INSCRIPTION (API CALL)
  // ─────────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Validation du téléphone
    if (_fullPhoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Téléphone obligatoire'),
          backgroundColor: AppColors.statusRejected,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.register(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        telephone: _fullPhoneNumber, // ✅ Numéro complet avec indicatif
      );

      if (mounted) {
        // ✅ Succès : Message + Navigation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Compte créé avec succès ! 🎉'),
              ],
            ),
            backgroundColor: AppColors.statusOffer,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
        // Redirection vers login après 1.5s
        await Future.delayed(const Duration(milliseconds: 1500));
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        // ❌ Erreur : Message détaillé
        final message = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(message)),
              ],
            ),
            backgroundColor: AppColors.statusRejected,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🎨 BUILD PRINCIPAL
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Retour',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // 📌 Titre
                const Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez GoPostule dès maintenant',
                  style: TextStyle(fontSize: 14, color: AppColors.textGrey),
                ),
                const SizedBox(height: 32),

                // 👤 Nom + Prénom (côte à côte)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        textCapitalization: TextCapitalization.words,
                        validator: _validateNom,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        textCapitalization: TextCapitalization.words,
                        validator: _validatePrenom,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 📧 Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // 📱 Téléphone avec IntlPhoneField (PACKAGE)
                IntlPhoneField(
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(),
                    ),
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  initialCountryCode: 'MA', // Maroc par défaut
                  dropdownIcon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  dropdownDecoration: const BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  onChanged: (phone) {
                    // ✅ Stocke le numéro complet (+212612345678)
                    setState(() {
                      _fullPhoneNumber = phone.completeNumber;
                    });
                  },
                  validator: (phone) {
                    if (phone == null || phone.number.isEmpty) {
                      return 'Téléphone obligatoire';
                    }
                    if (phone.number.length < 8) {
                      return 'Numéro trop court';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 🔐 Mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      tooltip: _obscurePassword ? 'Afficher' : 'Masquer',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 🔐 Confirmer mot de passe
                TextFormField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleRegister(),
                  validator: _validateConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirmer le mot de passe',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      ),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      tooltip: _obscureConfirm ? 'Afficher' : 'Masquer',
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 🎯 Bouton S'inscrire
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : const Text(
                      "S'inscrire",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 🔗 Lien vers Login
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: RichText(
                      text: const TextSpan(
                        text: "Déjà un compte ? ",
                        style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                        children: [
                          TextSpan(
                            text: 'Se connecter',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
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