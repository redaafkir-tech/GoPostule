// lib/features/candidatures/widgets/application_status_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/candidature_enhanced.dart';

class ApplicationStatusCard extends StatelessWidget {
  final CandidatureEnhanced candidature;

  const ApplicationStatusCard({super.key, required this.candidature});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.work_outline_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidature.offre.titre,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        candidature.offre.entreprise,
                        style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.85)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildStatusBadge(),
            const SizedBox(height: 20),
            _buildProgressBar(),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'Soumis le',
                  value: DateFormat('dd MMM yyyy').format(candidature.dateSoumission),
                ),
                if (candidature.derniereMiseAJour != null)
                  _buildInfoItem(
                    icon: Icons.update_rounded,
                    label: 'Mis à jour',
                    value: DateFormat('dd MMM').format(candidature.derniereMiseAJour!),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final statusColor = _getStatusColor();
    final statusIcon = _getStatusIcon();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 8),
          Text(
            candidature.getStatusLabel(),
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: statusColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progression', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
            Text('${candidature.progressPercent}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: candidature.progressPercent / 100,
            backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem({required IconData icon, required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.white.withOpacity(0.7)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7))),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Color _getStatusColor() {
    switch (candidature.status) {
      case CandidatureStatus.admise:
        return Colors.green.shade300;
      case CandidatureStatus.rejetee:
        return Colors.red.shade300;
      case CandidatureStatus.concoursOral:
        return Colors.orange.shade300;
      case CandidatureStatus.examenRh:
        return Colors.blue.shade300;
      case CandidatureStatus.concoursEcrit:
        return Colors.teal.shade300;
      default:
        return Colors.white;
    }
  }

  IconData _getStatusIcon() {
    switch (candidature.status) {
      case CandidatureStatus.admise:
        return Icons.check_circle_outline;
      case CandidatureStatus.rejetee:
        return Icons.cancel_outlined;
      case CandidatureStatus.concoursOral:
        return Icons.event_available_outlined;
      case CandidatureStatus.examenRh:
        return Icons.people_outline;
      case CandidatureStatus.concoursEcrit:
        return Icons.assignment_outlined;
      default:
        return Icons.send_outlined;
    }
  }
}