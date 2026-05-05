class ApiConstants {

  // Émulateur Android → 10.0.2.2 remplace localhost
  static const String baseUrl = "http://localhost:5000";


  // Si vrai téléphone → mettre votre IP
  // static const String baseUrl = "http://192.168.0.193:5000";

  static const String register     = "$baseUrl/api/auth/register";
  static const String login        = "$baseUrl/api/auth/login";
  static const String me           = "$baseUrl/api/auth/me";
  static const String offres       = "$baseUrl/api/offres";
  static const String candidatures = "$baseUrl/api/candidatures";
  static const String dossiers     = "$baseUrl/api/dossiers";
}