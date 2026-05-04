import 'package:flutter/material.dart';
import 'app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String status; // "in_review", "rejected", "offer", "applied"

  const StatusBadge({super.key, required this.status});

  // Retourne la couleur selon le statut
  Color get _color {
    switch (status.toLowerCase()) {
      case 'in_review':   return AppColors.statusReview;
      case 'rejected':    return AppColors.statusRejected;
      case 'offer':       return AppColors.statusOffer;
      default:            return AppColors.statusPending;
    }
  }

  // Retourne le texte affiché dans le badge
  String get _label {
    switch (status.toLowerCase()) {
      case 'in_review':   return 'In Review';
      case 'rejected':    return 'Rejected';
      case 'offer':       return 'Offer Received';
      default:            return 'Applied';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(20), // Pill shape comme dans le design
      ),
      child: Text(
        _label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}