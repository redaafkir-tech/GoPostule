// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/offre_service.dart';
import '../../../shared/user_model.dart';
import '../../../shared/offre.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  UserModel? _user;
  List<Offre> _offres = [];
  List<int> _offresPostulees = [];
  List<int> _offresSauvegardees = [];
  bool _loading = true;

  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final userMap = await AuthService.getMe();
      final offres = await OffreService().getAllOffres();
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('saved_offres') ?? [];
      final sauvegardees = savedIds.map((id) => int.tryParse(id) ?? 0).toList();

      if (!mounted) return;
      setState(() {
        _user = UserModel(
          id: userMap['Id'] ?? userMap['id'] ?? 0,
          nom: userMap['Nom'] ?? userMap['nom'] ?? '',
          prenom: userMap['Prenom'] ?? userMap['prenom'] ?? '',
          email: userMap['Email'] ?? userMap['email'] ?? '',
          ville: userMap['Ville'] ?? userMap['ville'] ?? '',
          telephone: userMap['Telephone'] ?? userMap['telephone'] ?? '',
          photoUrl: userMap['PhotoUrl'] ?? userMap['photoUrl'],
        );
        _offres = offres;
        _offresSauvegardees = sauvegardees;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleSaveOffre(int offreId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('saved_offres') ?? [];
    if (saved.contains(offreId.toString())) {
      saved.remove(offreId.toString());
      setState(() => _offresSauvegardees.remove(offreId));
    } else {
      saved.add(offreId.toString());
      if (!_offresSauvegardees.contains(offreId)) {
        setState(() => _offresSauvegardees.add(offreId));
      }
    }
    await prefs.setStringList('saved_offres', saved);
  }

  List<Offre> _getOffresRecommandees() {
    final userVille = _user?.ville?.toLowerCase() ?? '';
    final userNom = _user?.nom?.toLowerCase() ?? '';

    final filtered = _offres.where((offre) {
      if (_offresPostulees.contains(offre.id)) return false;
      int score = 0;
      if (offre.localisation.toLowerCase().contains(userVille)) score += 3;
      if (offre.entreprise.toLowerCase().contains(userNom)) score += 2;
      if (offre.secteur.toLowerCase().contains('développement') ||
          offre.secteur.toLowerCase().contains('it') ||
          offre.secteur.toLowerCase().contains('informatique')) {
        score += 1;
      }
      return score > 0;
    }).toList();

    // ✅ CORRECTION 1 : Tri par date sécurisé (gestion des valeurs null)
    filtered.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(0); // Utilise une date très ancienne si null
      final dateB = b.createdAt ?? DateTime(0);
      return dateB.compareTo(dateA); // Plus récentes d'abord
    });

    return filtered.take(3).toList();
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ✅ CORRECTION 2 : Couleur texte noir (textDark) pour lisibilité
                  const Text(
                    'Notifications',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Toutes les notifications ont été marquées comme lues'),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    // ✅ CORRECTION 2 : Couleur texte noir
                    child: const Text(
                      'Tout marquer comme lu',
                      style: TextStyle(color: AppColors.textDark),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _NotificationItem(
                    title: 'Nouvelle offre correspondante',
                    subtitle: 'Développeur Full Stack chez Maroc Telecom',
                    time: 'Il y a 2 heures',
                    unread: true,
                    icon: Icons.work_outline,
                  ),
                  _NotificationItem(
                    title: 'Candidature vue',
                    subtitle: 'Votre candidature pour Data Analyst a été consultée',
                    time: 'Il y a 5 heures',
                    unread: true,
                    icon: Icons.visibility_outlined,
                  ),
                  _NotificationItem(
                    title: 'Entretien programmé',
                    subtitle: 'Votre entretien est prévu le 15 mai à 10h00',
                    time: 'Hier',
                    unread: false,
                    icon: Icons.event_outlined,
                  ),
                  _NotificationItem(
                    title: 'Offre expirée',
                    subtitle: 'L\'offre Ingénieur Réseau n\'est plus disponible',
                    time: 'Il y a 2 jours',
                    unread: false,
                    icon: Icons.access_time,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ CORRECTION 3 : Navigation sans arguments inutiles
  void _navigateToSearch() {
    Navigator.pushNamed(context, '/offres');
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildStatsSection()),
            SliverToBoxAdapter(child: _buildOffresSection()),
            const SliverToBoxAdapter(child: SizedBox(height: 90)), // Espace pour la BottomNavBar
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final prenom = _user?.prenom ?? 'Utilisateur';
    final nom = _user?.nom ?? '';
    final photoUrl = _user?.photoUrl;
    final fullName = '$prenom $nom';
    final initiale = prenom.isNotEmpty ? prenom[0].toUpperCase() : 'U';

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F2460), Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 50, height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.accent, width: 2),
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, Color(0xFFF5D08A)],
                      ),
                    ),
                    child: ClipOval(
                      child: photoUrl != null && photoUrl.isNotEmpty
                          ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppColors.accent.withOpacity(0.3),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                    : null,
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Text(
                              initiale,
                              style: const TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          );
                        },
                      )
                          : Center(
                        child: Text(
                          initiale,
                          style: const TextStyle(
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bonjour ',
                      style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      fullName,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Découvrez les meilleures opportunités',
                      style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _showNotifications,
                child: Stack(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textLight.withOpacity(0.15),
                      ),
                      child: const Icon(Icons.notifications_outlined,
                          color: AppColors.textLight, size: 20),
                    ),
                    Positioned(
                      top: 7, right: 7,
                      child: Container(
                        width: 9, height: 9,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF1E40AF), width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: GestureDetector(
        onTap: _navigateToSearch,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search, color: AppColors.textGrey, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Rechercher un poste, entreprise…',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ),
              Icon(Icons.tune, color: AppColors.textDark.withOpacity(0.6), size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vue d\'ensemble',
            style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.35,
            ),
            itemCount: 4,
            itemBuilder: (_, i) => _buildStatCard(i),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(int index) {
    final stats = [
      {
        'label': 'Candidatures', 'value': '12', 'badge': '+2 ce mois',
        'icon': Icons.send_rounded,
        'gradient': [AppColors.textDark, AppColors.info],
      },
      {
        'label': 'Offres vues', 'value': '48', 'badge': 'Actif',
        'icon': Icons.remove_red_eye_outlined,
        'gradient': [const Color(0xFF0F2460), const Color(0xFF3B82F6)],
      },
      {
        'label': 'Entretiens', 'value': '5', 'badge': '2 à venir',
        'icon': Icons.check_circle_outline,
        'gradient': [const Color(0xFF065F46), const Color(0xFF10B981)],
      },
      {
        'label': 'Sauvegardées',
        'value': '${_offresSauvegardees.length}',
        'badge': 'Favoris',
        'icon': Icons.star_border_rounded,
        'gradient': [const Color(0xFF78350F), AppColors.accent],
      },
    ];
    final stat = stats[index];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: stat['gradient'] as List<Color>,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat['icon'] as IconData, color: Colors.white, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stat['value'] as String,
                style: const TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800),
              ),
              Text(
                stat['label'] as String,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.65), fontSize: 11),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  stat['badge'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOffresSection() {
    final offresRecommandees = _getOffresRecommandees();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Offres recommandées',
                style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/offres'),
                child: const Text(
                  'Voir tout →',
                  style: TextStyle(
                      color: AppColors.info, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (offresRecommandees.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Aucune offre correspondante',
                  style: TextStyle(color: AppColors.textGrey),
                ),
              ),
            )
          else
            ...offresRecommandees.map(
                  (o) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HomeOffreCard(
                  offre: o,
                  isSaved: _offresSauvegardees.contains(o.id),
                  onSaveToggle: _toggleSaveOffre,
                  onTap: () => Navigator.pushNamed(context, '/offres'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGET NOTIFICATION
// ══════════════════════════════════════════════════════════════
class _NotificationItem extends StatelessWidget {
  final String title, subtitle, time;
  final bool unread;
  final IconData icon;

  const _NotificationItem({
    required this.title, required this.subtitle, required this.time,
    required this.unread, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unread ? const Color(0xFFEFF6FF) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: unread
              ? AppColors.info.withOpacity(0.2)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: unread
                  ? AppColors.info.withOpacity(0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: unread ? AppColors.info : AppColors.textGrey, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: AppColors.textGrey),
                ),
              ],
            ),
          ),
          if (unread)
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.info, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGET OFFRE CARD
// ══════════════════════════════════════════════════════════════
class _HomeOffreCard extends StatelessWidget {
  final Offre offre;
  final VoidCallback onTap;
  final bool isSaved;
  final Function(int) onSaveToggle;

  const _HomeOffreCard({
    required this.offre, required this.onTap,
    required this.isSaved, required this.onSaveToggle,
  });

  @override
  Widget build(BuildContext context) {
    final titre = offre.titre;
    final entreprise = offre.entreprise;
    final localisation = offre.localisation;
    final typeContrat = offre.typeContrat;
    final salaire = offre.salaire;
    final initiale = entreprise.isNotEmpty ? entreprise[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16, offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46, height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F2460), Color(0xFF1E40AF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      initiale,
                      style: const TextStyle(
                          color: AppColors.accent, fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titre,
                        style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entreprise,
                        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        children: [
                          if (localisation.isNotEmpty)
                            _Tag(text: ' $localisation',
                                bg: const Color(0xFFEFF6FF), tc: const Color(0xFF1D4ED8)),
                          if (salaire != null && salaire.isNotEmpty)
                            _Tag(text: salaire,
                                bg: const Color(0xFFF0FDF4), tc: const Color(0xFF166534)),
                          _Tag(text: typeContrat,
                              bg: const Color(0xFFFEF3C7), tc: const Color(0xFF92400E)),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onSaveToggle(offre.id),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isSaved ? const Color(0xFFFEF3C7) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                      color: isSaved ? AppColors.accent : AppColors.textGrey,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color bg, tc;
  const _Tag({required this.text, required this.bg, required this.tc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tc)),
    );
  }
}