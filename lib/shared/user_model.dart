class UserModel {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String ville;
  final String? photoUrl; // null = pas de photo

  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.ville,
    this.photoUrl,
  });

  // fromJson — branché sur GET /auth/me plus tard
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:       json['id'],
      nom:      json['nom'],
      prenom:   json['prenom'],
      email:    json['email'],
      ville:    json['ville'],
      photoUrl: json['photoUrl'],
    );
  }

  // copyWith — crée une copie avec des champs modifiés
  // Utilisé quand l'utilisateur modifie ses infos
  UserModel copyWith({
    String? nom,
    String? prenom,
    String? email,
    String? ville,
    String? photoUrl,
  }) {
    return UserModel(
      id:       id,
      nom:      nom ?? this.nom,
      prenom:   prenom ?? this.prenom,
      email:    email ?? this.email,
      ville:    ville ?? this.ville,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}