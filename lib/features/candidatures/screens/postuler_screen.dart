// lib/features/candidatures/screens/postuler_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/candidature_service.dart';
import '../../../core/services/dossier_service.dart';
import '../../../shared/offre.dart';

class PostulerScreen extends StatefulWidget {
  final Offre offre;

  const PostulerScreen({super.key, required this.offre});

  @override
  State<PostulerScreen> createState() => _PostulerScreenState();
}

class _PostulerScreenState extends State<PostulerScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _lettreController = TextEditingController();
  final _candidatureService = CandidatureService();
  final _dossierService = DossierService();

  bool _isLoading = false;
  bool _accepteConditions = false;

  // Fichiers sélectionnés
  File? _fileCV;
  File? _filePhoto;
  File? _fileCIN;
  File? _fileDiplome;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _lettreController.dispose();
    super.dispose();
  }

  Future<void> _pickFile(String type) async {
    List<String> allowedExtensions;

    switch (type) {
      case 'cv':
        allowedExtensions = ['pdf'];
        break;
      case 'photo':
        allowedExtensions = ['jpg', 'jpeg', 'png'];
        break;
      case 'cin':
        allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
        break;
      case 'diplome':
        allowedExtensions = ['pdf'];
        break;
      default:
        allowedExtensions = ['pdf', 'jpg', 'png'];
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final fileSize = await file.length();
      final fileSizeMB = fileSize / (1024 * 1024);

      // Vérification taille max (5MB pour tous)
      if (fileSizeMB > 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Fichier trop volumineux. Max 5MB. Actuel: ${fileSizeMB.toStringAsFixed(1)}MB',
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      setState(() {
        switch (type) {
          case 'cv': _fileCV = file; break;
          case 'photo': _filePhoto = file; break;
          case 'cin': _fileCIN = file; break;
          case 'diplome': _fileDiplome = file; break;
        }
      });
    }
  }

  Future<void> _submitCandidature() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepteConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez accepter les conditions de candidature'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_fileCV == null || _filePhoto == null ||
        _fileCIN == null || _fileDiplome == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez uploader tous les documents requis'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final candidatureResult = await _candidatureService.postuler(
        offreId: widget.offre.id,
        lettreMotivation: _lettreController.text.trim(),
      );

      final candidatureId = candidatureResult['id'] as int;

      await _dossierService.createDossier(
        userId: 0,
        candidatureId: candidatureId,
        nom: '',
        prenom: '',
        cheminCIN: _fileCIN!.path,
        cheminDiplome: _fileDiplome!.path,
        cheminCV: _fileCV!.path,
        cheminPhoto: _filePhoto!.path,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Candidature envoyée avec succès !'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/offres', (route) => false);
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
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Postuler'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            slivers: [
              // Header offre
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                widget.offre.entreprise.substring(0, 2).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.offre.titre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.offre.entreprise,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTag(Icons.work_outline, widget.offre.secteur, Colors.white.withOpacity(0.2)),
                          _buildTag(Icons.business_center, widget.offre.typeContrat, Colors.white.withOpacity(0.2)),
                          _buildTag(Icons.location_on, widget.offre.localisation, Colors.white.withOpacity(0.2)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Formulaire
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Lettre de motivation
                        _buildSectionHeader(Icons.edit_note, 'Lettre de motivation'),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextFormField(
                            controller: _lettreController,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: 'Présentez-vous et expliquez pourquoi ce poste vous intéresse...\n\nConseil : Soyez concis (min 50 caractères)',
                              hintStyle: TextStyle(color: AppColors.textGrey, fontSize: 13),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'La lettre de motivation est obligatoire';
                              }
                              if (value.trim().length < 50) {
                                return 'Minimum 50 caractères (${value.trim().length}/50)';
                              }
                              if (value.trim().length > 2000) {
                                return 'Maximum 2000 caractères';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Documents requis
                        _buildSectionHeader(Icons.attach_file, 'Documents requis'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            'Tous les documents sont obligatoires • Max 5MB par fichier',
                            style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildDocumentUpload(
                          icon: Icons.description,
                          label: 'Curriculum Vitae (CV)',
                          subtitle: 'Format PDF uniquement • Max 5MB',
                          helperText: 'Assurez-vous que votre CV est à jour',
                          file: _fileCV,
                          onTap: () => _pickFile('cv'),
                          color: const Color(0xFF3B82F6),
                        ),
                        const SizedBox(height: 10),

                        _buildDocumentUpload(
                          icon: Icons.photo_camera,
                          label: 'Photo d\'identité',
                          subtitle: 'Format PNG ou JPG • Max 2MB',
                          helperText: 'Photo récente, fond clair, format passeport',
                          file: _filePhoto,
                          onTap: () => _pickFile('photo'),
                          color: const Color(0xFF8B5CF6),
                        ),
                        const SizedBox(height: 10),

                        _buildDocumentUpload(
                          icon: Icons.credit_card,
                          label: 'Carte d\'identité (CIN)',
                          subtitle: 'PDF ou JPG/PNG • Max 5MB',
                          helperText: 'Recto et verso lisibles',
                          file: _fileCIN,
                          onTap: () => _pickFile('cin'),
                          color: const Color(0xFF10B981),
                        ),
                        const SizedBox(height: 10),

                        _buildDocumentUpload(
                          icon: Icons.school,
                          label: 'Diplôme(s)',
                          subtitle: 'Format PDF uniquement • Max 5MB',
                          helperText: 'Dernier diplôme obtenu ou équivalent',
                          file: _fileDiplome,
                          onTap: () => _pickFile('diplome'),
                          color: const Color(0xFFF59E0B),
                        ),
                        const SizedBox(height: 24),

                        // ✅ CHECKBOX AMÉLIORÉE
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _accepteConditions
                                  ? AppColors.primary.withOpacity(0.4)
                                  : AppColors.primary.withOpacity(0.2),
                              width: _accepteConditions ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: _accepteConditions
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _accepteConditions
                                        ? AppColors.primary
                                        : AppColors.textGrey.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: _accepteConditions
                                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _accepteConditions = !_accepteConditions),
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textGrey,
                                        height: 1.4,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: 'Je certifie que les informations fournies sont exactes et j\'accepte les ',
                                        ),
                                        TextSpan(
                                          text: 'conditions de candidature',
                                          style: TextStyle(
                                            color: _accepteConditions
                                                ? AppColors.primary
                                                : AppColors.textGrey,
                                            fontWeight: _accepteConditions
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            decoration: TextDecoration.underline,
                                            decorationColor: _accepteConditions
                                                ? AppColors.primary
                                                : Colors.transparent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ✅ BOUTON CONDITIONNEL
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            // ✅ Bouton activé SEULEMENT si case cochée ET pas en chargement
                            onPressed: (!_accepteConditions || _isLoading) ? null : _submitCandidature,
                            icon: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Icon(Icons.send, size: 20),
                            label: Text(
                              _isLoading
                                  ? 'Envoi en cours...'
                                  : 'Envoyer ma candidature',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              // ✅ Couleur change selon l'état
                              backgroundColor: _accepteConditions
                                  ? AppColors.primary
                                  : Colors.grey.shade400,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: _accepteConditions ? 2 : 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'En envoyant votre candidature, vous acceptez notre politique de confidentialité',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUpload({
    required IconData icon,
    required String label,
    required String subtitle,
    required String? helperText,
    required File? file,
    required VoidCallback onTap,
    required Color color,
  }) {
    final isUploaded = file != null;
    final fileName = isUploaded ? file!.path.split('/').last : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUploaded ? color.withOpacity(0.3) : const Color(0xFFE8ECF4),
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Row(
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('*', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      if (helperText != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          helperText,
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGrey.withOpacity(0.8),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUploaded ? color : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUploaded ? Icons.check : Icons.upload,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
            if (isUploaded && fileName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.insert_drive_file, size: 14, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      color: color,
                      onPressed: () {
                        setState(() {
                          if (label.contains('CV')) _fileCV = null;
                          else if (label.contains('Photo')) _filePhoto = null;
                          else if (label.contains('CIN')) _fileCIN = null;
                          else if (label.contains('Diplôme')) _fileDiplome = null;
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}