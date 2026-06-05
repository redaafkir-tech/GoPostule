// lib/features/home/widgets/home_search_bar.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  // Couleurs directes
  static const Color _primary = Color(0xFF0D1B3E);
  static const Color _textGrey = Color(0xFF757575);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Rechercher un poste...',
          hintStyle: const TextStyle(color: _textGrey),
          prefixIcon: Icon(Icons.search, color: _primary),
        ),
      ),
    );
  }
}