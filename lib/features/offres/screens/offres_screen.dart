// lib/features/offres/screens/offres_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/offre_service.dart';
import '../../../core/services/candidature_service.dart';
import '../../../shared/offre.dart';
import '../widgets/offre_card.dart';
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
  bool _isLoading = true;
  String? _error;
  bool _showFilters = false;

  String? _selectedSecteur;
  String? _selectedVille;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<String> _secteurs = [
    'Tous', 'Développement', 'Infrastructure', 'Finance',
    'Ressources Humaines', 'Juridique', 'Commercial', 'Logistique',
    'Comptabilité', 'Audit', 'Communication', 'Data & IA',
    'Cybersécurité', 'Cloud & DevOps', 'Enseignement',
    'BTP & Génie Civil', 'Agriculture', 'Tourisme',
  ];

  final List<String> _villes = [
    'Toutes', 'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger',
    'Agadir', 'Meknès', 'Oujda', 'Kénitra', 'Tétouan', 'Safi',
    'Salé', 'Beni Mellal', 'Nador', 'Khouribga', 'El Jadida',
    'Berrechid', 'Settat', 'Taza', 'Al Hoceïma', 'Essaouira',
    'Khemisset', 'Guelmim', 'Laâyoune', 'Dakhla', 'Ouarzazate',
    'Taroudant', 'Tiznit', 'Errachidia', 'Figuig', 'Chefchaouen',
    'Asilah', 'Larache', 'Youssoufia', 'Sidi Kacem', 'Sidi Ifni',
    'Tan-Tan', 'Berkane', 'Mohammedia', 'Khénifra', 'Boujdour',
    'Fquih Ben Salah', 'El Kelaâ des Sraghna',
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _loadOffres();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _toggleFilters() {
    setState(() => _showFilters = !_showFilters);
    if (_showFilters) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedSecteur = null;
      _selectedVille = null;
    });
  }

  bool get _hasActiveFilters =>
      _selectedSecteur != null || _selectedVille != null;

  Future<void> _loadOffres() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _offreService.getAllOffres(),
        _candidatureService.getMesCandidatures(),
      ]);

      final offres = results[0] as List<Offre>;
      final candidatures = results[1] as List<dynamic>;

      final offresPostulees = candidatures
          .map((c) => c['Offre']['Id'] as int)
          .toList();

      setState(() {
        _offres = offres;
        _offresPostulees = offresPostulees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Offre> get _offresFiltrees {
    return _offres.where((offre) {
      if (_offresPostulees.contains(offre.id)) return false;
      final query = _searchController.text.toLowerCase();
      final matchSearch = query.isEmpty ||
          offre.titre.toLowerCase().contains(query) ||
          offre.entreprise.toLowerCase().contains(query);
      final matchSecteur = _selectedSecteur == null ||
          offre.secteur == _selectedSecteur;
      final matchVille = _selectedVille == null ||
          offre.localisation == _selectedVille;
      return matchSearch && matchSecteur && matchVille;
    }).toList();
  }

  void _navigateToPostuler(Offre offre) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostulerScreen(offre: offre),
      ),
    ).then((_) => _loadOffres());
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  void _showOffreDetail(BuildContext context, Offre offre) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              offre.entreprise.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(offre.titre,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textDark)),
                              const SizedBox(height: 4),
                              Text(offre.entreprise,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag(Icons.work_outline, offre.secteur,
                            AppColors.accent, AppColors.primary),
                        _buildTag(Icons.business_center_outlined,
                            offre.typeContrat,
                            const Color(0xFFE8F0FE),
                            const Color(0xFF185FA5)),
                        _buildTag(Icons.location_on_outlined, offre.localisation,
                            const Color(0xFFE8F5E9),
                            const Color(0xFF2E7D32)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (offre.dateLimite != null)
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 14, color: AppColors.textGrey),
                          const SizedBox(width: 6),
                          Text('Date limite : ${offre.dateLimite}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 24),
                    const Text('Description du poste',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    Text(offre.description,
                        style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textGrey,
                            height: 1.7)),
                    if (offre.missions != null) ...[
                      const SizedBox(height: 20),
                      const Text('Missions',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Text(offre.missions!,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                              height: 1.7)),
                    ],
                    if (offre.competences != null) ...[
                      const SizedBox(height: 20),
                      const Text('Compétences requises',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark)),
                      const SizedBox(height: 12),
                      Text(offre.competences!,
                          style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGrey,
                              height: 1.7)),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Fermer'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            // ✅ CORRECTION ICI : onPressed (pas oonPressed)
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToPostuler(offre);
                            },
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Postuler'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
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

  Widget _buildTag(IconData icon, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor)),
        ],
      ),
    );
  }

  Widget _buildFilterPanel() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizeTransition(
        sizeFactor: _fadeAnimation,
        axisAlignment: -1,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filtres',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (_hasActiveFilters)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh_rounded,
                          size: 16, color: AppColors.primary),
                      label: const Text(
                        'Réinitialiser',
                        style: TextStyle(
                            fontSize: 12, color: AppColors.primary),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDropdown(
                label: 'Secteur',
                icon: Icons.work_outline,
                value: _selectedSecteur,
                items: _secteurs.where((s) => s != 'Tous').toList(),
                onChanged: (val) =>
                    setState(() => _selectedSecteur = val),
                hint: 'Tous les secteurs',
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                label: 'Ville',
                icon: Icons.location_on_outlined,
                value: _selectedVille,
                items: _villes.where((v) => v != 'Toutes').toList(),
                onChanged: (val) =>
                    setState(() => _selectedVille = val),
                hint: 'Toutes les villes',
              ),
              if (_hasActiveFilters) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    if (_selectedSecteur != null)
                      _buildActiveBadge(
                          _selectedSecteur!,
                              () => setState(
                                  () => _selectedSecteur = null)),
                    if (_selectedVille != null)
                      _buildActiveBadge(_selectedVille!,
                              () => setState(() => _selectedVille = null)),
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
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: value != null
                  ? AppColors.primary
                  : const Color(0xFFE8E8E8),
              width: value != null ? 1.5 : 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Row(
                children: [
                  Icon(icon, size: 16, color: AppColors.textGrey),
                  const SizedBox(width: 8),
                  Text(hint,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey)),
                ],
              ),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textGrey, size: 20),
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textDark),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(12),
              items: items
                  .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveBadge(String label, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.primary),
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
        title: const Text('Offres'),
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: _toggleFilters,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _showFilters
                        ? Icons.filter_list_off_rounded
                        : Icons.filter_list_rounded,
                    key: ValueKey(_showFilters),
                    color: _hasActiveFilters
                        ? AppColors.accent
                        : Colors.white,
                  ),
                ),
              ),
              if (_hasActiveFilters)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(
                    color: AppColors.textDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Rechercher un poste, entreprise...',
                  hintStyle: const TextStyle(
                      color: AppColors.textGrey, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textGrey, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        size: 18, color: AppColors.textGrey),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {});
                    },
                  )
                      : null,
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadOffres,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildFilterPanel(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    '${_offresFiltrees.length} offre(s) trouvée(s)',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textGrey,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_hasActiveFilters) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Filtré',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur: $_error',
                        style: const TextStyle(
                            color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadOffres,
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              )
                  : _offresFiltrees.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      _hasActiveFilters
                          ? Icons.filter_list_off_rounded
                          : Icons.search_off,
                      size: 64,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _hasActiveFilters
                          ? 'Aucune offre pour ces filtres'
                          : 'Aucune offre disponible',
                      style: const TextStyle(
                          color: AppColors.textGrey),
                    ),
                    if (_hasActiveFilters) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text(
                            'Réinitialiser les filtres'),
                      ),
                    ],
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _offresFiltrees.length,
                itemBuilder: (context, index) {
                  final offre = _offresFiltrees[index];
                  return OffreCard(
                    offre: offre,
                    onTap: () =>
                        _showOffreDetail(context, offre),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}