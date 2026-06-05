// lib/features/candidatures/screens/candidatures_screen.dart
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/candidature_service.dart';
import '../../../core/services/reclamation_service.dart';

class CandidaturesScreen extends StatefulWidget {
  const CandidaturesScreen({super.key});

  @override
  State<CandidaturesScreen> createState() => _CandidaturesScreenState();
}

class _CandidaturesScreenState extends State<CandidaturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _candidatureService = CandidatureService();
  final _reclamationService = ReclamationService();

  List<dynamic> _candidatures = [];
  bool _isLoading = true;
  String? _error;

  // ✅ Pour hover effect
  int? _hoveredCardIndex;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadCandidatures();

    // Rafraîchir automatiquement quand l'écran devient visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCandidatures();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidatures() async {
    print('🔄 Chargement des candidatures...');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final candidatures = await _candidatureService.getMesCandidatures();

      print('✅ Candidatures reçues: ${candidatures.length}');
      print('   Données: $candidatures');

      if (!mounted) return;

      setState(() {
        _candidatures = candidatures;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Erreur chargement: $e');
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ✅ Filtrer seulement les candidatures réelles
  List<dynamic> get _actives => _candidatures
      .where((c) {
    final phase = c['PhaseActuelle']?.toString().toLowerCase() ?? '';
    return phase != 'admise' && phase != 'rejetee';
  })
      .toList();

  List<dynamic> get _terminees => _candidatures
      .where((c) {
    final phase = c['PhaseActuelle']?.toString().toLowerCase() ?? '';
    return phase == 'admise' || phase == 'rejetee';
  })
      .toList();

  Future<void> _deleteCandidature(int id) async {
    try {
      await _candidatureService.deleteCandidature(id);
      _loadCandidatures();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Candidature supprimée'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
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

  Future<void> _createReclamation(
      int candidatureId, String objet, String message) async {
    try {
      await _reclamationService.createReclamation(
        candidatureId: candidatureId,
        objet: objet,
        message: message,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Réclamation soumise avec succès'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        String message = 'Erreur lors de la réclamation';
        if (e.response?.statusCode == 400) {
          final data = e.response?.data;
          if (data is Map && data['message'] != null) {
            message = data['message'];
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _supprimerCandidature(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la candidature'),
        content: const Text(
          'Cette action est irréversible. Confirmer la suppression ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _deleteCandidature(id);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, dynamic c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              (c['Offre']?['Entreprise'] ?? '??')
                                  .toString()
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['Offre']?['Titre'] ?? 'Offre inconnue',
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              Text(
                                c['Offre']?['Entreprise'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // ✅ TIMELINE DYNAMIQUE DES ÉTAPES
                    _buildRecruitmentTimeline(c),

                    const SizedBox(height: 24),
                    const Divider(height: 1),
                    const SizedBox(height: 20),

                    // Historique
                    if (c['Historique'] != null &&
                        (c['Historique'] as List).isNotEmpty) ...[
                      const Text(
                        'Historique des actions',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...(c['Historique'] as List).map((h) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              h['Phase'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            if (h['Commentaire'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                h['Commentaire'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              h['Date'] ?? '',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ TIMELINE DYNAMIQUE DES ÉTAPES DE RECRUTEMENT
  Widget _buildRecruitmentTimeline(dynamic c) {
    final phase = c['PhaseActuelle']?.toString().toLowerCase() ?? 'soumise';
    final historique = c['Historique'] as List? ?? [];

    // Déterminer le statut de chaque étape
    final etapes = [
      {'key': 'traitement_dossier', 'label': 'Traitement du dossier', 'icon': Icons.folder_open},
      {'key': 'concours_ecrit', 'label': 'Concours écrit', 'icon': Icons.edit_note},
      {'key': 'concours_oral', 'label': 'Concours oral', 'icon': Icons.mic},
      {'key': 'admission', 'label': 'Décision finale', 'icon': Icons.verified},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi du processus',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        ...etapes.asMap().entries.map((entry) {
          final index = entry.key;
          final etape = entry.value;
          final isLast = index == etapes.length - 1;

          // Déterminer le statut de l'étape
          final statut = _getEtapeStatut(etape['key'] as String, phase, historique);

          return _TimelineStep(
            number: index + 1,
            title: etape['label'] as String,
            icon: etape['icon'] as IconData,
            status: statut,
            isLast: isLast,
          );
        }).toList(),
      ],
    );
  }

  // ✅ Détermine le statut d'une étape (validé/en cours/à venir/non validé)
  EtapeStatus _getEtapeStatut(String etapeKey, String phase, List historique) {
    // Map des étapes dans l'ordre
    final ordreEtapes = ['traitement_dossier', 'concours_ecrit', 'concours_oral', 'admission'];
    final currentIndex = ordreEtapes.indexOf(etapeKey);

    // Déterminer la phase actuelle en index
    int phaseIndex = -1;
    if (phase == 'soumise' || phase == 'examen_dossier') phaseIndex = 0;
    else if (phase == 'concours_ecrit_passe' || phase == 'attente_ecrit') phaseIndex = 1;
    else if (phase == 'concours_oral_passe' || phase == 'attente_oral') phaseIndex = 2;
    else if (phase == 'admise') phaseIndex = 3;
    else if (phase == 'rejetee') {
      // Trouver à quelle étape le rejet a eu lieu
      final rejetEtape = historique.lastWhere(
            (h) => h['Phase']?.toString().toLowerCase().contains('rejet') ?? false,
        orElse: () => null,
      );
      if (rejetEtape != null) {
        // Simplification: on considère que le rejet bloque les étapes suivantes
        return EtapeStatus.failed;
      }
    }

    if (currentIndex < phaseIndex) {
      return EtapeStatus.completed; // Étape passée = validée
    } else if (currentIndex == phaseIndex) {
      return phase == 'admise' ? EtapeStatus.completed : EtapeStatus.active; // Étape en cours
    } else {
      return EtapeStatus.pending; // Étape à venir
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mes Candidatures'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.accent,
              indicatorWeight: 3,
              labelColor: AppColors.accent,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: [
                Tab(text: 'En cours (${_actives.length})'),
                Tab(text: 'Terminées (${_terminees.length})'),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : _error != null
          ? _buildErrorWidget()
          : RefreshIndicator(
        onRefresh: _loadCandidatures,
        color: AppColors.accent,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildListe(_actives),
            _buildListe(_terminees),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.danger.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error ?? 'Une erreur est survenue',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadCandidatures,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListe(List<dynamic> liste) {
    if (liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 80,
              color: AppColors.textGrey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune candidature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vos candidatures apparaîtront ici',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: liste.length,
      itemBuilder: (context, index) {
        final c = liste[index];
        final isTerminee = c['PhaseActuelle'] == 'admise' ||
            c['PhaseActuelle'] == 'rejetee';

        // ✅ Hover effect pour web/desktop
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredCardIndex = index),
          onExit: (_) => setState(() => _hoveredCardIndex = null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            transform: Matrix4.identity()
              ..scale(_hoveredCardIndex == index ? 1.02 : 1.0),
            child: _CandidatureCard(
              candidature: c,
              isHovered: _hoveredCardIndex == index,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/application-hub',
                  arguments: c['Id'].toString(),
                );
              },
              onDelete: isTerminee ? () => _supprimerCandidature(c['Id']) : null,
              onShowDetail: () => _showDetail(context, c),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// ENUM POUR LES STATUTS D'ÉTAPE
// ══════════════════════════════════════════════════════════════
enum EtapeStatus {
  pending,    // À venir (gris)
  active,     // En cours (orange/bleu)
  completed,  // Validé (vert)
  failed,     // Non validé (rouge)
}

// ══════════════════════════════════════════════════════════════
// WIDGET TIMELINE STEP
// ══════════════════════════════════════════════════════════════
class _TimelineStep extends StatelessWidget {
  final int number;
  final String title;
  final IconData icon;
  final EtapeStatus status;
  final bool isLast;

  const _TimelineStep({
    required this.number,
    required this.title,
    required this.icon,
    required this.status,
    required this.isLast,
  });

  Color _getStatusColor() {
    switch (status) {
      case EtapeStatus.completed:
        return AppColors.success;
      case EtapeStatus.active:
        return AppColors.accent;
      case EtapeStatus.failed:
        return AppColors.danger;
      case EtapeStatus.pending:
        return Colors.grey.shade400;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case EtapeStatus.completed:
        return Icons.check;
      case EtapeStatus.active:
        return Icons.circle;
      case EtapeStatus.failed:
        return Icons.close;
      case EtapeStatus.pending:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne du numéro/icone
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: status == EtapeStatus.pending
                    ? Colors.grey.shade200
                    : color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: status == EtapeStatus.pending
                      ? Colors.grey.shade400
                      : color,
                  width: 2,
                ),
              ),
              child: Icon(
                _getStatusIcon(),
                size: 18,
                color: status == EtapeStatus.pending
                    ? Colors.grey.shade500
                    : color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: status == EtapeStatus.completed
                    ? AppColors.success.withOpacity(0.3)
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Contenu de l'étape
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: status == EtapeStatus.pending
                            ? AppColors.textGrey
                            : AppColors.textDark,
                      ),
                    ),
                    if (status == EtapeStatus.active) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'En cours',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (status == EtapeStatus.completed) ...[
                  const SizedBox(height: 4),
                  Text(
                    '✓ Validé',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ] else if (status == EtapeStatus.failed) ...[
                  const SizedBox(height: 4),
                  Text(
                    '✗ Non validé',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════
// WIDGET CARTE CANDIDATURE AVEC HOVER
// ══════════════════════════════════════════════════════════════
class _CandidatureCard extends StatelessWidget {
  final dynamic candidature;
  final bool isHovered;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final VoidCallback onShowDetail;

  const _CandidatureCard({
    required this.candidature,
    required this.isHovered,
    required this.onTap,
    this.onDelete,
    required this.onShowDetail,
  });

  String _getPhaseLabel(String? phase) {
    switch (phase?.toString().toLowerCase()) {
      case 'soumise':
        return 'Soumise';
      case 'examen_dossier':
        return 'Examen du dossier';
      case 'validee':
        return 'Validée';
      case 'admise':
        return 'Admise';
      case 'rejetee':
        return 'Rejetée';
      default:
        return phase ?? 'Inconnue';
    }
  }

  Color _getPhaseColor(String? phase) {
    switch (phase?.toString().toLowerCase()) {
      case 'soumise':
        return AppColors.primary;
      case 'examen_dossier':
        return AppColors.accent;
      case 'validee':
      case 'admise':
        return AppColors.success;
      case 'rejetee':
        return AppColors.danger;
      default:
        return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final offre = candidature['Offre'] ?? {};
    final phase = candidature['PhaseActuelle']?.toString();
    final dateCandidature = candidature['DateCandidature'] != null
        ? DateTime.tryParse(candidature['DateCandidature'])
        : DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHovered ? Colors.white : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHovered
                ? AppColors.primary.withOpacity(0.3)
                : Colors.transparent,
            width: isHovered ? 2 : 1,
          ),
          boxShadow: isHovered
              ? [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (offre['Entreprise'] ?? '?')
                          .toString()
                          .substring(0, 2)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offre['Titre'] ?? 'Offre inconnue',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isHovered
                              ? AppColors.primary
                              : AppColors.textDark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offre['Entreprise'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.danger,
                      size: 20,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Supprimer',
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPhaseColor(phase).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPhaseColor(phase).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _getPhaseLabel(phase),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _getPhaseColor(phase),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  offre['Localisation'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: AppColors.textGrey,
                ),
                const SizedBox(width: 4),
                Text(
                  dateCandidature != null
                      ? '${dateCandidature.day.toString().padLeft(2, '0')}/${dateCandidature.month.toString().padLeft(2, '0')}/${dateCandidature.year}'
                      : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // ✅ Mini timeline visuelle
            _buildMiniTimeline(phase),
          ],
        ),
      ),
    );
  }

  // ✅ Mini timeline dans la carte
  Widget _buildMiniTimeline(String? phase) {
    final etapes = ['soumise', 'examen_dossier', 'validee', 'admise'];
    final currentPhase = phase?.toString().toLowerCase() ?? 'soumise';
    final currentIndex = etapes.indexOf(currentPhase);

    return Row(
      children: [
        for (int i = 0; i < etapes.length; i++) ...[
          Container(
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: i <= currentIndex
                  ? (currentPhase == 'rejetee' && i < etapes.length - 1
                  ? AppColors.success
                  : currentPhase == 'rejetee'
                  ? AppColors.danger
                  : AppColors.accent)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          if (i < etapes.length - 1) const SizedBox(width: 4),
        ],
        const Spacer(),
        GestureDetector(
          onTap: onShowDetail,
          child: Text(
            'Voir détails →',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}