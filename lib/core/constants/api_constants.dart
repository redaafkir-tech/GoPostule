class ApiConstants {
  // 10.0.2.2 = adresse spéciale émulateur Android qui pointe vers ton PC
  // Quand tu passes en production tu changes juste cette ligne
  static const String baseUrl = 'http://localhost:5000/api';

  // Auth
  static const String login    = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me       = '$baseUrl/auth/me';

  // Offres
  static const String offres       = '$baseUrl/offres';
  static const String offresSearch = '$baseUrl/offres/search';

  // Dossier
  static const String dossiers = '$baseUrl/dossiers';

  // Candidatures
  static const String candidatures = '$baseUrl/candidatures';

  // Réclamations
  static const String reclamations = '$baseUrl/reclamations';
}