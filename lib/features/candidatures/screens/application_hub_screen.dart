// lib/features/candidatures/screens/application_hub_screen.dart
import 'package:flutter/material.dart';
import '../widgets/application_status_card.dart';
import '../widgets/application_timeline.dart';
import '../widgets/application_insights.dart';
import '../widgets/document_center.dart';
import '../widgets/application_actions.dart';
import '../widgets/empty_states.dart';
import '../../../shared/candidature_enhanced.dart';
import '../../../core/services/candidature_service_enhanced.dart';
import '../../../shared/offre.dart';

class ApplicationHubScreen extends StatefulWidget {
  final String candidatureId;
  const ApplicationHubScreen({super.key, required this.candidatureId});

  @override
  State<ApplicationHubScreen> createState() => _ApplicationHubScreenState();
}

class _ApplicationHubScreenState extends State<ApplicationHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CandidatureServiceEnhanced _service = CandidatureServiceEnhanced();
  CandidatureEnhanced? _candidature;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCandidature();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCandidature() async {
    setState(() { _isLoading = true; _error = null; });

    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // 🎯 DONNÉES DE TEST avec Concours Écrit/Oral + Emails
      // ✅ Utilise camelCase pour correspondre au modèle
      final testData = CandidatureEnhanced(
        id: widget.candidatureId,
        offre: Offre(
          id: 1,
          titre: 'Data Analyst',
          entreprise: 'ONEE',
          description: 'Test',
          localisation: 'Rabat',
          typeContrat: 'CDI',
          secteur: 'Data',
          actif: true,
        ),
        status: CandidatureStatus.concoursEcrit,
        dateSoumission: DateTime.now().subtract(const Duration(days: 5)),
        progressPercent: 60,
        phaseActuelle: 'concoursEcrit', // ✅ camelCase
        timeline: [
          TimelineEvent(
              phase: 'soumise',
              label: 'Candidature soumise',
              date: DateTime.now().subtract(const Duration(days: 5)),
              isCompleted: true,
              isCurrent: false
          ),
          TimelineEvent(
              phase: 'examenRh', // ✅ camelCase
              label: 'Examen RH',
              date: DateTime.now().subtract(const Duration(days: 4)),
              isCompleted: true,
              isCurrent: false
          ),
          TimelineEvent(
              phase: 'concoursEcrit', // ✅ camelCase
              label: 'Concours Écrit',
              date: DateTime.now().subtract(const Duration(days: 2)),
              isCompleted: true,
              isCurrent: false,
              commentaire: 'Note: 15/20'
          ),
          TimelineEvent(
              phase: 'concoursOral', // ✅ camelCase
              label: 'Concours Oral',
              date: DateTime.now().add(const Duration(days: 3)),
              isCompleted: false,
              isCurrent: true
          ),
        ],
        documentStatus: DocumentStatus(
            cvUploaded: true,
            cinUploaded: true,
            diplomeUploaded: true,
            photoUploaded: false,
            lettreMotivationUploaded: true,
            totalDocuments: 5,
            uploadedDocuments: 4,
            progressPercent: 80
        ),
        insights: InsightsData(
            profileCompleteness: 80,
            chancesEstimation: 'Élevées',
            tips: ['Ajoutez votre photo', 'Préparez votre entretien oral'],
            candidatsConcurrents: 12
        ),
        // ✅ Champs concours + emails
        resultatConcoursEcrit: ConcoursResult.admis,
        resultatConcoursOral: null,
        emailConcoursEcritRecu: true,
        emailConcoursOralRecu: false,
        dateConcoursEcrit: DateTime.now().subtract(const Duration(days: 2)),
        dateConcoursOral: DateTime.now().add(const Duration(days: 3)),
      );

      setState(() { _candidature = testData; _isLoading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        title: const Text(
            'Ma Candidature',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)
        ),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Progression'),
            Tab(text: 'Documents'),
            Tab(text: 'Actions')
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Erreur: $_error'))
          : _candidature == null
          ? const Center(child: Text("Chargement..."))
          : TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Progression
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ApplicationStatusCard(candidature: _candidature!),
                const SizedBox(height: 16),
                ApplicationTimeline(candidature: _candidature!),
                const SizedBox(height: 16),
                ApplicationInsights(candidature: _candidature!),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Tab 2: Documents
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                DocumentCenter(candidature: _candidature!),
                const SizedBox(height: 32),
              ],
            ),
          ),
          // Tab 3: Actions
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                ApplicationActions(candidature: _candidature!),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}