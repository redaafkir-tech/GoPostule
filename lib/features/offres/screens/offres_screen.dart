// lib/features/offres/screens/offres_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/offre_service.dart';
import '../../../core/services/candidature_service.dart';
import '../../../shared/offre.dart';
import '../../candidatures/screens/postuler_screen.dart';

class OffresScreen extends StatefulWidget {
  const OffresScreen({super.key});

  @override
  State<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends State<OffresScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _offreService = OffreService();
  final _candidatureService = CandidatureService();

  List<Offre> _offres = [];
  List<int> _offresPostulees = [];
  List<int> _offresSauvegardees = [];
  bool _isLoading = true;
  String? _error;
  bool _showFilters = false;
  String? _selectedSecteur;
  String? _selectedVille;

  int? _hoveredOfferIndex; // ✅ Pour hover effect

  late AnimationController _filterController;
  late Animation<double> _filterAnim;

  static const _secteurs = [
    'Développement', 'Infrastructure', 'Finance',
    'Ressources Humaines', 'Juridique', 'Commercial', 'Logistique',
    'Comptabilité', 'Audit', 'Communication', 'Data & IA',
    'Cybersécurité', 'Cloud & DevOps', 'Enseignement',
    'BTP & Génie Civil', 'Agriculture', 'Tourisme',
  ];

  static const _villes = [
    'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Kénitra', 'Tétouan', 'Safi',
    'Salé', 'Beni Mellal', 'Nador', 'Khouribga', 'El Jadida',
    'Berrechid', 'Settat', 'Taza', 'Al Hoceïma', 'Essaouira',
    'Khemisset', 'Guelmim', 'Laâyoune', 'Dakhla', 'Ouarzazate',
    'Taroudant', 'Tiznit', 'Errachidia', 'Mohammedia', 'Chefchaouen',
  ];

