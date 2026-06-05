// lib/features/auth/screens/profil_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../../../core/services/auth_service.dart';
import '../../../shared/user_model.dart';
import '../../../core/services/storage_service.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen>
    with SingleTickerProviderStateMixin {
  bool _isEditing = false;
  bool _isSaving = false;
  bool _pageLoading = true;
  bool _isUploadingPhoto = false;
  UserModel? _user;

  File? _imageFile;
  Uint8List? _imageBytes;
  String? _photoUrl;

  late TextEditingController _nomCtrl;
  late TextEditingController _prenomCtrl;
  late TextEditingController _telCtrl;
  String? _selectedVille;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final ImagePicker _picker = ImagePicker();

  static const _gold  = Color(0xFFE8B74B);
  static const _navy  = Color(0xFF1A3A5C);
  static const _bg    = Color(0xFFF4F6FA);

  final List<String> _villes = [
    'Casablanca','Rabat','Marrakech','Fès','Tanger','Agadir','Meknès','Oujda',
    'Kénitra','Tétouan','Safi','Salé','Beni Mellal','Nador','Khouribga',
    'El Jadida','Settat','Taza','Essaouira','Khemisset','Guelmim','Laâyoune',
    'Dakhla','Ouarzazate','Chefchaouen','Larache','Berkane','Mohammedia','Khénifra',
  ];

  String get _baseUrl => kIsWeb ? 'http://localhost:5000' : 'http://10.0.2.2:5000';

  int get _profileCompletion {
    int s = 0;
    if ((_user?.nom.length ?? 0) >= 2) s += 20;
    if ((_user?.prenom.length ?? 0) >= 2) s += 20;
    if (_user?.email.isNotEmpty ?? false) s += 20;
    if ((_user?.telephone.length ?? 0) >= 8) s += 20;
    if (_user?.ville.isNotEmpty ?? false) s += 10;
    if (_photoUrl != null && _photoUrl!.isNotEmpty) s += 10;
    return s.clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _nomCtrl    = TextEditingController();
    _prenomCtrl = TextEditingController();
    _telCtrl    = TextEditingController();
    _animCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim   = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _chargerProfil();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── chargement ────────────────────────────────────────────────
  Future<void> _chargerProfil() async {
    if (!mounted) return;
    setState(() => _pageLoading = true);
    try {
      final data = await AuthService.getMe();
      if (!mounted) return;
      final u = UserModel(
        id: data['Id'] ?? data['id'] ?? 0,
        nom: data['Nom'] ?? data['nom'] ?? '',
        prenom: data['Prenom'] ?? data['prenom'] ?? '',
        email: data['Email'] ?? data['email'] ?? '',
        ville: data['Ville'] ?? data['ville'] ?? '',
        telephone: data['Telephone'] ?? data['telephone'] ?? '',
        photoUrl: data['PhotoUrl'] ?? data['photoUrl'],
      );
      setState(() {
        _user = u;
        _photoUrl = u.photoUrl;
        _nomCtrl.text = u.nom;
        _prenomCtrl.text = u.prenom;
        _telCtrl.text = u.telephone;
        _selectedVille = u.ville.isNotEmpty ? u.ville : null;
        _pageLoading = false;
      });
      _animCtrl.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _pageLoading = false);
      _showError('Erreur de chargement');
    }
  }

  // ── upload photo ──────────────────────────────────────────────
  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512, maxHeight: 512, imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _isUploadingPhoto = true);
    try {
      String? url;
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        url = await _uploadBytes(bytes, picked.name);
      } else {
        url = await _uploadFile(File(picked.path));
      }
      if (url != null && _user != null && mounted) {
        await AuthService.updateMe(
          nom: _user!.nom, prenom: _user!.prenom,
          email: _user!.email, telephone: _user!.telephone,
          ville: _user!.ville, photoUrl: url,
        );
        if (!mounted) return;
        setState(() {
          _photoUrl = url;
          _user = _user!.copyWith(photoUrl: url);
          _isUploadingPhoto = false;
        });
        _showSuccess('Photo mise à jour ✅');
      } else {
        if (mounted) setState(() => _isUploadingPhoto = false);
        _showError('Échec de l\'upload');
      }
    } catch (_) {
      if (mounted) setState(() => _isUploadingPhoto = false);
      _showError('Erreur lors de l\'upload');
    }
  }

  Future<String?> _uploadFile(File file) async {
    try {
      final token = await StorageService.getToken();
      final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/auth/upload-photo'));
      req.headers['Authorization'] = 'Bearer $token';
      req.files.add(await http.MultipartFile.fromPath('photo', file.path));
      final res = await req.send();
      if (res.statusCode == 200) {
        final body = await res.stream.bytesToString();
        return jsonDecode(body)['photoUrl'] as String?;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> _uploadBytes(Uint8List bytes, String name) async {
    try {
      final token = await StorageService.getToken();
      final req = http.MultipartRequest('POST', Uri.parse('$_baseUrl/api/auth/upload-photo'));
      req.headers['Authorization'] = 'Bearer $token';
      req.files.add(http.MultipartFile.fromBytes('photo', bytes, filename: name));
      final res = await req.send();
      if (res.statusCode == 200) {
        final body = await res.stream.bytesToString();
        return jsonDecode(body)['photoUrl'] as String?;
      }
    } catch (_) {}
    return null;
  }

  // ── sauvegarde ────────────────────────────────────────────────
  Future<void> _sauvegarder() async {
    if (!_formValide()) return;
    setState(() => _isSaving = true);
    try {
      await AuthService.updateMe(
        nom: _nomCtrl.text.trim(),
        prenom: _prenomCtrl.text.trim(),
        email: _user!.email,
        telephone: _telCtrl.text.trim(),
        ville: _selectedVille ?? '',
        photoUrl: _photoUrl,
      );
      if (!mounted) return;
      setState(() {
        _user = _user!.copyWith(
          nom: _nomCtrl.text.trim(),
          prenom: _prenomCtrl.text.trim(),
          ville: _selectedVille ?? '',
          telephone: _telCtrl.text.trim(),
        );
        _isEditing = false;
        _isSaving = false;
      });
      _showSuccess('Profil mis à jour ✅');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  void _annuler() {
    setState(() {
      _isEditing = false;
      _nomCtrl.text = _user!.nom;
      _prenomCtrl.text = _user!.prenom;
      _telCtrl.text = _user!.telephone;
      _selectedVille = _user!.ville.isNotEmpty ? _user!.ville : null;
    });
  }

  bool _formValide() {
    if (_nomCtrl.text.trim().length < 2) { _showError('Nom trop court'); return false; }
    if (_prenomCtrl.text.trim().length < 2) { _showError('Prénom trop court'); return false; }
    return true;
  }

  // ── snackbars ─────────────────────────────────────────────────
  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.check_circle_rounded, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: const Color(0xFF22C55E),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white),
        const SizedBox(width: 10),
        Expanded(child: Text(msg)),
      ]),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  // ── modals ────────────────────────────────────────────────────
  void _showChangeEmailSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EmailChangeSheet(
        onSuccess: () { _showSuccess('Email mis à jour ✅'); _chargerProfil(); },
      ),
    );
  }

  void _showChangePasswordSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PasswordChangeSheet(
        onSuccess: () => _showSuccess('Mot de passe changé ✅'),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion',
            style: TextStyle(color: _navy, fontWeight: FontWeight.bold)),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await StorageService.logout();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Déconnecter', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── BUILD PRINCIPAL ───────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_pageLoading) return _buildLoader();
    if (_user == null) return _buildErrorState();

    return Scaffold(
      backgroundColor: _bg,
      // ── Barre d'actions fixe en haut (pas de SliverAppBar)
      // On utilise un Stack pour avoir le header + une AppBar transparente
      body: FadeTransition(
        opacity: _fadeAnim,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [_buildSliverHeader()],
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
            child: Column(children: [
              _buildCompletionCard(),
              const SizedBox(height: 16),
              _buildInfoCard(),
              const SizedBox(height: 16),
              _buildSecurityCard(),
              const SizedBox(height: 16),
              _buildLogoutButton(),
            ]),
          ),
        ),
      ),
    );
  }

  // ── HEADER (SliverAppBar) ─────────────────────────────────────
  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 290,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF1E3A8A),
      // ── AppBar actions : toujours visible même scrollé
      titleSpacing: 0,
      title: Row(
        children: [
          // Bouton retour
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          // ── Mode lecture : bouton Modifier
          if (!_isEditing)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: OutlinedButton.icon(
                onPressed: () => setState(() => _isEditing = true),
                icon: const Icon(Icons.edit_outlined, size: 15, color: _gold),
                label: const Text('Modifier',
                    style: TextStyle(color: _gold, fontWeight: FontWeight.w600, fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _gold, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  minimumSize: Size.zero,
                ),
              ),
            ),
          // ── Mode édition : Annuler + Confirmer côte à côte
          if (_isEditing) ...[
            TextButton(
              onPressed: _annuler,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                minimumSize: Size.zero,
              ),
              child: const Text('Annuler',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _sauvegarder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gold,
                  foregroundColor: _navy,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: _isSaving
                    ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(color: _navy, strokeWidth: 2))
                    : const Text('Confirmer ✓',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.parallax,
        background: _buildHeaderBackground(),
      ),
    );
  }

  Widget _buildHeaderBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2460), Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 48), // espace pour la titleBar
            // Avatar
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 106, height: 106,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _gold, width: 3),
                    boxShadow: [BoxShadow(color: _gold.withValues(alpha: 0.35),
                        blurRadius: 18, spreadRadius: 2)],
                  ),
                ),
                Container(
                  width: 100, height: 100,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: _isUploadingPhoto
                      ? const ColoredBox(color: Color(0xFF1E3A8A),
                      child: Center(child: CircularProgressIndicator(
                          color: _gold, strokeWidth: 2)))
                      : _buildAvatar(100),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 4, right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: _gold, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 6)],
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 15, color: _navy),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${_user!.prenom} ${_user!.nom}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold,
                  color: Colors.white, letterSpacing: 0.3),
            ),
            const SizedBox(height: 4),
            Text(_user!.email,
                style: const TextStyle(fontSize: 12, color: Colors.white60)),
            const SizedBox(height: 8),
            if ((_selectedVille ?? _user!.ville).isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: _gold),
                  const SizedBox(width: 4),
                  Text(_selectedVille ?? _user!.ville,
                      style: const TextStyle(fontSize: 12, color: Colors.white,
                          fontWeight: FontWeight.w500)),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  // ── COMPLETION CARD ───────────────────────────────────────────
  Widget _buildCompletionCard() {
    final pct = _profileCompletion;
    final color = pct < 50
        ? Colors.red.shade400
        : pct < 80
        ? Colors.orange
        : const Color(0xFF22C55E);
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [
          _iconBox(Icons.trending_up_rounded, _gold),
          const SizedBox(width: 12),
          const Text('Profil complété',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navy)),
        ]),
        Text('$pct%',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      ]),
      const SizedBox(height: 14),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: pct / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
      ),
      if (pct < 100) ...[
        const SizedBox(height: 8),
        Text(
          pct < 50
              ? 'Complétez votre profil pour maximiser vos chances !'
              : 'Encore quelques infos et votre profil sera parfait 🎯',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
      ],
    ]));
  }

  // ── INFO CARD ─────────────────────────────────────────────────
  Widget _buildInfoCard() {
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Informations personnelles', Icons.person_outline),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: _field(label: 'NOM', ctrl: _nomCtrl, icon: Icons.badge_outlined)),
        const SizedBox(width: 12),
        Expanded(child: _field(label: 'PRÉNOM', ctrl: _prenomCtrl, icon: Icons.person_outline)),
      ]),
      const SizedBox(height: 14),
      _emailRow(),
      const SizedBox(height: 14),
      _field(label: 'TÉLÉPHONE', ctrl: _telCtrl, icon: Icons.phone_outlined,
          keyboard: TextInputType.phone),
      const SizedBox(height: 14),
      _villeField(),
    ]));
  }

  Widget _emailRow() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('EMAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8), letterSpacing: 1.2)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.email_outlined, size: 18, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(child: Text(_user!.email,
              style: const TextStyle(fontSize: 14, color: _navy, fontWeight: FontWeight.w500))),
          if (_isEditing)
            GestureDetector(
              onTap: _showChangeEmailSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _gold.withValues(alpha: 0.4)),
                ),
                child: const Text('Changer',
                    style: TextStyle(fontSize: 12, color: _gold, fontWeight: FontWeight.bold)),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.verified_rounded, size: 12, color: Color(0xFF22C55E)),
                SizedBox(width: 4),
                Text('Vérifié', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E),
                    fontWeight: FontWeight.w600)),
              ]),
            ),
        ]),
      ),
    ]);
  }

  // ── SECURITY CARD ─────────────────────────────────────────────
  Widget _buildSecurityCard() {
    return _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sectionTitle('Sécurité', Icons.shield_outlined),
      const SizedBox(height: 16),
      _securityTile(
        icon: Icons.lock_outline_rounded,
        title: 'Changer le mot de passe',
        subtitle: 'Mettez à jour votre mot de passe régulièrement',
        onTap: _showChangePasswordSheet,
      ),
    ]));
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
        label: const Text('Se déconnecter',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  // ── LOADER / ERROR ────────────────────────────────────────────
  Widget _buildLoader() => const Scaffold(
    backgroundColor: _bg,
    body: Center(child: CircularProgressIndicator(color: _gold, strokeWidth: 3)),
  );

  Widget _buildErrorState() => Scaffold(
    backgroundColor: _bg,
    body: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text('Impossible de charger le profil',
            style: TextStyle(color: _navy, fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _chargerProfil,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(backgroundColor: _navy),
        ),
      ],
    )),
  );

  // ── HELPERS ───────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16, offset: const Offset(0, 6))],
    ),
    child: child,
  );

  Widget _sectionTitle(String t, IconData icon) => Row(children: [
    _iconBox(icon, _navy),
    const SizedBox(width: 12),
    Text(t, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _navy)),
  ]);

  Widget _iconBox(IconData icon, Color color) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 18, color: color),
  );

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8), letterSpacing: 1.2)),
      const SizedBox(height: 8),
      _isEditing
          ? TextField(
        controller: ctrl,
        keyboardType: keyboard,
        style: const TextStyle(fontSize: 14, color: _navy, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
          filled: true, fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _gold, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      )
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 10),
          Expanded(child: Text(
            ctrl.text.isEmpty ? 'Non renseigné' : ctrl.text,
            style: TextStyle(
              fontSize: 14,
              color: ctrl.text.isEmpty ? const Color(0xFF94A3B8) : _navy,
              fontWeight: FontWeight.w500,
            ),
          )),
        ]),
      ),
    ]);
  }

  Widget _villeField() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('VILLE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8), letterSpacing: 1.2)),
      const SizedBox(height: 8),
      _isEditing
          ? DropdownButtonFormField<String>(
        value: _selectedVille,
        hint: const Text('Sélectionner', style: TextStyle(color: Color(0xFF94A3B8))),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.location_on_outlined, size: 18,
              color: Color(0xFF64748B)),
          filled: true, fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _gold, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
        items: _villes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (val) => setState(() => _selectedVille = val),
        isExpanded: true,
      )
          : Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF64748B)),
          const SizedBox(width: 10),
          Text(
            _selectedVille ?? (_user!.ville.isNotEmpty ? _user!.ville : 'Non spécifiée'),
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: (_selectedVille ?? _user!.ville).isNotEmpty
                  ? _navy : const Color(0xFF94A3B8),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _securityTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          _iconBox(icon, _navy),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _navy)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          ])),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
        ]),
      ),
    );
  }

  Widget _buildAvatar(double size) {
    if (_photoUrl != null && _photoUrl!.isNotEmpty) {
      return Image.network(_photoUrl!, fit: BoxFit.cover, width: size, height: size,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildInitials(),
        loadingBuilder: (_, child, p) => p == null ? child
            : const ColoredBox(color: Color(0xFF1E3A8A),
            child: Center(child: CircularProgressIndicator(
                color: _gold, strokeWidth: 2))),
      );
    }
    if (kIsWeb && _imageBytes != null) {
      return Image.memory(_imageBytes!, fit: BoxFit.cover);
    }
    if (!kIsWeb && _imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    }
    return _buildInitials();
  }

  Widget _buildInitials() {
    final i = '${_user!.prenom.isNotEmpty ? _user!.prenom[0] : ''}'
        '${_user!.nom.isNotEmpty ? _user!.nom[0] : ''}'.toUpperCase();
    return ColoredBox(
      color: const Color(0xFF1E3A8A),
      child: Center(child: Text(i,
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold,
              color: _gold, letterSpacing: 2))),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// WIDGET : Changement d'email
// ════════════════════════════════════════════════════════════════
class _EmailChangeSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _EmailChangeSheet({required this.onSuccess});

  @override
  State<_EmailChangeSheet> createState() => _EmailChangeSheetState();
}

