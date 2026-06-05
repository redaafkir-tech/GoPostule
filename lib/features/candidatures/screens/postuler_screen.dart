// lib/features/candidatures/screens/postuler_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/candidature_service.dart';
import '../../../core/services/dossier_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/offre.dart';

class PostulerScreen extends StatefulWidget {
  final Offre offre;

  const PostulerScreen({super.key, required this.offre});

  @override
  State<PostulerScreen> createState() => _PostulerScreenState();
}

class _PostulerScreenState extends State<PostulerScreen>
    with TickerProviderStateMixin {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _lettreController = TextEditingController();
  final CandidatureService _candidatureService = CandidatureService();
  final DossierService _dossierService = DossierService();

  bool _isLoading = false;
  bool _accepteConditions = false;
  int _currentStep = 0;

  // Fichiers sélectionnés
  PlatformFile? _fileCV;
  PlatformFile? _filePhoto;
  PlatformFile? _fileCIN;
  PlatformFile? _fileDiplome;

  // Données bytes pour web
  Uint8List? _cvBytes;
  Uint8List? _photoBytes;
  Uint8List? _cinBytes;
  Uint8List? _diplomeBytes;

  // Statuts d'upload
  UploadStatus _cvStatus = UploadStatus.notUploaded;
  UploadStatus _photoStatus = UploadStatus.notUploaded;
  UploadStatus _cinStatus = UploadStatus.notUploaded;
  UploadStatus _diplomeStatus = UploadStatus.notUploaded;

  String? _cvError;
  String? _photoError;
  String? _cinError;
  String? _diplomeError;

  late AnimationController _fadeController;
  late AnimationController _stepController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _stepProgress;

  final List<String> _conseils = [
    '💡 Personnalisez votre lettre pour cette offre spécifique',
    '💡 Mettez en avant vos compétences techniques pertinentes',
    '💡 Vérifiez que votre CV est au format PDF',
    '💡 Une photo professionnelle augmente vos chances de 40%',
  ];
  int _conseilIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _stepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _stepProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _stepController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _stepController.dispose();
    _lettreController.dispose();
    super.dispose();
  }

  // ✅ MÉTHODE _showMessage
  void _showMessage(String msg, {required String type}) {
    Color bg;
    switch (type) {
      case 'success': bg = Colors.green.shade600; break;
      case 'warning': bg = Colors.orange.shade600; break;
      case 'error': bg = Colors.red.shade600; break;
      default: bg = AppColors.primary;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // 📁 UPLOAD DE FICHIERS (WEB + MOBILE)
  // ─────────────────────────────────────────────────────────
  Future<void> _pickFile(String type) async {
    final Map<String, List<String>> extensions = {
      'cv': ['pdf'],
      'photo': ['jpg', 'jpeg', 'png'],
      'cin': ['pdf', 'jpg', 'jpeg', 'png'],
      'diplome': ['pdf'],
    };

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: extensions[type],
        lockParentWindow: true,
        withData: true,
      );

      if (result == null) return;

      final file = result.files.first;

      if (file.size == null) {
        _setError(type, 'Impossible de déterminer la taille du fichier');
        return;
      }

      final fileSizeMB = file.size! / (1024 * 1024);
      final maxMB = (type == 'photo') ? 2.0 : 5.0;

      if (fileSizeMB > maxMB) {
        _setError(type, 'Fichier trop volumineux (max ${maxMB.toInt()}MB)');
        return;
      }

      _setStatus(type, UploadStatus.uploading);

      if (kIsWeb) {
        if (file.bytes == null) {
          _setError(type, 'Erreur: Impossible de lire le fichier');
          return;
        }
        switch (type) {
          case 'cv': _cvBytes = file.bytes!; break;
          case 'photo': _photoBytes = file.bytes!; break;
          case 'cin': _cinBytes = file.bytes!; break;
          case 'diplome': _diplomeBytes = file.bytes!; break;
        }
      } else {
        if (file.path == null) {
          _setError(type, 'Chemin de fichier invalide');
          return;
        }
      }

      final savedPath = await _saveFileToAppDirectory(file, type);

      if (savedPath == null && !kIsWeb) {
        _setError(type, 'Échec de la sauvegarde du fichier');
        return;
      }

      setState(() {
        switch (type) {
          case 'cv': _fileCV = file; break;
          case 'photo': _filePhoto = file; break;
          case 'cin': _fileCIN = file; break;
          case 'diplome': _fileDiplome = file; break;
        }
        _setStatus(type, UploadStatus.uploaded);
      });

    } on PlatformException catch (e) {
      _setError(type, 'Erreur d\'accès: ${e.message}');
    } catch (e) {
      _setError(type, 'Erreur: ${e.toString()}');
    }
  }

  // ─────────────────────────────────────────────────────────
  // 💾 SAUVEGARDE DANS DOSSIERS ORGANISÉS
  // ─────────────────────────────────────────────────────────
  Future<String?> _saveFileToAppDirectory(PlatformFile file, String type) async {
    try {
      if (kIsWeb) return null;

      final baseDir = await getApplicationDocumentsDirectory();

      String subFolder;
      switch (type) {
        case 'cv': subFolder = 'CVs'; break;
        case 'photo': subFolder = 'Photos'; break;
        case 'cin': subFolder = 'CINs'; break;
        case 'diplome': subFolder = 'Diplomes'; break;
        default: subFolder = 'Documents';
      }

      final targetDir = Directory('${baseDir.path}/GoPostule/$subFolder');

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(file.name);
      final fileName = '${type}_$timestamp$extension';
      final filePath = '${targetDir.path}/$fileName';

      if (file.path != null) {
        final sourceFile = File(file.path!);
        await sourceFile.copy(filePath);
        return filePath;
      }
      return null;

    } catch (e) {
      debugPrint('Erreur sauvegarde fichier: $e');
      return null;
    }
  }

  void _setStatus(String type, UploadStatus status) {
    setState(() {
      switch (type) {
        case 'cv': _cvStatus = status; break;
        case 'photo': _photoStatus = status; break;
        case 'cin': _cinStatus = status; break;
        case 'diplome': _diplomeStatus = status; break;
      }
    });
  }

  void _setError(String type, String message) {
    setState(() {
      switch (type) {
        case 'cv': _cvStatus = UploadStatus.failed; _cvError = message; break;
        case 'photo': _photoStatus = UploadStatus.failed; _photoError = message; break;
        case 'cin': _cinStatus = UploadStatus.failed; _cinError = message; break;
        case 'diplome': _diplomeStatus = UploadStatus.failed; _diplomeError = message; break;
      }
    });
  }

  void _removeFile(String type) {
    setState(() {
      switch (type) {
        case 'cv': _fileCV = null; _cvBytes = null; _cvStatus = UploadStatus.notUploaded; _cvError = null; break;
        case 'photo': _filePhoto = null; _photoBytes = null; _photoStatus = UploadStatus.notUploaded; _photoError = null; break;
        case 'cin': _fileCIN = null; _cinBytes = null; _cinStatus = UploadStatus.notUploaded; _cinError = null; break;
        case 'diplome': _fileDiplome = null; _diplomeBytes = null; _diplomeStatus = UploadStatus.notUploaded; _diplomeError = null; break;
      }
    });
  }

  // ─────────────────────────────────────────────────────────
  // 📤 SOUMISSION CANDIDATURE - CORRIGÉE
  // ─────────────────────────────────────────────────────────
  Future<void> _submitCandidature() async {
    print('🚀 Début soumission candidature...');

    int userId = 0;
    int candidatureId = 0;
    String? cvPath;
    String? photoPath;
    String? cinPath;
    String? diplomePath;

    // ✅ Vérification conditions
    if (!_accepteConditions) {
      print('❌ Conditions non acceptées');
      _showMessage('Veuillez accepter les conditions', type: 'warning');
      return;
    }
    print('✅ Conditions acceptées');

    // ✅ Vérification offre
    if (widget.offre == null) {
      print('❌ widget.offre est null');
      _showMessage('Erreur: Offre non trouvée', type: 'error');
      return;
    }
    print('✅ Offre: ${widget.offre.id} - ${widget.offre.titre}');

    // ✅ Vérification fichiers obligatoires
    print('📄 CV: ${_fileCV?.name ?? "null"}');
    print('📸 Photo: ${_filePhoto?.name ?? "null"}');
    print('🆔 CIN: ${_fileCIN?.name ?? "null"}');
    print('🎓 Diplôme: ${_fileDiplome?.name ?? "null"}');

    if (_fileCV == null || _filePhoto == null) {
      print('❌ CV ou photo manquant');
      _showMessage('CV et photo sont obligatoires', type: 'warning');
      return;
    }
    print('✅ Fichiers obligatoires présents');

    setState(() => _isLoading = true);

    try {
      // ✅ Appel API - Création candidature
      print('📡 Appel API postuler...');
      print('   Offre ID: ${widget.offre.id}');
      print('   Lettre: ${_lettreController.text.trim().length} caractères');

      final candidatureResult = await _candidatureService.postuler(
        offreId: widget.offre.id,
        lettreMotivation: _lettreController.text.trim(),
      );

      print('✅ Candidature créée: $candidatureResult');
      candidatureId = candidatureResult['id'] as int;
      print('   ID: $candidatureId');

      // ✅ Récupérer user
      print('📡 Récupération infos utilisateur...');
      final userMap = await AuthService.getMe();
      print('✅ User: ${userMap['Nom']} ${userMap['Prenom']}');

      userId = userMap['Id'] ?? userMap['id'] ?? 0;
      final nom = userMap['Nom'] ?? userMap['nom'] ?? '';
      final prenom = userMap['Prenom'] ?? userMap['prenom'] ?? '';

      // ✅ Préparer chemins - WEB vs MOBILE
      if (!kIsWeb) {
        // 📱 MOBILE: utiliser les chemins
        cvPath = _fileCV?.path ?? '';
        photoPath = _filePhoto?.path ?? '';
        cinPath = _fileCIN?.path ?? '';
        diplomePath = _fileDiplome?.path ?? '';
        print('📁 Chemins locaux:');
        print('   CV: $cvPath');
        print('   Photo: $photoPath');
      } else {
        // 🌐 WEB: utiliser base64
        if (_cvBytes != null) {
          cvPath = 'data:application/pdf;base64,${base64Encode(_cvBytes!)}';
          print('📄 CV en base64 (Web)');
        }
        if (_photoBytes != null) {
          photoPath = 'data:image/jpeg;base64,${base64Encode(_photoBytes!)}';
          print('📸 Photo en base64 (Web)');
        }
        if (_cinBytes != null) {
          cinPath = 'data:application/pdf;base64,${base64Encode(_cinBytes!)}';
        }
        if (_diplomeBytes != null) {
          diplomePath = 'data:application/pdf;base64,${base64Encode(_diplomeBytes!)}';
        }
      }

      // ✅ Créer dossier - AVEC TOUS LES PARAMÈTRES
      print('📡 Création du dossier...');

      await _dossierService.createDossier(
        userId: userId,
        candidatureId: candidatureId,
        nom: nom,
        prenom: prenom,
        cheminCIN: cinPath ?? '',
        cheminCV: cvPath ?? '',
        cheminDiplome: diplomePath ?? '',
        cheminPhoto: photoPath ?? '',
      );

      print('✅ Dossier créé avec succès');

      // ✅ Message succès + Redirection
      if (mounted) {
        print('✅ Candidature terminée avec succès!');
        _showMessage('✅ Candidature envoyée avec succès !', type: 'success');

        print('⏳ Attente 1 seconde...');
        await Future.delayed(const Duration(seconds: 1));

        if (mounted) {
          print('🔄 Redirection vers /home...');
          await Navigator.of(context).pushNamedAndRemoveUntil(
            '/home',
                (route) => false,
          );
          print('✅ Redirection effectuée');
        }
      }

    } on DioException catch (e) {
      print('❌ Erreur Dio: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');

      if (mounted) {
        // ✅ Extraire le vrai message d'erreur du backend
        String backendError = '';
        if (e.response?.data is Map) {
          final data = e.response?.data as Map;
          backendError = data['message']
              ?? data['errors']?.toString()
              ?? data['error']
              ?? data['title']
              ?? '';
        }

        String errorMessage;
        if (backendError.isNotEmpty) {
          errorMessage = 'Erreur: $backendError';
        } else if (e.response?.statusCode == 400) {
          errorMessage = 'Erreur 400: Données invalides. Vérifiez vos informations.';
        } else if (e.response?.statusCode == 401) {
          errorMessage = 'Erreur 401: Session expirée. Reconnectez-vous.';
        } else if (e.response?.statusCode == 500) {
          errorMessage = 'Erreur 500: Problème serveur. Réessayez plus tard.';
        } else {
          errorMessage = 'Erreur de connexion au serveur.';
        }

        _showMessage(errorMessage, type: 'error');
      }
    } on PlatformException catch (e) {
      print('❌ Erreur plateforme: ${e.message}');
      if (mounted) {
        _showMessage('Erreur plateforme: ${e.message}', type: 'error');
      }
    } catch (e, stackTrace) {
      print('❌ Erreur générale: $e');
      print('📋 Stack trace: $stackTrace');
      if (mounted) {
        _showMessage('Erreur: ${e.toString()}', type: 'error');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        print('🏁 Soumission terminée');
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  // ✅ MÉTHODE BUILD OBLIGATOIRE
  // ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Postuler'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildOfferHeader(),
            _buildInteractiveStepper(),
            Expanded(child: _buildStepContent()),
            _buildProgressBar(),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // WIDGETS DE BUILD
  // ─────────────────────────────────────────────────────────
  Widget _buildOfferHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.9),
            AppColors.info.withOpacity(0.8),
          ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    widget.offre.entreprise.substring(0, 2).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.offre.titre,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.offre.entreprise,
                      style: TextStyle(fontSize: 15, color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: [
              _buildTag(Icons.work_outline, widget.offre.secteur),
              _buildTag(Icons.business_center, widget.offre.typeContrat),
              _buildTag(Icons.location_on, widget.offre.localisation),
              if (widget.offre.salaire != null && widget.offre.salaire!.isNotEmpty)
                _buildTag(Icons.attach_money, widget.offre.salaire!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStepper() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              AnimatedBuilder(
                animation: _stepProgress,
                builder: (context, child) {
                  return FractionallySizedBox(
                    widthFactor: _stepProgress.value,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStepButton(0, 'Infos'),
              _buildStepButton(1, 'Documents'),
              _buildStepButton(2, 'Confirmation'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return GestureDetector(
      onTap: isCompleted ? () => _goToStep(step) : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : isCompleted ? AppColors.success : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 18)
                  : Text(
                '${step + 1}',
                style: TextStyle(
                    color: isActive || isCompleted ? Colors.white : Colors.grey.shade600,
                    fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
                color: isActive ? AppColors.primary : Colors.grey.shade500,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _goToStep(int step) {
    if (step < _currentStep) {
      setState(() => _currentStep = step);
      _stepController.forward(from: 0);
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0: return _buildInfoStep();
      case 1: return _buildDocumentsStep();
      case 2: return _buildConfirmationStep();
      default: return Container();
    }
  }

  Widget _buildInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lettre de motivation',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Présentez-vous et expliquez pourquoi ce poste vous intéresse',
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4)
                  ),
                ],
              ),
              child: TextFormField(
                controller: _lettreController,
                maxLines: 10,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: 'Madame, Monsieur,\n\nJe vous écris pour postuler...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Veuillez écrire une lettre';
                  }

                  final trimmed = value.trim();

                  if (trimmed.isEmpty) {
                    return 'La lettre ne peut pas être vide';
                  }

                  if (trimmed.length < 10) {
                    return 'Minimum 10 caractères (${trimmed.length}/10)';
                  }

                  if (trimmed.length > 2000) {
                    return 'Maximum 2000 caractères';
                  }

                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                '${_lettreController.text.length}/2000',
                style: TextStyle(
                  color: _lettreController.text.length > 1800
                      ? Colors.orange
                      : Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Documents requis',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tous les documents marqués * sont obligatoires • Max 5MB par fichier',
            style: TextStyle(color: AppColors.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _buildDocumentCard(
            type: 'cv', icon: Icons.description, label: 'Curriculum Vitae (CV) *',
            subtitle: 'Format PDF uniquement • Max 5MB', helperText: 'Assurez-vous que votre CV est à jour',
            file: _fileCV, status: _cvStatus, error: _cvError,
            onPick: () => _pickFile('cv'), onRemove: () => _removeFile('cv'),
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(height: 12),
          _buildDocumentCard(
            type: 'photo', icon: Icons.photo_camera, label: 'Photo d\'identité *',
            subtitle: 'Format PNG ou JPG • Max 2MB', helperText: 'Photo récente, fond clair',
            file: _filePhoto, status: _photoStatus, error: _photoError,
            onPick: () => _pickFile('photo'), onRemove: () => _removeFile('photo'),
            color: const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 12),
          _buildDocumentCard(
            type: 'cin', icon: Icons.credit_card, label: 'Carte d\'identité (CIN)',
            subtitle: 'PDF ou JPG/PNG • Max 5MB', helperText: 'Recto et verso lisibles',
            file: _fileCIN, status: _cinStatus, error: _cinError,
            onPick: () => _pickFile('cin'), onRemove: () => _removeFile('cin'),
            color: const Color(0xFF10B981),
          ),
          const SizedBox(height: 12),
          _buildDocumentCard(
            type: 'diplome', icon: Icons.school, label: 'Diplôme(s)',
            subtitle: 'Format PDF uniquement • Max 5MB', helperText: 'Dernier diplôme obtenu',
            file: _fileDiplome, status: _diplomeStatus, error: _diplomeError,
            onPick: () => _pickFile('diplome'), onRemove: () => _removeFile('diplome'),
            color: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Récapitulatif',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              children: [
                _buildRecapRow('Offre', widget.offre.titre),
                _buildRecapRow('Entreprise', widget.offre.entreprise),
                _buildRecapRow('Localisation', widget.offre.localisation),
                _buildRecapRow('Contrat', widget.offre.typeContrat),
                const Divider(height: 24),
                _buildRecapRow('Lettre', '${_lettreController.text.length} caractères'),
                _buildRecapRow('CV', _fileCV != null ? '✓ Ajouté' : '✗ Manquant', success: _fileCV != null),
                _buildRecapRow('Photo', _filePhoto != null ? '✓ Ajouté' : '✗ Manquant', success: _filePhoto != null),
                _buildRecapRow('CIN', _fileCIN != null ? '✓ Ajouté' : '✗ Manquant', success: _fileCIN != null),
                _buildRecapRow('Diplôme', _fileDiplome != null ? '✓ Ajouté' : '✗ Manquant', success: _fileDiplome != null),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _accepteConditions ? AppColors.primary.withOpacity(0.4) : AppColors.primary.withOpacity(0.2),
                width: _accepteConditions ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _accepteConditions = !_accepteConditions),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24, height: 24,
                    decoration: BoxDecoration(
                      color: _accepteConditions ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _accepteConditions ? AppColors.primary : AppColors.textGrey.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: _accepteConditions ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _accepteConditions = !_accepteConditions),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 12, color: AppColors.textGrey, height: 1.4),
                        children: [
                          const TextSpan(text: 'Je certifie que les informations sont exactes et j\'accepte les '),
                          TextSpan(
                            text: 'conditions de candidature',
                            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.timelapse, color: AppColors.accent, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '⏱️ Temps de traitement estimé: 3-5 jours ouvrés',
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecapRow(String label, String value, {bool success = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
          Row(
            children: [
              if (success) Icon(Icons.check_circle, color: AppColors.success, size: 16),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                    color: success ? AppColors.success : AppColors.textDark,
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String type,
    required IconData icon,
    required String label,
    required String subtitle,
    required String? helperText,
    required PlatformFile? file,
    required UploadStatus status,
    required String? error,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required Color color,
  }) {
    final isUploaded = status == UploadStatus.uploaded;
    final isUploading = status == UploadStatus.uploading;
    final isFailed = status == UploadStatus.failed;
    final fileName = file?.name;

    return GestureDetector(
      onTap: isUploaded ? null : onPick,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUploaded ? color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFailed ? Colors.red.shade300 : isUploaded ? color.withOpacity(0.4) : const Color(0xFFE8ECF4),
            width: isFailed || isUploaded ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: isFailed ? Colors.red.shade100 : color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isFailed ? Icons.error_outline : icon,
                        color: isFailed ? Colors.red : color,
                        size: 24,
                      ),
                    ),
                    if (isUploading)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
                      if (isFailed && error != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, size: 12, color: Colors.red.shade600),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  error,
                                  style: TextStyle(fontSize: 11, color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: isUploaded ? color : isFailed ? Colors.red.shade500 : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: isUploading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : IconButton(
                    icon: Icon(
                        isUploaded ? Icons.check : isFailed ? Icons.refresh : Icons.upload,
                        color: Colors.white, size: 18),
                    onPressed: isFailed ? onPick : (isUploaded ? null : onPick),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close, size: 12, color: Colors.red),
                      ),
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

  Widget _buildProgressBar() {
    double progress;
    String progressText;

    switch (_currentStep) {
      case 0:
        progress = 0.0;
        progressText = '0% - Informations';
        break;
      case 1:
        progress = 0.33;
        progressText = '33% - Documents';
        break;
      case 2:
        progress = 0.66;
        progressText = '66% - Confirmation';
        break;
      default:
        progress = 0.0;
        progressText = '0%';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            progressText,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() => _currentStep--);
                  _stepController.forward(from: 0);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Précédent', style: TextStyle(color: AppColors.primary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep > 0 ? 2 : 1,
            child: ElevatedButton.icon(
              onPressed: () {
                if (_currentStep < 2) {
                  if (_currentStep == 0) {
                    print('📝 Validation étape Infos...');
                    print('   Longueur lettre: ${_lettreController.text.trim().length}');

                    if (_formKey.currentState == null) {
                      print('❌ _formKey est null');
                      return;
                    }

                    if (_formKey.currentState!.validate()) {
                      print('✅ Formulaire valide');
                      setState(() => _currentStep++);
                      _stepController.forward(from: 0);
                    } else {
                      print('❌ Formulaire invalide - vérifiez la lettre');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez remplir la lettre de motivation (min 10 caractères)'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    }
                  }
                  else if (_currentStep == 1) {
                    print('📄 Validation étape Documents...');
                    print('   CV: ${_fileCV?.name ?? "null"}');
                    print('   Photo: ${_filePhoto?.name ?? "null"}');

                    if (_fileCV == null || _filePhoto == null) {
                      print('❌ Documents manquants');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('CV et photo sont obligatoires'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    print('✅ Documents valides');
                    setState(() => _currentStep++);
                    _stepController.forward(from: 0);
                  }
                } else {
                  _submitCandidature();
                }
              },
              icon: _isLoading && _currentStep == 2
                  ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.arrow_forward, size: 18),
              label: Text(
                _currentStep < 2
                    ? 'Continuer'
                    : _isLoading
                    ? 'Envoi...'
                    : 'Envoyer ma candidature',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accepteConditions || _currentStep < 2
                    ? AppColors.primary
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: (_accepteConditions || _currentStep < 2) ? 2 : 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ENUM UPLOAD STATUS - DOIT ÊTRE EN DEHORS DE LA CLASSE
// ══════════════════════════════════════════════════════════════
enum UploadStatus {
  notUploaded,
  uploading,
  uploaded,
  failed,
}