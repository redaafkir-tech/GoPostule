import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/offre.dart';

// Widget réutilisable — affiche une offre sous forme de card
class OffreCard extends StatelessWidget {
  final Offre offre;
  final VoidCallback onTap; // Action quand on clique sur la card

  const OffreCard({
    super.key,
    required this.offre,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        // InkWell ajoute l'effet ripple au clic
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Titre de l'offre
                  Expanded(
                    child: Text(
                      offre.titre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Badge secteur — jaune
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
                      offre.secteur,
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

              // Entreprise
              Text(
                offre.entreprise,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGrey,
                ),
              ),

              const SizedBox(height: 8),

              // Ville + Niveau
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offre.ville,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.school_outlined,
                    size: 14,
                    color: AppColors.textGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    offre.niveau,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Date publication
              Text(
                'Publié le ${offre.datePublication.day}/${offre.datePublication.month}/${offre.datePublication.year}',
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
}