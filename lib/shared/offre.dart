// lib/shared/offre.dart
class Offre {
  final int id;
  final String titre;
  final String entreprise;
  final String description;
  final String? missions;
  final String? profilRecherche;
  final String? competences;
  final String localisation;
  final String? salaire;
  final String typeContrat;
  final String secteur;
  final String? dateLimite;
  final int? placesDisponibles;
  final bool actif;
  final DateTime? createdAt;

  Offre({
    required this.id,
    required this.titre,
    required this.entreprise,
    required this.description,
    this.missions,
    this.profilRecherche,
    this.competences,
    required this.localisation,
    this.salaire,
    required this.typeContrat,
    required this.secteur,
    this.dateLimite,
    this.placesDisponibles,
    required this.actif,
    this.createdAt,
  });

  // ✅ CONSTRUCTEUR JSON → OBJET (clés backend en MAJUSCULE)
  factory Offre.fromJson(Map<String, dynamic> json) {
    return Offre(
      id: json['Id'] ?? 0,
      titre: json['Titre'] ?? '',
      entreprise: json['Entreprise'] ?? '',
      description: json['Description'] ?? '',
      missions: json['Missions'],
      profilRecherche: json['ProfilRecherche'],
      competences: json['Competences'],
      localisation: json['Localisation'] ?? '',
      salaire: json['Salaire'],
      typeContrat: json['TypeContrat'] ?? '',
      secteur: json['Secteur'] ?? '',
      dateLimite: json['DateLimite'],
      placesDisponibles: json['PlacesDisponibles'],
      actif: json['Actif'] ?? true,
      createdAt: json['CreatedAt'] != null
          ? DateTime.tryParse(json['CreatedAt'])
          : null,
    );
  }

  // ✅ OBJET → JSON (pour les envois vers l'API)
  Map<String, dynamic> toJson() => {
    'Titre': titre,
    'Entreprise': entreprise,
    'Description': description,
    'Localisation': localisation,
    'TypeContrat': typeContrat,
    'Secteur': secteur,
    'Missions': missions,
    'Competences': competences,
    'Salaire': salaire,
    'DateLimite': dateLimite,
    'PlacesDisponibles': placesDisponibles,
    'Actif': actif,
  };
}