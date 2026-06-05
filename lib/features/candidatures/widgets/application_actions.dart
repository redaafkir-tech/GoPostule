// lib/features/candidatures/widgets/application_actions.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/candidature_enhanced.dart';
import 'document_center.dart';
import 'submit_reclamation_dialog.dart';
import 'share_offer_dialog.dart';

class ApplicationActions extends StatelessWidget {
  final CandidatureEnhanced candidature;

  const ApplicationActions({
    super.key,
    required this.candidature,
  });

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
                child: const Icon(
                  Icons.build_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Actions disponibles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Primary Actions
          _buildActionButton(
            icon: Icons.edit_document,
            label: 'Modifier documents',
            color: const Color(0xFF3B82F6),
            onTap: () => _modifyDocuments(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.download_rounded,
            label: 'Télécharger CV',
            color: const Color(0xFF10B981),
            onTap: () => _downloadCV(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.visibility_rounded,
            label: 'Voir l\'offre',
            color: const Color(0xFF8B5CF6),
            onTap: () => _viewOffer(context),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.email_rounded,
            label: 'Contacter les RH',
            color: const Color(0xFFF59E0B),
            onTap: () => _contactRecruiter(context),
          ),
          const SizedBox(height: 24),

          // Secondary Actions
          const Divider(height: 1),
          const SizedBox(height: 16),
          _buildSecondaryActionButton(
            icon: Icons.report_problem_rounded,
            label: 'Soumettre une réclamation',
            onTap: () => _submitReclamation(context),
          ),
          const SizedBox(height: 12),
          _buildSecondaryActionButton(
            icon: Icons.share_rounded,
            label: 'Partager cette offre',
            onTap: () => _shareOffer(context),
          ),
        ],
      ),
    );
  }

  // ✅ ACTIONS RÉELLES
  void _modifyDocuments(BuildContext context) {
    // Ouvrir le centre de documents en bottom sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: DocumentCenter(candidature: candidature),
          ),
        ),
      ),
    );
  }

  void _downloadCV(BuildContext context) {
    // Simulation de téléchargement - À remplacer par un vrai appel API
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📄 Préparation du téléchargement...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO: Implémenter le vrai téléchargement depuis le backend
    // Exemple: await downloadFile(candidature.documentStatus.cvUrl);
  }

  void _viewOffer(BuildContext context) {
    // Naviguer vers les détails de l'offre
    Navigator.pushNamed(
      context,
      '/offres/detail',
      arguments: candidature.offre.id,
    );
  }

  Future<void> _contactRecruiter(BuildContext context) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'rh@entreprise.com',
      query: 'subject=Candidature: ${candidature.offre.titre}',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossible d\'ouvrir le client email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _submitReclamation(BuildContext context) {
    // Ouvrir le dialog de réclamation
    showDialog(
      context: context,
      builder: (_) => SubmitReclamationDialog(
        candidatureId: int.tryParse(candidature.id) ?? 0,
      ),
    );
  }

  void _shareOffer(BuildContext context) {
    // Ouvrir le dialog de partage
    showDialog(
      context: context,
      builder: (_) => ShareOfferDialog(offre: candidature.offre),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.5),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}