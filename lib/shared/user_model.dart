// lib/shared/user_model.dart
class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String ville;
  final String? photoUrl;

  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone = '',
    required this.ville,
    this.photoUrl,
  });

  // ✅ fromJson avec gestion camelCase/snake_case et majuscules C#
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['Id'] ?? json['id'] ?? json['Id'] ?? 0,
      nom: json['Nom'] ?? json['nom'] ?? '',
      prenom: json['Prenom'] ?? json['prenom'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      telephone: json['Telephone'] ?? json['telephone'] ?? '',
      ville: json['Ville'] ?? json['ville'] ?? '',
      photoUrl: json['PhotoUrl'] ?? json['photoUrl'],
    );
  }

  // ✅ toJson pour les requêtes PUT/POST
  Map<String, dynamic> toJson() {
    return {
      'Nom': nom,
      'Prenom': prenom,
      'Email': email,
      'Telephone': telephone,
      'Ville': ville,
      'PhotoUrl': photoUrl,
    };
  }

  // ✅ copyWith pour mettre à jour l'objet
  UserModel copyWith({
    int? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? ville,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      ville: ville ?? this.ville,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}