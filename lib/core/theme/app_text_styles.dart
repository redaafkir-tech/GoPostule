import 'package:flutter/material.dart';
import 'app_theme.dart';

// Tous les styles de texte réutilisables de l'app
// Tu appelles AppTextStyles.title au lieu de réécrire TextStyle partout
class AppTextStyles {
  // Titre de page — "Mes candidatures"
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textLight,
  );

  // Titre d'une card — "Product Designer"
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  // Sous-titre — "Innovate Solutions"
  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 13,
    color: AppColors.textGrey,
  );

  // Label petit — "Location: Paris"
  static const TextStyle label = TextStyle(
    fontSize: 12,
    color: AppColors.textGrey,
  );

  // Texte bouton
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );
}