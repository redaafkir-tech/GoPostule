// La classe Offre représente une offre d'emploi
// Chaque champ correspond à une colonne dans ta table SQL Server
class Offre {
  final int id;
  final String titre;
  final String entreprise;
  final String ville;
  final String secteur;   // "dev", "infra", "economie"...
  final String niveau;    // "junior", "senior", "stage"...
  final String description;
  final DateTime datePublication;

  const Offre({
    required this.id,
    required this.titre,
    required this.entreprise,
    required this.ville,
    required this.secteur,
    required this.niveau,
    required this.description,
    required this.datePublication,
  });

  // fromJson : convertit la réponse JSON du backend en objet Dart
  factory Offre.fromJson(Map<String, dynamic> json) {
    return Offre(
      id:               json['id'],
      titre:            json['titre'],
      entreprise:       json['entreprise'],
      ville:            json['ville'],
      secteur:          json['secteur'],
      niveau:           json['niveau'],
      description:      json['description'],
      datePublication:  DateTime.parse(json['datePublication']),
    );
  }
}