class _EmailChangeSheetState extends State<_EmailChangeSheet> {
  final _emailCtrl = TextEditingController();
  final _codeCtrl  = TextEditingController();
  bool _step1 = true;
  bool _loading = false;

  static const _gold = Color(0xFFE8B74B);
  static const _navy = Color(0xFF1A3A5C);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Changer l\'email',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navy)),
              const SizedBox(height: 6),
              Text(
                _step1
                    ? 'Entrez votre nouvel email. Un code sera envoyé.'
                    : 'Entrez le code reçu sur ${_emailCtrl.text}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
              if (_step1) ...[
                _inputField(_emailCtrl, 'Nouvel email', Icons.email_outlined,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _submitBtn('Envoyer le code', _step1Done),
              ] else ...[
                _inputField(_codeCtrl, 'Code à 6 chiffres', Icons.pin_outlined,
                    keyboard: TextInputType.number),
                const SizedBox(height: 20),
                _submitBtn('Confirmer', _step2Done),
                const SizedBox(height: 8),
                Center(child: TextButton(
                  onPressed: () => setState(() { _step1 = true; _codeCtrl.clear(); }),
                  child: const Text('← Changer l\'email saisi',
                      style: TextStyle(color: _navy)),
                )),
              ],
              const SizedBox(height: 8),
            ]),
      ),
    );
  }

  Future<void> _step1Done() async {
    final email = _emailCtrl.text.trim();
    if (!RegExp(r'^[\w.\-]+@[\w.\-]+\.\w+$').hasMatch(email)) {
      _snack('Email invalide'); return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.sendEmailChangeCode(email);
      if (mounted) setState(() { _loading = false; _step1 = false; });
    } catch (e) {
      if (mounted) { setState(() => _loading = false); _snack('Erreur: $e'); }
    }
  }

  Future<void> _step2Done() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    try {
      await AuthService.confirmEmailChange(
        nouvelEmail: _emailCtrl.text.trim(),
        code: _codeCtrl.text.trim(),
      );
      if (mounted) { Navigator.pop(context); widget.onSuccess(); }
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _snack('Code invalide ou expiré');
      }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  Widget _inputField(TextEditingController ctrl, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: ctrl, keyboardType: keyboard,
      style: const TextStyle(color: _navy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 18),
        filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _gold, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _submitBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity, height: 50,
    child: ElevatedButton(
      onPressed: _loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: _navy,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: _loading
          ? const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
              color: Colors.white)),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
