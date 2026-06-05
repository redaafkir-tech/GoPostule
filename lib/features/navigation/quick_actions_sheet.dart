// lib/features/navigation/quick_actions_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../candidatures/widgets/submit_reclamation_dialog.dart';

class QuickActionsSheet extends StatelessWidget {
  const QuickActionsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55, // ✅ 55% au lieu de 75%
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header (réduit)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.info],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actions rapides',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        'Que souhaitez-vous faire ?',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ✅ Grid scrollable
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.90,
                      children: [
                        _ActionCard(
                          icon: Icons.search_rounded,
                          label: 'Rechercher',
                          subtitle: 'Une offre',
                          gradient: const [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          onTap: () => _navigateToSearch(context),
                        ),
                        _ActionCard(
                          icon: Icons.upload_file_rounded,
                          label: 'Déposer CV',
                          subtitle: 'Mettre à jour',
                          gradient: const [Color(0xFF10B981), Color(0xFF34D399)],
                          onTap: () => _navigateToUploadCV(context),
                        ),
                        _ActionCard(
                          icon: Icons.star_rounded,
                          label: 'Favoris',
                          subtitle: 'Offres sauvegardées',
                          gradient: const [Color(0xFFF59E0B), Color(0xFFFBBF24)],
                          onTap: () => _navigateToFavorites(context),
                        ),
                        _ActionCard(
                          icon: Icons.calendar_today_rounded,
                          label: 'Entretiens',
                          subtitle: 'Mes RDV',
                          gradient: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                          onTap: () => _navigateToInterviews(context),
                        ),
                        _ActionCard(
                          icon: Icons.report_problem_rounded,
                          label: 'Réclamation',
                          subtitle: 'Contacter RH',
                          gradient: const [Color(0xFFEF4444), Color(0xFFF87171)],
                          onTap: () => _navigateToReclamation(context),
                        ),
                        _ActionCard(
                          icon: Icons.notifications_active_rounded,
                          label: 'Notifications',
                          subtitle: 'Alertes RH',
                          gradient: const [Color(0xFF06B6D4), Color(0xFF22D3EE)],
                          onTap: () => _navigateToNotifications(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // AI Assistant Banner (compact)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.info.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assistant IA',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textDark,
                                  ),
                                ),
                                Text(
                                  'Optimisez votre carrière',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textGrey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textGrey.withOpacity(0.5),
                            size: 14,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // FONCTIONS DE NAVIGATION (inchangées)
  // ══════════════════════════════════════════════════════════════

  void _navigateToSearch(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/offres');
  }

  void _navigateToUploadCV(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.upload_file_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Déposer CV'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  style: BorderStyle.solid,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: AppColors.primary.withOpacity(0.6),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'PDF, JPG ou PNG',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Maximum 5MB',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📄 Sélectionnez votre fichier CV'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            icon: const Icon(Icons.upload, size: 16),
            label: const Text('Choisir'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFavorites(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/offres/saved');
  }

  void _navigateToInterviews(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/entretiens');
  }

  void _navigateToReclamation(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => SubmitReclamationDialog(candidatureId: 0),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    Navigator.pop(context);
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/notifications');
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGET CARTE D'ACTION (compact)
// ══════════════════════════════════════════════════════════════
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: gradient.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textGrey.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}