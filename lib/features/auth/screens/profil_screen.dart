// lib/features/auth/screens/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/user_model.dart';
import '../../../core/services/storage_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isLoading = false;
  bool _pageLoading = true;
  bool _isUploadingPhoto = false;
  UserModel? _user;

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _photoUrl;

  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _telephoneController;
  String? _selectedVille;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _villes = [
    'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Kénitra', 'Tétouan',
    'Safi', 'Salé', 'Beni Mellal', 'Nador', 'Khouribga',
    'El Jadida', 'Settat', 'Taza', 'Essaouira', 'Khemisset',
    'Guelmim', 'Laâyoune', 'Dakhla', 'Ouarzazate', 'Chefchaouen',
    'Larache', 'Berkane', 'Mohammedia', 'Khénifra',
  ];

  final ImagePicker _picker = ImagePicker();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    return 'http://10.0.2.2:5000';
  }

  int get _profileCompletion {
    int completion = 0;
    if (_user?.nom.isNotEmpty ?? false) completion += 15;
    if (_user?.prenom.isNotEmpty ?? false) completion += 15;
    if (_user?.email.isNotEmpty ?? false) completion += 15;
    if (_user?.telephone.isNotEmpty ?? false) completion += 15;
    if (_user?.ville.isNotEmpty ?? false) completion += 10;
    if (_photoUrl != null || _imageFile != null || _imageBytes != null) completion += 20;
    if ((_user?.nom.length ?? 0) > 2 && (_user?.prenom.length ?? 0) > 2) completion += 10;
    return completion;
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _initControllers();
    _chargerProfil();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  void _initControllers() {
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _emailController = TextEditingController();
    _telephoneController = TextEditingController();
  }

  // ─────────────────────────────────────────────────────────────
  // 📸 UPLOAD PHOTO
  // ─────────────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile == null) return;
      setState(() => _isUploadingPhoto = true);

      String? uploadedPhotoUrl;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _imageBytes = bytes);
        uploadedPhotoUrl = await _uploadPhotoBytesToServer(bytes, pickedFile.name);
      } else {
        final file = File(pickedFile.path);
        setState(() => _imageFile = file);
        uploadedPhotoUrl = await _uploadPhotoFileToServer(file);
      }

      if (uploadedPhotoUrl != null && _user != null) {
        await AuthService.updateMe(
          nom: _user!.nom,
          prenom: _user!.prenom,
          email: _user!.email,
          telephone: _user!.telephone,
          ville: _user!.ville,
          photoUrl: uploadedPhotoUrl,
        );

        setState(() {
          _photoUrl = uploadedPhotoUrl;
          _user = _user!.copyWith(photoUrl: uploadedPhotoUrl);
          _imageFile = null;
          _imageBytes = null;
        });

        if (mounted) _showSuccess('Photo mise à jour ✅');
      } else {
        if (mounted) _showError('Upload échoué');
      }

      setState(() => _isUploadingPhoto = false);
    } catch (e) {
      setState(() => _isUploadingPhoto = false);
      if (mounted) _showError('Erreur: ${e.toString()}');
    }
  }

  Future<String?> _uploadPhotoFileToServer(File imageFile) async {
    try {
      final token = await StorageService.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/auth/upload-photo'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', imageFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var json = jsonDecode(data);
        return json['photoUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Erreur upload mobile: $e');
      return null;
    }
  }

  Future<String?> _uploadPhotoBytesToServer(Uint8List bytes, String fileName) async {
    try {
      final token = await StorageService.getToken();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/auth/upload-photo'),
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(http.MultipartFile.fromBytes('photo', bytes, filename: fileName));

      var response = await request.send();
      if (response.statusCode == 200) {
        var data = await response.stream.bytesToString();
        var json = jsonDecode(data);
        return json['photoUrl'] as String?;
      }
      return null;
    } catch (e) {
      print('❌ Erreur upload web: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📡 CHARGEMENT PROFIL
  // ─────────────────────────────────────────────────────────────
  Future<void> _chargerProfil() async {
    setState(() => _pageLoading = true);
    try {
      final data = await AuthService.getMe();
      print('📋 DATA PROFIL: $data');

      setState(() {
        _user = UserModel(
          id: data['Id'] ?? data['id'] ?? 0,
          nom: data['Nom'] ?? data['nom'] ?? '',
          prenom: data['Prenom'] ?? data['prenom'] ?? '',
          email: data['Email'] ?? data['email'] ?? '',
          ville: data['Ville'] ?? data['ville'] ?? '',
          telephone: data['Telephone'] ?? data['telephone'] ?? '',
          photoUrl: data['PhotoUrl'] ?? data['photoUrl'],
        );

        _photoUrl = _user!.photoUrl;
        _nomController.text = _user!.nom;
        _prenomController.text = _user!.prenom;
        _emailController.text = _user!.email;
        _telephoneController.text = _user!.telephone;
        _selectedVille = _user!.ville.isNotEmpty ? _user!.ville : null;
        _pageLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement profil: $e');
      setState(() => _pageLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 💾 SAUVEGARDE PROFIL
  // ─────────────────────────────────────────────────────────────
  Future<void> _sauvegarder() async {
    if (!_formValide()) return;
    setState(() => _isLoading = true);

    try {
      await AuthService.updateMe(
        nom: _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        ville: _selectedVille ?? '',
        photoUrl: _photoUrl,
      );

      setState(() {
        _user = _user!.copyWith(
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          email: _emailController.text.trim(),
          ville: _selectedVille ?? '',
          telephone: _telephoneController.text.trim(),
        );
        _isEditing = false;
      });

      if (mounted) _showSuccess('Profil mis à jour ✅');
    } catch (e) {
      if (mounted) _showError(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool _formValide() {
    if (_nomController.text.trim().length < 2) {
      _showError('Le nom doit contenir au moins 2 caractères');
      return false;
    }
    if (_prenomController.text.trim().length < 2) {
      _showError('Le prénom doit contenir au moins 2 caractères');
      return false;
    }
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(_emailController.text.trim())) {
      _showError('Email invalide');
      return false;
    }
    return true;
  }

  void _annulerEdition() {
    setState(() {
      _isEditing = false;
      _nomController.text = _user!.nom;
      _prenomController.text = _user!.prenom;
      _emailController.text = _user!.email;
      _telephoneController.text = _user!.telephone;
      _selectedVille = _user!.ville;
    });
  }

  void _confirmerDeconnexion() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, spreadRadius: 5),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded, size: 40, color: Colors.red.shade600),
              ),
              const SizedBox(height: 20),
              const Text(
                'Déconnexion',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C)),
              ),
              const SizedBox(height: 8),
              const Text(
                'Voulez-vous vraiment vous déconnecter ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Annuler', style: TextStyle(color: Color(0xFF1A3A5C))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Déconnexion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle, color: Colors.white),
        const SizedBox(width: 12),
        Text(message),
      ]),
      backgroundColor: AppColors.statusOffer,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 12),
        Expanded(child: Text(message)),
      ]),
      backgroundColor: AppColors.statusRejected,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 4),
    ));
  }

  @override
  Widget build(BuildContext context) {
    if (_pageLoading) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(
                  color: const Color(0xFFE8B74B),
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Chargement...',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    if (_user == null) {
      return Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text('Impossible de charger le profil', style: TextStyle(fontSize: 16, color: Color(0xFF1A3A5C), fontWeight: FontWeight.w600)),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _chargerProfil,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A3A5C),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
              ),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            Row(
              children: [
                TextButton(
                  onPressed: _annulerEdition,
                  child: const Text('Annuler', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sauvegarder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B74B),
                    foregroundColor: const Color(0xFF1A3A5C),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFF1A3A5C), strokeWidth: 2))
                      : const Text('Sauvegarder', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 16),
              ],
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildPremiumHeader(),
              const SizedBox(height: 24),
              _buildProfileCompletion(),
              const SizedBox(height: 16),
              _buildPersonalInfoSection(),
              const SizedBox(height: 16),
              _buildSecuritySection(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🎨 PREMIUM HEADER (Badge Candidat SUPPRIMÉ)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPremiumHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E3A8A),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showFullImage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  TweenAnimationBuilder(
                    duration: const Duration(seconds: 2),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              const Color(0xFFE8B74B).withOpacity(value),
                              const Color(0xFFF5D78E),
                              const Color(0xFFE8B74B).withOpacity(value),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 4,
                    child: Container(
                      width: 122,
                      height: 122,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  Positioned(
                    child: Container(
                      width: 114,
                      height: 114,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE8B74B).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _isUploadingPhoto
                            ? Container(
                          color: const Color(0xFF1E3A8A),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFFE8B74B), strokeWidth: 2.5),
                          ),
                        )
                            : _getImageWidget(),
                      ),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8B74B),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 20, color: Color(0xFF0F172A)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '${_user!.prenom} ${_user!.nom}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
          // ❌ Badge "Candidat" SUPPRIMÉ ICI
          const SizedBox(height: 14),
          if ((_selectedVille ?? _user!.ville).isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFFE8B74B)),
                  const SizedBox(width: 6),
                  Text(
                    _selectedVille ?? (_user!.ville.isNotEmpty ? _user!.ville : 'Non spécifiée'),
                    style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 📊 PROFILE COMPLETION
  // ─────────────────────────────────────────────────────────────
  Widget _buildProfileCompletion() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A5C).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8B74B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.trending_up_rounded, size: 20, color: Color(0xFFE8B74B)),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Profil complété',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C)),
                  ),
                ],
              ),
              Text(
                '$_profileCompletion%',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFE8B74B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: _profileCompletion / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFE8B74B)),
              minHeight: 8,
            ),
          ),
          if (_profileCompletion < 100) ...[
            const SizedBox(height: 12),
            Text(
              _getCompletionMessage(),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ],
      ),
    );
  }

  String _getCompletionMessage() {
    if (_profileCompletion < 50) return 'Complétez votre profil pour augmenter vos chances';
    if (_profileCompletion < 80) return 'Presque là ! Ajoutez quelques détails supplémentaires';
    return 'Excellent ! Votre profil est presque parfait';
  }

  // ─────────────────────────────────────────────────────────────
  // 👤 PERSONAL INFO SECTION
  // ─────────────────────────────────────────────────────────────
  Widget _buildPersonalInfoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A5C).withOpacity(0.06),
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
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B74B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Informations personnelles',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildPremiumField(label: 'Nom', controller: _nomController, icon: Icons.person_outline, isEditing: _isEditing)),
              const SizedBox(width: 12),
              Expanded(child: _buildPremiumField(label: 'Prénom', controller: _prenomController, icon: Icons.person_outline, isEditing: _isEditing)),
            ],
          ),
          const SizedBox(height: 16),
          _buildPremiumField(label: 'Email', controller: _emailController, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, isEditing: _isEditing),
          const SizedBox(height: 16),
          _buildPremiumField(label: 'Téléphone', controller: _telephoneController, icon: Icons.phone_outlined, keyboardType: TextInputType.phone, isEditing: _isEditing),
          const SizedBox(height: 16),
          _buildPremiumVilleField(isEditing: _isEditing),
        ],
      ),
    );
  }

  Widget _buildPremiumField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required bool isEditing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        if (isEditing)
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1A3A5C), fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8B74B), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF64748B)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.text.isEmpty ? 'Non renseigné' : controller.text,
                    style: TextStyle(
                      fontSize: 14,
                      color: controller.text.isEmpty ? const Color(0xFF94A3B8) : const Color(0xFF1A3A5C),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPremiumVilleField({required bool isEditing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'VILLE',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8), letterSpacing: 1.2),
        ),
        const SizedBox(height: 8),
        if (isEditing)
          DropdownButtonFormField<String>(
            value: _selectedVille,
            hint: const Text('Sélectionner une ville', style: TextStyle(color: Color(0xFF94A3B8))),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE8B74B), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: _villes.map((v) => DropdownMenuItem<String>(
              value: v,
              child: Text(v, style: const TextStyle(color: Color(0xFF1A3A5C))),
            )).toList(),
            onChanged: (val) {
              setState(() {
                _selectedVille = val;
              });
            },
            isExpanded: true,
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 12),
                Text(
                  _selectedVille ?? (_user!.ville.isNotEmpty ? _user!.ville : 'Non spécifiée'),
                  style: TextStyle(
                    fontSize: 14,
                    color: (_selectedVille ?? _user!.ville).isNotEmpty ? const Color(0xFF1A3A5C) : const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🔐 SECURITY SECTION (2FA SUPPRIMÉ)
  // ─────────────────────────────────────────────────────────────
  Widget _buildSecuritySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A3A5C).withOpacity(0.06),
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
                width: 4,
                height: 22,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B74B),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sécurité',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSecurityItem(
            icon: Icons.lock_outline_rounded,
            title: 'Changer le mot de passe',
            subtitle: 'Modifiez votre mot de passe régulièrement',
            onTap: _showChangePasswordSheet,
            color: const Color(0xFF1A3A5C),
          ),
          // ❌ Authentification à deux facteurs SUPPRIMÉE
        ],
      ),
    );
  }

  Widget _buildSecurityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool comingSoon = false,
  }) {
    return InkWell(
      onTap: comingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A3A5C))),
                      if (comingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Bientôt', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🚪 LOGOUT BUTTON
  // ─────────────────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: _confirmerDeconnexion,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade50, Colors.red.shade100],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: Colors.red.shade600, size: 22),
              const SizedBox(width: 12),
              Text(
                'Se déconnecter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🖼️ IMAGE WIDGET
  // ─────────────────────────────────────────────────────────────
  Widget _getImageWidget() {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(
        _photoUrl!,
        fit: BoxFit.cover,
        width: 114,
        height: 114,
        gaplessPlayback: true,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: const Color(0xFF1E3A8A),
            child: const Center(child: CircularProgressIndicator(color: Color(0xFFE8B74B), strokeWidth: 2)),
          );
        },
        errorBuilder: (_, __, ___) => _buildInitials(),
      );
    }
    if (kIsWeb && _imageBytes != null) return Image.memory(_imageBytes!, fit: BoxFit.cover);
    if (!kIsWeb && _imageFile != null) return Image.file(_imageFile!, fit: BoxFit.cover);
    return _buildInitials();
  }

  Widget _buildInitials() {
    final initiales = '${_user!.prenom.isNotEmpty ? _user!.prenom[0] : ''}${_user!.nom.isNotEmpty ? _user!.nom[0] : ''}'.toUpperCase();
    return Container(
      color: const Color(0xFF1E3A8A),
      child: Center(
        child: Text(
          initiales,
          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFE8B74B), letterSpacing: 2),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  FULL SCREEN IMAGE
  // ─────────────────────────────────────────────────────────────
  void _showFullImage() {
    if (_photoUrl == null && _imageFile == null && _imageBytes == null) return;

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 40,
                    spreadRadius: 15,
                  ),
                ],
              ),
              child: ClipOval(
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFE8B74B), Color(0xFFF5D78E)],
                    ),
                  ),
                  child: ClipOval(
                    child: InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: _getImageWidget(),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)],
                  ),
                  child: const Icon(Icons.close, color: Color(0xFF1A3A5C), size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🔑 CHANGE PASSWORD
  // ─────────────────────────────────────────────────────────────
  void _showChangePasswordSheet() {
    final ancienCtrl = TextEditingController();
    final nouveauCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscureAncien = true, obscureNouveau = true, obscureConfirm = true;
    bool loading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFFE8B74B), borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 10),
                    const Text('Changer le mot de passe', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A3A5C))),
                  ],
                ),
                const SizedBox(height: 24),
                _buildPasswordField(ancienCtrl, 'Ancien mot de passe', obscureAncien, (v) => setModalState(() => obscureAncien = v)),
                const SizedBox(height: 14),
                _buildPasswordField(nouveauCtrl, 'Nouveau mot de passe', obscureNouveau, (v) => setModalState(() => obscureNouveau = v)),
                const SizedBox(height: 14),
                _buildPasswordField(confirmCtrl, 'Confirmer', obscureConfirm, (v) => setModalState(() => obscureConfirm = v)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A3A5C),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: loading
                        ? null
                        : () async {
                      if (ancienCtrl.text.isEmpty || nouveauCtrl.text.isEmpty || confirmCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Tous les champs sont obligatoires')));
                        return;
                      }
                      if (nouveauCtrl.text != confirmCtrl.text) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Les mots de passe ne correspondent pas')));
                        return;
                      }
                      if (nouveauCtrl.text.length < 6) {
                        ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Minimum 6 caractères requis')));
                        return;
                      }
                      setModalState(() => loading = true);
                      try {
                        await AuthService.changePassword(ancienMotDePasse: ancienCtrl.text, nouveauMotDePasse: nouveauCtrl.text);
                        Navigator.pop(ctx);
                        _showSuccess('Mot de passe changé ✅');
                      } catch (e) {
                        String msg = 'Erreur lors du changement';
                        if (e.toString().contains('400')) msg = 'Ancien mot de passe incorrect.';
                        else if (e.toString().contains('401')) msg = 'Session expirée. Reconnectez-vous.';
                        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg)));
                      } finally {
                        setModalState(() => loading = false);
                      }
                    },
                    child: loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Confirmer', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController ctrl, String label, bool obscure, ValueChanged<bool> onToggle) {
    return TextField(
      controller: ctrl,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF1A3A5C)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 18),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 18, color: const Color(0xFF94A3B8)),
          onPressed: () => onToggle(!obscure),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE8B74B), width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}