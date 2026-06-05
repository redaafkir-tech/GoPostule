// lib/features/home/widgets/quick_stats.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuickStats extends StatelessWidget {
  const QuickStats({super.key});

  // Couleurs directes
  static const Color _primary = Color(0xFF0D1B3E);
  static const Color _accent = Color(0xFFF5C518);
  static const Color _textGrey = Color(0xFF757575);
  static const Color _textDark = Color(0xFF0D1B3E);
  static const Color _statusReview = Color(0xFF1565C0);
  static const Color _statusOffer = Color(0xFF43A047);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: _accent,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vue d\'ensemble',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.send_outlined,
                value: '12',
                label: 'Candidatures',
                color: _primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.visibility_outlined,
                value: '48',
                label: 'Vues',
                color: _statusReview,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _StatCard(
                icon: Icons.check_circle_outline,
                value: '5',
                label: 'Entretiens',
                color: _statusOffer,
              )),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(
                icon: Icons.star_outline,
                value: '3',
                label: 'Sauvegardées',
                color: _accent,
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: QuickStats._textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}