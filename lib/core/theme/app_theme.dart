import 'package:flutter/material.dart';

class AppColors {
  // Couleurs principales
  static const Color primary     = Color(0xFF0D1B3E); // Bleu foncé — navbar, header
  static const Color accent      = Color(0xFFF5C518); // Jaune/Or — boutons, badges actifs
  static const Color background  = Color(0xFFFFFFFF); // Blanc — fond général
  static const Color surface     = Color(0xFFF5F5F5); // Gris clair — fond des cards

  // Couleurs des statuts (badges candidatures)
  static const Color statusReview   = Color(0xFF1565C0); // Bleu — In Review
  static const Color statusRejected = Color(0xFFE53935); // Rouge — Rejected
  static const Color statusOffer    = Color(0xFF43A047); // Vert — Offer Received
  static const Color statusPending  = Color(0xFF9E9E9E); // Gris — Applied

  // Textes
  static const Color textDark  = Color(0xFF0D1B3E); // Texte principal
  static const Color textGrey  = Color(0xFF757575); // Texte secondaire (Location, Date)
  static const Color textLight = Color(0xFFFFFFFF); // Texte sur fond sombre
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,

    colorScheme: const ColorScheme.light(
      primary:   AppColors.primary,
      secondary: AppColors.accent,
      surface:   AppColors.surface,
      error:     AppColors.statusRejected,
    ),

    // AppBar — bleu foncé comme dans le design
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textLight,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: AppColors.textLight,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),

    // Bottom Navigation Bar — bleu foncé avec icônes blancs/jaune
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.primary,
      selectedItemColor: AppColors.accent,    // Jaune quand sélectionné
      unselectedItemColor: AppColors.textLight, // Blanc quand non sélectionné
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Boutons principaux — jaune avec texte bleu foncé (comme "Upload New")
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primary,   // Texte bleu foncé sur fond jaune
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    ),

    // Champs de texte
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Nouvelle version — correct
    cardTheme: CardThemeData(
      color: AppColors.background,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
  );
}