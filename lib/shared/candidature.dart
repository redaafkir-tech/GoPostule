// Les 4 phases possibles d'une candidature
enum PhaseCandidature { envoyee, enRevision, convoque, resultat }

// Type d'examen si convoqué
enum TypeExamen { ecrit, oral }

// Résultat final
enum ResultatCandidature { admis, refuse }

class Candidature {
  final int id;
  final String titreOffre;
  final String entreprise;
  final String ville;
  final DateTime datePostulation;
  final PhaseCandidature phase;

  // Rempli uniquement si phase == convoque
  final TypeExamen? typeExamen;
  final DateTime? dateExamen;

  // Rempli uniquement si phase == resultat
  final ResultatCandidature? resultat;
  final String? raisonRefus; // null si admis

  const Candidature({
    required this.id,
    required this.titreOffre,
    required this.entreprise,
    required this.ville,
    required this.datePostulation,
    required this.phase,
    this.typeExamen,
    this.dateExamen,
    this.resultat,
    this.raisonRefus,
  });

  // fromJson — branché sur le backend plus tard
  factory Candidature.fromJson(Map<String, dynamic> json) {
    return Candidature(
      id:              json['id'],
      titreOffre:      json['titreOffre'],
      entreprise:      json['entreprise'],
      ville:           json['ville'],
      datePostulation: DateTime.parse(json['datePostulation']),
      phase: PhaseCandidature.values.firstWhere(
            (e) => e.name == json['phase'],
        orElse: () => PhaseCandidature.envoyee,
      ),
      typeExamen: json['typeExamen'] != null
          ? TypeExamen.values.firstWhere(
              (e) => e.name == json['typeExamen'])
          : null,
      dateExamen: json['dateExamen'] != null
          ? DateTime.parse(json['dateExamen'])
          : null,
      resultat: json['resultat'] != null
          ? ResultatCandidature.values.firstWhere(
              (e) => e.name == json['resultat'])
          : null,
      raisonRefus: json['raisonRefus'],
    );
  }

  // Vrai si l'utilisateur peut supprimer la candidature
  bool get peutSupprimer =>
      phase == PhaseCandidature.resultat;
}