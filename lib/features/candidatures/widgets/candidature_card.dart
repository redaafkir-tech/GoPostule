import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/candidature.dart';

class CandidatureCard extends StatelessWidget {
  final Candidature candidature;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const CandidatureCard({
    super.key,
    required this.candidature,
    required this.onTap,
    this.onDelete,
  });

  static const List<String> _etapes = [
    'Envoyée',
    'En révision',
    'Convoqué',
    'Résultat',
  ];

  // Index actif selon la phase
  int get _etapeActive {
    switch (candidature.phase) {
      case PhaseCandidature.envoyee:    return 0;
      case PhaseCandidature.enRevision: return 1;
      case PhaseCandidature.convoque:   return 2;
      case PhaseCandidature.resultat:   return 3;
    }
  }

  // Couleur principale selon la phase/résultat
  Color get _couleurPrincipale {
    if (candidature.phase == PhaseCandidature.resultat) {
      if (candidature.resultat == ResultatCandidature.admis) {
        return AppColors.statusOffer;   // Vert
      }
      return AppColors.statusRejected; // Rouge
    }
    return AppColors.primary; // Bleu foncé
  }

  // Label + couleur du badge
  String get _badgeLabel {
    if (candidature.phase == PhaseCandidature.resultat) {
      return candidature.resultat == ResultatCandidature.admis
          ? 'Admis'
          : 'Refusé';
    }
    return _etapes[_etapeActive];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            // Bordure colorée si résultat final
            color: candidature.phase == PhaseCandidature.resultat
                ? _couleurPrincipale.withOpacity(0.3)
                : const Color(0xFFF0F0F0),
            width: candidature.phase == PhaseCandidature.resultat ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo entreprise
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _couleurPrincipale.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        candidature.entreprise.substring(0, 2).toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _couleurPrincipale,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          candidature.titreOffre,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          candidature.entreprise,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge statut
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _couleurPrincipale.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _badgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _couleurPrincipale,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Ville + date
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 12, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(candidature.ville,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textGrey)),
                  const SizedBox(width: 12),
                  const Icon(Icons.calendar_today_outlined,
                      size: 12, color: AppColors.textGrey),
                  const SizedBox(width: 4),
                  Text(
                    '${candidature.datePostulation.day}/${candidature.datePostulation.month}/${candidature.datePostulation.year}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textGrey),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Stepper horizontal
              _buildStepper(),

              // Bouton supprimer — visible seulement si résultat final
              if (candidature.peutSupprimer && onDelete != null) ...[
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.delete_outline,
                          size: 14,
                          color: AppColors.statusRejected.withOpacity(0.7)),
                      const SizedBox(width: 4),
                      Text(
                        'Supprimer la candidature',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.statusRejected.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Row(
      children: List.generate(_etapes.length, (index) {
        final isCompleted = index < _etapeActive;
        final isActive    = index == _etapeActive;

        Color circleColor;
        if (isActive || isCompleted) {
          circleColor = _couleurPrincipale;
        } else {
          circleColor = const Color(0xFFE0E0E0);
        }

        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: (isCompleted || isActive)
                          ? circleColor
                          : Colors.white,
                      border: Border.all(color: circleColor, width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? const Icon(Icons.check,
                        size: 12, color: Colors.white)
                        : isActive &&
                        candidature.phase ==
                            PhaseCandidature.resultat
                        ? Icon(
                      candidature.resultat ==
                          ResultatCandidature.admis
                          ? Icons.check
                          : Icons.close,
                      size: 12,
                      color: Colors.white,
                    )
                        : isActive
                        ? Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: circleColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _etapes[index],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isActive || isCompleted
                          ? AppColors.textDark
                          : AppColors.textGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (index < _etapes.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isCompleted
                        ? circleColor
                        : const Color(0xFFE0E0E0),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}