// lib/features/offres/widgets/offre_card.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/offre.dart';  // ← Modèle typed

class OffreCard extends StatelessWidget {
  final Offre offre;
  final VoidCallback onTap;

  const OffreCard({
    super.key,
    required this.offre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── LIGNE 1 : Titre + Badge Secteur ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      offre.titre,  // ✅ Champ correct
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      offre.secteur,  // ✅ Champ correct
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // ── LIGNE 2 : Entreprise ──
              Text(
                offre.entreprise,  // ✅ Champ correct
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 8),

              // ── LIGNE 3 : Localisation + TypeContrat (au lieu de Ville+Niveau) ──
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offre.localisation,  // ✅ Champ correct (au lieu de ville)
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.work_outline,  // ✅ Icône plus adaptée
                    size: 14,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offre.typeContrat,  // ✅ Champ correct (au lieu de niveau)
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ── LIGNE 4 : Date de publication (avec null safety) ──
              if (offre.createdAt != null)  // ✅ Vérification null
                Text(
                  'Publié le ${_formatDate(offre.createdAt!)}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Helper pour formater la date proprement
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}