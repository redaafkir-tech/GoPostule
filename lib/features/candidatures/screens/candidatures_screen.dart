import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/candidature.dart';
import '../widgets/candidature_card.dart';

class CandidaturesScreen extends StatefulWidget {
  const CandidaturesScreen({super.key});

  @override
  State<CandidaturesScreen> createState() => _CandidaturesScreenState();
}

class _CandidaturesScreenState extends State<CandidaturesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO Phase 2 : remplacer par appel API
  List<Candidature> _candidatures = [
    Candidature(
      id: 1,
      titreOffre: 'Développeur Flutter',
      entreprise: 'TechCorp',
      ville: 'Casablanca',
      datePostulation: DateTime(2025, 4, 1),
      phase: PhaseCandidature.convoque,
      typeExamen: TypeExamen.ecrit,
      dateExamen: DateTime(2025, 5, 10),
    ),
    Candidature(
      id: 2,
      titreOffre: 'Analyste Financier',
      entreprise: 'BanqueMaroc SA',
      ville: 'Rabat',
      datePostulation: DateTime(2025, 4, 10),
      phase: PhaseCandidature.resultat,
      resultat: ResultatCandidature.admis,
    ),
    Candidature(
      id: 3,
      titreOffre: 'Ingénieur Réseau',
      entreprise: 'NetSolutions',
      ville: 'Tanger',
      datePostulation: DateTime(2025, 3, 15),
      phase: PhaseCandidature.resultat,
      resultat: ResultatCandidature.refuse,
      raisonRefus: 'Votre profil ne correspond pas aux critères requis pour ce poste. Nous vous encourageons à postuler pour d\'autres offres.',
    ),
    Candidature(
      id: 4,
      titreOffre: 'Développeur .NET Senior',
      entreprise: 'SoftHouse',
      ville: 'Casablanca',
      datePostulation: DateTime(2025, 4, 18),
      phase: PhaseCandidature.enRevision,
    ),
  ];

  // Supprimer une candidature — seulement si résultat final
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
              backgroundColor: AppColors.statusRejected,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                // Supprime de la liste locale — TODO API DELETE /candidatures/{id}
                _candidatures.removeWhere((c) => c.id == id);
              });
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // Bottom sheet détail candidature
  void _showDetail(BuildContext context, Candidature c) {
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
              // Handle
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
                    // En-tête
                    Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: Text(
                              c.entreprise.substring(0, 2).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.titreOffre,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textDark,
                                  )),
                              Text(c.entreprise,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textGrey,
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(height: 1, color: Color(0xFFF0F0F0)),
                    const SizedBox(height: 20),

                    // Bloc selon la phase
                    if (c.phase == PhaseCandidature.convoque)
                      _buildConvoqueBloc(c),

                    if (c.phase == PhaseCandidature.resultat &&
                        c.resultat == ResultatCandidature.admis)
                      _buildAdmisBloc(),

                    if (c.phase == PhaseCandidature.resultat &&
                        c.resultat == ResultatCandidature.refuse)
                      _buildRefuseBloc(context, c),

                    if (c.phase == PhaseCandidature.envoyee ||
                        c.phase == PhaseCandidature.enRevision)
                      _buildEnAttenteBloc(c),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bloc — candidature en attente ou en révision
  Widget _buildEnAttenteBloc(Candidature c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Statut actuel',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  color: AppColors.primary.withOpacity(0.7), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.phase == PhaseCandidature.envoyee
                      ? 'Votre candidature a bien été envoyée. Elle est en attente d\'examen.'
                      : 'Votre candidature est en cours de révision par l\'équipe RH.',
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textGrey,
                      height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bloc — convoqué à un examen
  Widget _buildConvoqueBloc(Candidature c) {
    final typeLabel = c.typeExamen == TypeExamen.ecrit
        ? 'Examen écrit'
        : 'Entretien oral';
    final typeIcon = c.typeExamen == TypeExamen.ecrit
        ? Icons.edit_note_rounded
        : Icons.mic_rounded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Convocation',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(typeIcon, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    typeLabel,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              if (c.dateExamen != null) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.event_rounded,
                        size: 14, color: AppColors.textGrey),
                    const SizedBox(width: 6),
                    Text(
                      'Le ${c.dateExamen!.day}/${c.dateExamen!.month}/${c.dateExamen!.year}',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textGrey),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              const Text(
                'Préparez-vous bien. Les résultats vous seront communiqués après délibération.',
                style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textGrey,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bloc — admis
  Widget _buildAdmisBloc() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Résultat',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.statusOffer.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.statusOffer.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.statusOffer.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: AppColors.statusOffer, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Félicitations !',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusOffer,
                        )),
                    SizedBox(height: 4),
                    Text(
                      'Votre candidature a été retenue. Vous serez contacté prochainement.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Bloc — refusé avec raison + bouton réclamation
  Widget _buildRefuseBloc(BuildContext context, Candidature c) {
    final _reclamationController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Résultat',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 12),

        // Bloc refus
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.statusRejected.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: AppColors.statusRejected.withOpacity(0.25)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.statusRejected.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: AppColors.statusRejected, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Candidature refusée',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusRejected,
                        )),
                    const SizedBox(height: 6),
                    Text(
                      c.raisonRefus ??
                          'Votre candidature n\'a pas été retenue pour ce poste.',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textGrey,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Section réclamation
        const Text('Déposer une réclamation',
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        const SizedBox(height: 8),
        const Text(
          'Si vous estimez que cette décision est injustifiée, vous pouvez soumettre une réclamation.',
          style: TextStyle(
              fontSize: 12, color: AppColors.textGrey, height: 1.5),
        ),
        const SizedBox(height: 12),

        // Champ texte réclamation
        TextField(
          controller: _reclamationController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Expliquez votre réclamation...',
            hintStyle:
            const TextStyle(fontSize: 13, color: AppColors.textGrey),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Bouton soumettre réclamation
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              if (_reclamationController.text.trim().isEmpty) return;
              Navigator.pop(context);
              // TODO Phase 2 : POST /reclamations
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Réclamation soumise avec succès'),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Soumettre la réclamation'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 46),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Actives = pas encore à résultat final OU résultat non supprimé
  List<Candidature> get _actives => _candidatures
      .where((c) => c.phase != PhaseCandidature.resultat)
      .toList();

  List<Candidature> get _terminees => _candidatures
      .where((c) => c.phase == PhaseCandidature.resultat)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Mes Candidatures'),
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
                  fontWeight: FontWeight.w600, fontSize: 14),
              tabs: [
                Tab(text: 'En cours (${_actives.length})'),
                Tab(text: 'Terminées (${_terminees.length})'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildListe(_actives),
          _buildListe(_terminees),
        ],
      ),
    );
  }

  Widget _buildListe(List<Candidature> liste) {
    if (liste.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64,
                color: AppColors.textGrey.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('Aucune candidature',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textGrey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: liste.length,
      itemBuilder: (context, index) {
        final c = liste[index];
        return CandidatureCard(
          candidature: c,
          onTap: () => _showDetail(context, c),
          onDelete: c.peutSupprimer
              ? () => _supprimerCandidature(c.id)
              : null,
        );
      },
    );
  }
}