// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // ── Couleurs principales ──────────────────────────────────
  static const Color primary = Color(0xFF0D1B3E);      // Bleu foncé navbar/header
  static const Color accent = Color(0xFFF5C518);       // Jaune/Or boutons, badges
  static const Color secondary = Color(0xFF1E3A8A);    // Bleu moyen accents

  // ── Backgrounds ───────────────────────────────────────────
  static const Color background = Color(0xFFFFFFFF);   // Blanc fond général
  static const Color surface = Color(0xFFF5F5F5);      // Gris clair cards

  // ── Textes ────────────────────────────────────────────────
  static const Color textDark = Color(0xFF0D1B3E);     // Texte principal
  static const Color textGrey = Color(0xFF757575);     // Texte secondaire
  static const Color textLight = Color(0xFFFFFFFF);    // Texte sur fond sombre

  // ── Statuts (badges candidatures) ─────────────────────────
  static const Color statusReview = Color(0xFF1565C0);     // Bleu — In Review
  static const Color statusRejected = Color(0xFFE53935);   // Rouge — Rejected
  static const Color statusOffer = Color(0xFF43A047);      // Vert — Offer Received
  static const Color statusPending = Color(0xFF9E9E9E);    // Gris — Applied

  // ── Autres utilitaires ────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ── Gradients utiles ──────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFF5D08A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}