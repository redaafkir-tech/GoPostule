import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/offre.dart';
import '../widgets/offre_card.dart';

class OffresScreen extends StatefulWidget {
  const OffresScreen({super.key});

  @override
  State<OffresScreen> createState() => _OffresScreenState();
}

class _OffresScreenState extends State<OffresScreen> {
  final _searchController = TextEditingController();

  String? _selectedSecteur;
  String? _selectedNiveau;
  String? _selectedVille;

  final List<String> _secteurs = [
    'Tous', 'Développement', 'Infrastructure', 'Finance',
    'Ressources Humaines', 'Juridique', 'Commercial', 'Logistique',
    'Comptabilité', 'Audit', 'Communication', 'Data & IA',
    'Cybersécurité', 'Cloud & DevOps', 'Enseignement',
    'BTP & Génie Civil', 'Agriculture', 'Tourisme',
  ];

  final List<String> _niveaux = [
    'Tous', 'Bac+2', 'Bac+3', 'Bac+4', 'Bac+5',
    'Ingénieur d\'état', 'Master', 'Doctorat', 'MBA',
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

  final List<Offre> _offres = [
    Offre(
      id: 1,
      titre: 'Développeur Flutter',
      entreprise: 'TechCorp',
      ville: 'Casablanca',
      secteur: 'Développement',
      niveau: 'Bac+5',
      description: 'Nous recherchons un développeur Flutter passionné pour rejoindre notre équipe mobile. Vous serez responsable du développement et de la maintenance d\'applications cross-platform performantes.',
      datePublication: DateTime(2025, 4, 1),
    ),
    Offre(
      id: 2,
      titre: 'Analyste Financier',
      entreprise: 'BanqueMaroc SA',
      ville: 'Rabat',
      secteur: 'Finance',
      niveau: 'Bac+3',
      description: 'Poste d\'analyste financier au sein de notre département finances. Vous aurez en charge l\'analyse des marchés, la préparation des rapports financiers et le suivi des indicateurs de performance.',
      datePublication: DateTime(2025, 4, 10),
    ),
    Offre(
      id: 3,
      titre: 'Ingénieur Réseau & Sécurité',
      entreprise: 'NetSolutions',
      ville: 'Tanger',
      secteur: 'Infrastructure',
      niveau: 'Ingénieur d\'état',
      description: 'Rejoignez notre équipe infrastructure pour gérer et sécuriser nos réseaux d\'entreprise. Vous interviendrez sur la configuration des équipements réseau, la mise en place de politiques de sécurité et la supervision des systèmes.',
      datePublication: DateTime(2025, 4, 15),
    ),
    Offre(
      id: 4,
      titre: 'Développeur .NET Senior',
      entreprise: 'SoftHouse',
      ville: 'Casablanca',
      secteur: 'Développement',
      niveau: 'Bac+5',
      description: 'Nous cherchons un développeur .NET expérimenté pour renforcer notre équipe backend. Vous concevrez et développerez des APIs RESTful robustes, intégrerez des bases de données SQL Server et participerez à l\'architecture des solutions.',
      datePublication: DateTime(2025, 4, 18),
    ),
  ];

  List<Offre> get _offresFiltrees {
    return _offres.where((offre) {
      final query = _searchController.text.toLowerCase();
      final matchSearch = query.isEmpty ||
          offre.titre.toLowerCase().contains(query) ||
          offre.entreprise.toLowerCase().contains(query);

      final matchSecteur = _selectedSecteur == null ||
          offre.secteur == _selectedSecteur;

      final matchNiveau = _selectedNiveau == null ||
          offre.niveau == _selectedNiveau;

      final matchVille = _selectedVille == null ||
          offre.ville == _selectedVille;

      return matchSearch && matchSecteur && matchNiveau && matchVille;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Popup détail offre — description complète + bouton postuler
  void _showOffreDetail(BuildContext context, Offre offre) {
    showModalBottomSheet(
      context: context,
      // isScrollControlled = le bottom sheet peut prendre plus de 50% de l'écran
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        // initialChildSize = taille initiale (75% de l'écran)
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
              // Handle — la petite barre grise en haut du bottom sheet
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
                    // En-tête : logo entreprise + titre
                    Row(
                      children: [
                        // Logo entreprise — cercle avec initiales
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              // Prend les 2 premières lettres de l'entreprise
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
                              Text(
                                offre.titre,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                offre.entreprise,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Tags : secteur, niveau, ville
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag(Icons.work_outline, offre.secteur, AppColors.accent, AppColors.primary),
                        _buildTag(Icons.school_outlined, offre.niveau, const Color(0xFFE8F0FE), const Color(0xFF185FA5)),
                        _buildTag(Icons.location_on_outlined, offre.ville, const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Date
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textGrey),
                        const SizedBox(width: 6),
                        Text(
                          'Publié le ${offre.datePublication.day}/${offre.datePublication.month}/${offre.datePublication.year}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Divider(height: 1, color: Color(0xFFF0F0F0)),

                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'Description du poste',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      offre.description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        height: 1.7, // Interligne pour meilleure lisibilité
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Boutons Fermer + Postuler
                    Row(
                      children: [
                        // Bouton Fermer
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              foregroundColor: AppColors.primary,
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Fermer'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Bouton Postuler
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              // Snackbar confirmation
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Candidature envoyée pour ${offre.titre}',
                                  ),
                                  backgroundColor: AppColors.primary,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            // Icon avion en papier
                            icon: const Icon(Icons.send_rounded, size: 18),
                            label: const Text('Postuler'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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

  // Helper — construit un tag avec icône + texte
  Widget _buildTag(IconData icon, String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(
      String label,
      List<String> options,
      String? selected,
      Function(String?) onSelect,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
              letterSpacing: 0.8,
            ),
          ),
        ),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: options.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = selected == option ||
                  ((option == 'Tous' || option == 'Toutes') &&
                      selected == null);

              return GestureDetector(
                onTap: () => onSelect(
                  (option == 'Tous' || option == 'Toutes') ? null : option,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.accent : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : const Color(0xFFE8E8E8),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textGrey,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Offres'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(160),
          child: Container(
            color: AppColors.primary,
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                        color: AppColors.textDark,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Rechercher un poste, entreprise...',
                        hintStyle: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textGrey,
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textGrey),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                            : Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 18,
                          ),
                        ),
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

                // Filtre secteur dans l'AppBar
                _buildFilterRow(
                  'Secteur',
                  _secteurs,
                  _selectedSecteur,
                      (val) => setState(() => _selectedSecteur = val),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          _buildFilterRow(
            'Niveau',
            _niveaux,
            _selectedNiveau,
                (val) => setState(() => _selectedNiveau = val),
          ),

          const SizedBox(height: 8),

          _buildFilterRow(
            'Ville',
            _villes,
            _selectedVille,
                (val) => setState(() => _selectedVille = val),
          ),

          const SizedBox(height: 12),

          // Compteur résultats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${_offresFiltrees.length} offre(s) trouvée(s)',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Liste des offres
          Expanded(
            child: _offresFiltrees.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off,
                      size: 64, color: AppColors.textGrey),
                  SizedBox(height: 16),
                  Text(
                    'Aucune offre trouvée',
                    style: TextStyle(color: AppColors.textGrey),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: _offresFiltrees.length,
              itemBuilder: (context, index) {
                final offre = _offresFiltrees[index];
                return OffreCard(
                  offre: offre,
                  onTap: () => _showOffreDetail(context, offre),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}