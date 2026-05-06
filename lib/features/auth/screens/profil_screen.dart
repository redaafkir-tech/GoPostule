import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/user_model.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // Mode édition actif ou non
  bool _isEditing = false;
  bool _isLoading = false;

  // Données fictives — remplacées par GET /auth/me en Phase 2
  UserModel _user = const UserModel(
    id: 1,
    nom: 'Alami',
    prenom: 'Ahmed',
    email: 'ahmed.alami@email.com',
    ville: 'Casablanca',
    photoUrl: null,
  );

  // Controllers pour les champs éditables
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _villeController;

  // Liste des villes du Maroc pour le dropdown
  final List<String> _villes = [
    'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Kénitra', 'Tétouan',
    'Safi', 'Salé', 'Beni Mellal', 'Nador', 'Khouribga',
    'El Jadida', 'Settat', 'Taza', 'Essaouira', 'Khemisset',
    'Guelmim', 'Laâyoune', 'Dakhla', 'Ouarzazate', 'Chefchaouen',
    'Larache', 'Berkane', 'Mohammedia', 'Khénifra',
  ];

  String? _selectedVille;

  @override
  void initState() {
    super.initState();
    // Initialise les controllers avec les données actuelles
    _nomController    = TextEditingController(text: _user.nom);
    _prenomController = TextEditingController(text: _user.prenom);
    _emailController  = TextEditingController(text: _user.email);
    _villeController  = TextEditingController(text: _user.ville);
    _selectedVille    = _user.ville;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _villeController.dispose();
    super.dispose();
  }

  // Annuler les modifications — remet les valeurs originales
  void _annulerEdition() {
    setState(() {
      _isEditing = false;
      _nomController.text    = _user.nom;
      _prenomController.text = _user.prenom;
      _emailController.text  = _user.email;
      _selectedVille         = _user.ville;
    });
  }

  // Sauvegarder les modifications
  Future<void> _sauvegarder() async {
    setState(() => _isLoading = true);

    // TODO Phase 2 : PUT /auth/me avec les nouvelles infos
    await Future.delayed(const Duration(seconds: 1));

    // Met à jour le user local
    setState(() {
      _user = _user.copyWith(
        nom:    _nomController.text.trim(),
        prenom: _prenomController.text.trim(),
        email:  _emailController.text.trim(),
        ville:  _selectedVille,
      );
      _isEditing = false;
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil mis à jour'),
          backgroundColor: AppColors.statusOffer,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  // Dialogue de confirmation déconnexion
  void _confirmerDeconnexion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // TODO Phase 2 : supprimer le token JWT
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          // Bouton éditer / sauvegarder dans l'AppBar
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Modifier',
            )
          else ...[
            // Annuler
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _annulerEdition,
              tooltip: 'Annuler',
            ),
            // Sauvegarder
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(Icons.check),
              onPressed: _isLoading ? null : _sauvegarder,
              tooltip: 'Sauvegarder',
            ),
          ],
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header bleu foncé avec photo + nom
            _buildHeader(),

            const SizedBox(height: 24),

            // Infos éditables
            _buildInfosSection(),

            const SizedBox(height: 24),

            // Bouton déconnexion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: OutlinedButton.icon(
                onPressed: _confirmerDeconnexion,
                icon: const Icon(Icons.logout_rounded,
                    color: AppColors.statusRejected),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: AppColors.statusRejected),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: AppColors.statusRejected),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Header avec photo de profil + nom complet
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Photo de profil
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accent,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: _user.photoUrl != null
                    ? ClipOval(
                  child: Image.network(
                    _user.photoUrl!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Center(
                  // Initiales si pas de photo
                  child: Text(
                    '${_user.prenom[0]}${_user.nom[0]}'.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),

              // Bouton changer photo — visible seulement en mode édition
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      // TODO Phase 2 : ouvrir galerie et uploader photo
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upload photo — disponible en Phase 2'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // Nom complet
          Text(
            '${_user.prenom} ${_user.nom}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 4),

          // Ville avec icône
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: Colors.white60),
              const SizedBox(width: 4),
              Text(
                _user.ville,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white60,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Section des champs d'information
  Widget _buildInfosSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informations personnelles',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),

          const SizedBox(height: 20),

          // Nom + Prénom côte à côte
          Row(
            children: [
              Expanded(
                child: _buildChamp(
                  label: 'Nom',
                  controller: _nomController,
                  icon: Icons.person_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChamp(
                  label: 'Prénom',
                  controller: _prenomController,
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Email
          _buildChamp(
            label: 'Email',
            controller: _emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 16),

          // Ville — dropdown en mode édition, texte en mode lecture
          _buildVilleField(),
        ],
      ),
    );
  }

  // Champ générique — affiche texte ou TextField selon _isEditing
  Widget _buildChamp({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        if (_isEditing)
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 18, color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          )
        else
        // Mode lecture — affiche juste la valeur
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Text(
                  controller.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Champ ville avec dropdown
  Widget _buildVilleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ville',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        if (_isEditing)
          DropdownButtonFormField<String>(
            value: _selectedVille,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_outlined,
                  size: 18, color: AppColors.textGrey),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                    color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
            items: _villes
                .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                .toList(),
            onChanged: (val) => setState(() => _selectedVille = val),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Text(
                  _selectedVille ?? _user.ville,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}