  @override
  void initState() {
    super.initState();
    _filterController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 280),
    );
    _filterAnim = CurvedAnimation(
        parent: _filterController, curve: Curves.easeInOut);
    _loadOffres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  Future<void> _loadOffres() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        _offreService.getAllOffres(),
        _candidatureService.getMesCandidatures(),
      ]);
      final offres = results[0] as List<Offre>;
      final candidatures = results[1] as List<dynamic>;
      final postulees = candidatures.map((c) => c['Offre']['Id'] as int).toList();
      final prefs = await SharedPreferences.getInstance();
      final savedIds = prefs.getStringList('saved_offres') ?? [];
      final sauvegardees = savedIds.map((id) => int.tryParse(id) ?? 0).toList();

      if (!mounted) return;
      setState(() {
        _offres = offres;
        _offresPostulees = postulees;
        _offresSauvegardees = sauvegardees;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _isLoading = false; });
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

  List<Offre> get _offresFiltrees {
    return _offres.where((o) {
      if (_offresPostulees.contains(o.id)) return false;
      final q = _searchController.text.toLowerCase();
      final matchSearch = q.isEmpty ||
          o.titre.toLowerCase().contains(q) ||
          o.entreprise.toLowerCase().contains(q);
      final matchSecteur = _selectedSecteur == null || o.secteur == _selectedSecteur;
      final matchVille = _selectedVille == null || o.localisation == _selectedVille;
      return matchSearch && matchSecteur && matchVille;
    }).toList();
  }

  bool get _hasActiveFilters => _selectedSecteur != null || _selectedVille != null;

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    _showFilters ? _filterController.forward() : _filterController.reverse();
  }

  void _resetFilters() =>
      setState(() { _selectedSecteur = null; _selectedVille = null; });

  void _navigateToPostuler(Offre offre) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostulerScreen(offre: offre)),
    ).then((_) => _loadOffres());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildAppBar(),
          _buildFilterPanel(),
          _buildResultsBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF0F2460), Color(0xFF1E40AF), Color(0xFF3B82F6)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 56, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Offres d\'emploi',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 22, fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleFilters,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _hasActiveFilters
                        ? AppColors.accent
                        : AppColors.textLight.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _hasActiveFilters
                          ? AppColors.accent
                          : AppColors.textLight.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _showFilters
                            ? Icons.filter_list_off_rounded
                            : Icons.filter_list_rounded,
                        color: _hasActiveFilters ? AppColors.textDark : AppColors.textLight,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _hasActiveFilters ? 'Filtré' : 'Filtres',
                        style: TextStyle(
                          color: _hasActiveFilters ? AppColors.textDark : AppColors.textLight,
                          fontSize: 13, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(color: AppColors.textDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Rechercher un poste, entreprise...',
                hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 14),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textGrey, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textGrey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return SizeTransition(
      sizeFactor: _filterAnim,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: _filterAnim,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtrer les offres',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (_hasActiveFilters)
                    GestureDetector(
                      onTap: _resetFilters,
                      child: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                            color: AppColors.info, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      label: 'Secteur', icon: Icons.work_outline,
                      value: _selectedSecteur, items: _secteurs,
                      onChanged: (v) => setState(() => _selectedSecteur = v),
                      hint: 'Tous',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildDropdown(
                      label: 'Ville', icon: Icons.location_on_outlined,
                      value: _selectedVille, items: _villes,
                      onChanged: (v) => setState(() => _selectedVille = v),
                      hint: 'Toutes',
                    ),
                  ),
                ],
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedSecteur != null)
                      _ActiveBadge(
                        label: _selectedSecteur!,
                        onRemove: () => setState(() => _selectedSecteur = null),
                      ),
                    if (_selectedVille != null)
                      _ActiveBadge(
                        label: _selectedVille!,
                        onRemove: () => setState(() => _selectedVille = null),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label, required IconData icon, required String? value,
    required List<String> items, required Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.textGrey, letterSpacing: 0.8),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value != null ? AppColors.textDark : const Color(0xFFE2E8F0),
              width: value != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value, isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textGrey, size: 18),
              style: const TextStyle(fontSize: 12, color: AppColors.textDark),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              hint: Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: 6),
                  Text(hint, style: const TextStyle(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 12)),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultsBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          Text(
            '${_offresFiltrees.length} offre(s) trouvée(s)',
            style: const TextStyle(
                fontSize: 13, color: AppColors.textGrey, fontWeight: FontWeight.w500),
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Filtré',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.accent));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Colors.red),
            const SizedBox(height: 12),
            Text('Erreur : $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadOffres,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
    if (_offresFiltrees.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasActiveFilters
                  ? Icons.filter_list_off_rounded
                  : Icons.search_off_rounded,
              size: 56, color: AppColors.textGrey,
            ),
            const SizedBox(height: 12),
            Text(
              _hasActiveFilters
                  ? 'Aucune offre pour ces filtres'
                  : 'Aucune offre disponible',
              style: const TextStyle(color: AppColors.textGrey),
            ),
            if (_hasActiveFilters) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Réinitialiser les filtres'),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOffres,
      color: AppColors.accent,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
        itemCount: _offresFiltrees.length,
        itemBuilder: (context, index) {
          final offre = _offresFiltrees[index];
          final isSaved = _offresSauvegardees.contains(offre.id);
          final isHovered = _hoveredOfferIndex == index;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredOfferIndex = index),
            onExit: (_) => setState(() => _hoveredOfferIndex = null),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              transform: Matrix4.identity()..scale(isHovered ? 1.02 : 1.0),
              child: _OffreCard(
                offre: offre,
                onTap: () => _showOffreDetail(context, offre),
                isSaved: isSaved,
                onSaveToggle: _toggleSaveOffre,
                isHovered: isHovered,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showOffreDetail(BuildContext context, Offre offre) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.78, minChildSize: 0.5, maxChildSize: 0.95,
        builder: (context, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: sc,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F2460), Color(0xFF1E40AF)],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              offre.entreprise.length >= 2
                                  ? offre.entreprise.substring(0, 2).toUpperCase()
                                  : offre.entreprise.toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800,
                                  color: AppColors.accent),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                offre.titre,
                                style: const TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.w800,
                                    color: AppColors.textDark),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                offre.entreprise,
                                style: const TextStyle(fontSize: 13, color: AppColors.textGrey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _SheetTag(
                            icon: Icons.work_outline, label: offre.secteur,
                            bg: const Color(0xFFFEF3C7), tc: const Color(0xFF92400E)),
                        _SheetTag(
                            icon: Icons.business_center_outlined, label: offre.typeContrat,
                            bg: const Color(0xFFE8F0FE), tc: const Color(0xFF185FA5)),
                        _SheetTag(
                            icon: Icons.location_on_outlined, label: offre.localisation,
                            bg: const Color(0xFFE8F5E9), tc: const Color(0xFF2E7D32)),
                        if (offre.salaire != null && offre.salaire!.isNotEmpty)
                          _SheetTag(
                              icon: Icons.attach_money, label: offre.salaire!,
                              bg: const Color(0xFFF0FDF4), tc: const Color(0xFF166534)),
                      ],
                    ),
                    if (offre.dateLimite != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 13, color: AppColors.textGrey),
                          const SizedBox(width: 6),
                          Text(
                            'Date limite : ${offre.dateLimite}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    _SheetSection(
                        title: 'Description du poste', content: offre.description),
                    if (offre.missions != null)
                      _SheetSection(title: 'Missions', content: offre.missions!),
                    if (offre.competences != null)
                      _SheetSection(title: 'Compétences requises', content: offre.competences!),
                    const SizedBox(height: 20),
                    const Divider(height: 1),
                    const SizedBox(height: 20),
                    const Text(
                      'Processus de recrutement',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    const SizedBox(height: 12),
                    _RecruitmentStep(
                        number: 1, title: 'Candidature',
                        description: 'Soumettez votre candidature en ligne',
                        icon: Icons.send_outlined),
                    const SizedBox(height: 12),
                    _RecruitmentStep(
                        number: 2, title: 'Examen du dossier',
                        description: 'Notre équipe RH étudie votre profil',
                        icon: Icons.folder_open_outlined),
                    const SizedBox(height: 12),
                    _RecruitmentStep(
                        number: 3, title: 'Entretien RH',
                        description: 'Entretien avec le responsable RH',
                        icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _RecruitmentStep(
                        number: 4, title: 'Entretien technique',
                        description: 'Test technique avec l\'équipe',
                        icon: Icons.code_outlined),
                    const SizedBox(height: 12),
                    _RecruitmentStep(
                        number: 5, title: 'Réponse',
                        description: 'Réception de la réponse finale',
                        icon: Icons.check_circle_outline),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.textDark),
                              foregroundColor: AppColors.textDark,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Text('Fermer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToPostuler(offre);
                            },
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Postuler'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.textDark,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGET OFFRE CARD AVEC HOVER EFFECT
// ══════════════════════════════════════════════════════════════
class _OffreCard extends StatefulWidget {
  final Offre offre;
  final VoidCallback onTap;
  final bool isSaved;
  final Function(int) onSaveToggle;
  final bool isHovered;

  const _OffreCard({
    required this.offre, required this.onTap,
    required this.isSaved, required this.onSaveToggle,
    required this.isHovered,
  });

  @override
  State<_OffreCard> createState() => _OffreCardState();
}

class _OffreCardState extends State<_OffreCard> {
  @override
  Widget build(BuildContext context) {
    final o = widget.offre;
    final initiale = o.entreprise.isNotEmpty ? o.entreprise[0].toUpperCase() : '?';

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: widget.isHovered
              ? Colors.white
              : const Color(0xFFF8FAFC), // ✅ Couleur différente au hover
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isHovered
                ? AppColors.primary.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            width: widget.isHovered ? 2 : 1,
          ),
          boxShadow: widget.isHovered
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
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
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        o.titre,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: widget.isHovered ? AppColors.primary : AppColors.textDark),
                      ),
                      Text(
                        o.entreprise,
                        style: TextStyle(fontSize: 12, color: AppColors.textGrey),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => widget.onSaveToggle(o.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: widget.isSaved ? const Color(0xFFFEF3C7) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      widget.isSaved
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: widget.isSaved ? AppColors.accent : AppColors.textGrey,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6, runSpacing: 6,
              children: [
                _CardTag(text: '📍 ${o.localisation}',
                    bg: const Color(0xFFEFF6FF), tc: const Color(0xFF1D4ED8)),
                if (o.salaire != null && o.salaire!.isNotEmpty)
                  _CardTag(text: o.salaire!,
                      bg: const Color(0xFFF0FDF4), tc: const Color(0xFF166534)),
                _CardTag(text: o.typeContrat,
                    bg: const Color(0xFFFEF3C7), tc: const Color(0xFF92400E)),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                gradient: widget.isHovered
                    ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.info],
                )
                    : const LinearGradient(
                  colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.isHovered
                    ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'Voir & Postuler',
                    style: TextStyle(
                        color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTag extends StatelessWidget {
  final String text;
  final Color bg, tc;
  const _CardTag({required this.text, required this.bg, required this.tc});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: tc)),
    );
  }
}

class _SheetTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, tc;
  const _SheetTag({
    required this.icon, required this.label,
    required this.bg, required this.tc,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tc),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tc)),
        ],
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  final String title, content;
  const _SheetSection({required this.title, required this.content});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          const SizedBox(height: 8),
          Text(content,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textGrey, height: 1.7)),
        ],
      ),
    );
  }
}

class _RecruitmentStep extends StatelessWidget {
  final int number;
  final String title, description;
  final IconData icon;

  const _RecruitmentStep({
    required this.number, required this.title,
    required this.description, required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800,
                  color: AppColors.accent),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.textGrey),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;
  const _ActiveBadge({required this.label, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textDark.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.textDark.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }
}