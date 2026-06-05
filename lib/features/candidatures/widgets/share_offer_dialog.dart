// lib/features/candidatures/widgets/share_offer_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/offre.dart';

class ShareOfferDialog extends StatelessWidget {
  final Offre offre;

  const ShareOfferDialog({
    super.key,
    required this.offre,
  });

  void _shareViaSMS(BuildContext context) async {
    final message = '''
🔍 Offre d'emploi : ${offre.titre}
🏢 Entreprise : ${offre.entreprise}
📍 Localisation : ${offre.localisation}
💼 Type : ${offre.typeContrat}

Postulez maintenant sur GoPostule !
''';

    // Copier dans le presse-papiers
    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message copié ! Collez-le dans votre application SMS'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _shareViaEmail(BuildContext context) async {
    final message = '''
Bonjour,

Je souhaite vous partager cette offre d'emploi :

🔍 ${offre.titre}
🏢 ${offre.entreprise}
📍 ${offre.localisation}
💼 ${offre.typeContrat}
${offre.salaire != null && offre.salaire!.isNotEmpty ? '💰 ${offre.salaire}' : ''}

Cordialement,
''';

    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message copié ! Collez-le dans votre email'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _shareViaWhatsApp(BuildContext context) async {
    final message = '''
🔍 *${offre.titre}*
🏢 *${offre.entreprise}*
📍 ${offre.localisation}
💼 ${offre.typeContrat}

Postulez maintenant !
''';

    await Clipboard.setData(ClipboardData(text: message));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message copié ! Collez-le dans WhatsApp'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _copyLink(BuildContext context) {
    final link = 'https://gopostule.ma/offres/${offre.id}';

    Clipboard.setData(ClipboardData(text: link));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lien copié: $link'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.share,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Partager cette offre',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offre.titre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offre.entreprise,
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Partager via',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
            _buildShareOption(
              context: context,
              icon: Icons.message,
              color: Colors.green,
              label: 'SMS',
              onTap: () => _shareViaSMS(context),
            ),
            _buildShareOption(
              context: context,
              icon: Icons.email,
              color: Colors.red,
              label: 'Email',
              onTap: () => _shareViaEmail(context),
            ),
            _buildShareOption(
              context: context,
              icon: Icons.chat,
              color: Colors.green.shade600,
              label: 'WhatsApp',
              onTap: () => _shareViaWhatsApp(context),
            ),
            _buildShareOption(
              context: context,
              icon: Icons.link,
              color: AppColors.primary,
              label: 'Copier le lien',
              onTap: () => _copyLink(context),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label),
      trailing: Icon(Icons.chevron_right, color: AppColors.textGrey),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}