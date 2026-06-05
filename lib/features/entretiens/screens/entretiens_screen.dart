// lib/features/entretiens/screens/entretiens_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EntretiensScreen extends StatefulWidget {
  const EntretiensScreen({super.key});

  @override
  State<EntretiensScreen> createState() => _EntretiensScreenState();
}

class _EntretiensScreenState extends State<EntretiensScreen> {
  // 🎯 DONNÉES DE TEST (À remplacer par l'API)
  final List<Map<String, dynamic>> _interviews = [
    {
      'id': 1,
      'titre': 'Entretien Technique',
      'entreprise': 'ONEE',
      'poste': 'Ingénieur Génie Logiciel',
      'date': '28 Mai 2026',
      'heure': '10:00',
      'lieu': 'Siège ONEE, Rabat',
      'statut': 'upcoming', // upcoming, completed, cancelled
    },
    {
      'id': 2,
      'titre': 'Entretien RH',
      'entreprise': 'Maroc Telecom',
      'poste': 'Développeur Full Stack',
      'date': '15 Mai 2026',
      'heure': '14:30',
      'lieu': 'En ligne (Teams)',
      'statut': 'completed',
    },
    {
      'id': 3,
      'titre': 'Entretien Final',
      'entreprise': 'OCP Group',
      'poste': 'Data Analyst',
      'date': '05 Mai 2026',
      'heure': '09:00',
      'lieu': 'Casablanca',
      'statut': 'cancelled',
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'upcoming':
        return AppColors.accent;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.danger;
      default:
        return AppColors.textGrey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'upcoming':
        return 'À venir';
      case 'completed':
        return 'Terminé';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'upcoming':
        return Icons.event_available_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Mes Entretiens'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _interviews.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _interviews.length,
        itemBuilder: (context, index) {
          final interview = _interviews[index];
          return _buildInterviewCard(interview);
        },
      ),
    );
  }

  Widget _buildInterviewCard(Map<String, dynamic> interview) {
    final statusColor = _getStatusColor(interview['statut']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bloc Date/Heure
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  _getStatusIcon(interview['statut']),
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(height: 6),
                Text(
                  interview['heure'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                Text(
                  interview['date'].split(' ')[0],
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Détails
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusLabel(interview['statut']),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  interview['titre'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${interview['poste']} • ${interview['entreprise']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        interview['lieu'],
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 80,
            color: AppColors.textGrey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun entretien programmé',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les invitations aux entretiens apparaîtront ici',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}