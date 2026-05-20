// lib/features/candidatures/widgets/document_center.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/candidature_enhanced.dart';

class DocumentCenter extends StatefulWidget {
  final CandidatureEnhanced candidature;

  const DocumentCenter({
    super.key,
    required this.candidature,
  });

  @override
  State<DocumentCenter> createState() => _DocumentCenterState();
}

class _DocumentCenterState extends State<DocumentCenter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Map<String, File?> _uploadedFiles = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _uploadDocument(String type) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _uploadedFiles[type] = File(result.files.single.path!);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document $type uploadé avec succès'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final docs = widget.candidature.documentStatus;

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
                  Icons.folder_open_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Centre de documents',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: docs.progressPercent == 100
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${docs.uploadedDocuments}/${docs.totalDocuments}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: docs.progressPercent == 100
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: docs.progressPercent / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                docs.progressPercent == 100 ? Colors.green : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 24),

          // Documents list
          _buildDocumentItem(
            icon: Icons.description_rounded,
            label: 'Curriculum Vitae',
            subtitle: 'PDF, JPG ou PNG • Max 5MB',
            isUploaded: docs.cvUploaded || _uploadedFiles['cv'] != null,
            color: const Color(0xFF3B82F6),
            onTap: () => _uploadDocument('cv'),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            icon: Icons.credit_card_rounded,
            label: 'Carte d\'identité',
            subtitle: 'PDF, JPG ou PNG • Max 5MB',
            isUploaded: docs.cinUploaded || _uploadedFiles['cin'] != null,
            color: const Color(0xFF10B981),
            onTap: () => _uploadDocument('cin'),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            icon: Icons.school_rounded,
            label: 'Diplôme',
            subtitle: 'PDF, JPG ou PNG • Max 5MB',
            isUploaded: docs.diplomeUploaded || _uploadedFiles['diplome'] != null,
            color: const Color(0xFFF59E0B),
            onTap: () => _uploadDocument('diplome'),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            icon: Icons.photo_camera_rounded,
            label: 'Photo',
            subtitle: 'JPG ou PNG • Max 2MB',
            isUploaded: docs.photoUploaded || _uploadedFiles['photo'] != null,
            color: const Color(0xFF8B5CF6),
            onTap: () => _uploadDocument('photo'),
          ),
          const SizedBox(height: 12),
          _buildDocumentItem(
            icon: Icons.edit_note_rounded,
            label: 'Lettre de motivation',
            subtitle: 'PDF uniquement • Max 5MB',
            isUploaded: docs.lettreMotivationUploaded || _uploadedFiles['lettre'] != null,
            color: const Color(0xFFEF4444),
            onTap: () => _uploadDocument('lettre'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool isUploaded,
    required Color color,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUploaded ? color.withOpacity(0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUploaded ? color.withOpacity(0.3) : Colors.grey.shade200,
          width: isUploaded ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUploaded ? color : AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.upload_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}