// WIDGET : Changement de mot de passe
// ════════════════════════════════════════════════════════════════
class _PasswordChangeSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  const _PasswordChangeSheet({required this.onSuccess});

  @override
  State<_PasswordChangeSheet> createState() => _PasswordChangeSheetState();
}

class _PasswordChangeSheetState extends State<_PasswordChangeSheet> {
  final _ancienCtrl  = TextEditingController();
  final _nouveauCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obsA = true, _obsN = true, _obsC = true;
  bool _loading = false;

  static const _gold = Color(0xFFE8B74B);
  static const _navy = Color(0xFF1A3A5C);

  @override
  void dispose() {
    _ancienCtrl.dispose();
    _nouveauCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Changer le mot de passe',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _navy)),
              const SizedBox(height: 20),
              _pwdField(_ancienCtrl, 'Ancien mot de passe', _obsA,
                      (v) => setState(() => _obsA = v)),
              const SizedBox(height: 12),
              _pwdField(_nouveauCtrl, 'Nouveau mot de passe', _obsN,
                      (v) => setState(() => _obsN = v)),
              const SizedBox(height: 12),
              _pwdField(_confirmCtrl, 'Confirmer le mot de passe', _obsC,
                      (v) => setState(() => _obsC = v)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _navy,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirmer',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 16),
            ]),
      ),
    );
  }

  Future<void> _submit() async {
    if (_ancienCtrl.text.isEmpty || _nouveauCtrl.text.isEmpty || _confirmCtrl.text.isEmpty) {
      _snack('Tous les champs sont obligatoires'); return;
    }
    if (_nouveauCtrl.text != _confirmCtrl.text) {
      _snack('Les mots de passe ne correspondent pas'); return;
    }
    if (_nouveauCtrl.text.length < 6) {
      _snack('Minimum 6 caractères'); return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.changePassword(
        ancienMotDePasse: _ancienCtrl.text,
        nouveauMotDePasse: _nouveauCtrl.text,
      );
      if (mounted) { Navigator.pop(context); widget.onSuccess(); }
    } catch (e) {
      final msg = e.toString().contains('400')
          ? 'Ancien mot de passe incorrect'
          : e.toString().contains('401')
          ? 'Session expirée'
          : 'Erreur serveur';
      if (mounted) { setState(() => _loading = false); _snack(msg); }
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  Widget _pwdField(TextEditingController ctrl, String label,
      bool obs, ValueChanged<bool> onToggle) {
    return TextField(
      controller: ctrl, obscureText: obs,
      style: const TextStyle(color: _navy),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B), size: 18),
        suffixIcon: IconButton(
          icon: Icon(obs ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              size: 18, color: const Color(0xFF94A3B8)),
          onPressed: () => onToggle(!obs),
        ),
        filled: true, fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _gold, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}