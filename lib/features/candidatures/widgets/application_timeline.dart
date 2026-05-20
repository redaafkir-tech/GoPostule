// lib/features/candidatures/widgets/application_timeline.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/candidature_enhanced.dart';

class ApplicationTimeline extends StatelessWidget {
  final CandidatureEnhanced candidature;

  const ApplicationTimeline({super.key, required this.candidature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.timeline_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Progression du recrutement',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...List.generate(
            candidature.timeline.length,
                (index) => _buildTimelineItem(
              event: candidature.timeline[index],
              isLast: index == candidature.timeline.length - 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({required TimelineEvent event, required bool isLast}) {
    final isCompleted = event.isCompleted;
    final isCurrent = event.isCurrent;

    // ✅ Accepte snake_case ET camelCase pour plus de flexibilité
    final phase = event.phase.toLowerCase().replaceAll('_', '');
    final isConcours = phase == 'concoursecrit' || phase == 'concoursoral';

    Color stepColor;
    if (isCompleted) {
      if (isConcours) {
        final isEcrit = phase == 'concoursecrit';
        final result = isEcrit
            ? candidature.resultatConcoursEcrit
            : candidature.resultatConcoursOral;

        if (result == ConcoursResult.admis) {
          stepColor = Colors.green;
        } else if (result == ConcoursResult.rejete) {
          stepColor = Colors.red;
        } else {
          stepColor = AppColors.primary;
        }
      } else {
        stepColor = Colors.green;
      }
    } else if (isCurrent) {
      stepColor = AppColors.accent;
    } else {
      stepColor = Colors.grey.shade400;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: isCurrent ? 20 : 16,
              height: isCurrent ? 20 : 16,
              decoration: BoxDecoration(
                color: stepColor,
                shape: BoxShape.circle,
                boxShadow: isCurrent
                    ? [BoxShadow(color: stepColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 2)]
                    : null,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 60,
                color: isCompleted
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isCurrent ? Border.all(color: AppColors.primary.withOpacity(0.2), width: 1.5) : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isCompleted
                            ? Colors.green.shade800
                            : isCurrent
                            ? AppColors.primary
                            : Colors.grey.shade600,
                      ),
                    ),
                    if (isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8)
                        ),
                        child: const Text(
                          'En cours',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                    DateFormat('dd MMM yyyy - HH:mm').format(event.date),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)
                ),

                // ✅ Détails Date + Lieu pour les Concours
                if (isConcours && !isCompleted) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 📅 Date
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Prévu le ${DateFormat('dd MMM yyyy \'à\' HH:mm').format(event.date)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // 📍 Lieu
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.blue.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Siège ONEE, Rabat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // 📧 Message Email Professionnel
                        const SizedBox(height: 12),
                        _buildEmailNotification(phase),
                      ],
                    ),
                  ),
                ],

                // Résultat du concours
                if (isConcours) _buildConcoursResult(event, phase, stepColor),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ Widget notification email professionnel
  Widget _buildEmailNotification(String phase) {
    final isOral = phase == 'concoursoral';
    final emailRecu = isOral
        ? candidature.emailConcoursOralRecu
        : candidature.emailConcoursEcritRecu;

    if (emailRecu) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, size: 18, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email de convocation reçu',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vérifiez votre boîte mail et vos spams',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.green.shade600),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade300, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.schedule, size: 18, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email de convocation en cours d\'envoi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vous le recevrez sous 48 heures',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 12, color: Colors.orange.shade600),
          ],
        ),
      );
    }
  }


  Widget _buildConcoursResult(TimelineEvent event, String phase, Color stepColor) {
    final isEcrit = phase == 'concoursecrit';
    final result = isEcrit
        ? candidature.resultatConcoursEcrit
        : candidature.resultatConcoursOral;
    final emailRecu = isEcrit
        ? candidature.emailConcoursEcritRecu
        : candidature.emailConcoursOralRecu;

    if (result == null) {
      if (!event.isCompleted) {
        return Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_empty, size: 18, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'En attente de résultat...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    final isAdmis = result == ConcoursResult.admis;
    final bgColor = isAdmis ? Colors.green.shade50 : Colors.red.shade50;
    final borderColor = isAdmis ? Colors.green.shade300 : Colors.red.shade300;
    final textColor = isAdmis ? Colors.green.shade800 : Colors.red.shade800;
    final icon = isAdmis ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: isAdmis ? Colors.green : Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isAdmis ? '✅ ADMIS(E)' : '❌ NON ADMIS(E)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 14,
                  ),
                ),
              ),
              if (emailRecu)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.email, size: 12, color: Colors.blue.shade800),
                      const SizedBox(width: 4),
                      Text(
                        'Email reçu',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade800,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isAdmis) ...[
            Text(
              isEcrit
                  ? '🎉 Félicitations ! Vous êtes convoqué(e) au concours oral.'
                  : '🎉 Félicitations ! Votre candidature est acceptée.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Text(
              'Nous sommes désolés, votre candidature n\'a pas été retenue.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isEcrit)
              Text(
                '⛔ Vous ne passez pas à l\'étape suivante.',
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic
                ),
              ),
          ],
        ],
      ),
    );
  }
}