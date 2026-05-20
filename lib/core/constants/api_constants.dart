// lib/core/constants/api_constants.dart
class ApiConstants {
  // 🌐 Base URL - Change selon l'environnement
  // Emulateur Android: http://10.0.2.2:5000/api
  // iOS Simulator: http://localhost:5000/api
  // Production: https://api.gopostul.com/api
  static const String baseUrl = 'http://localhost:5000/api';

  // 🔐 Auth Endpoints
  static const String login = '$baseUrl/auth/login';
  static const String register = '$baseUrl/auth/register';
  static const String me = '$baseUrl/auth/me';                    // ✅ GET/PUT profil
  static const String changePassword = '$baseUrl/auth/change-password'; // ✅ POST changement MDP
  static const String logout = '$baseUrl/auth/logout';            // ✅ POST déconnexion

  // 📋 Offres Endpoints
  static const String offres = '$baseUrl/offres';
  static const String offresSearch = '$baseUrl/offres/search';
  static const String offreById = '$baseUrl/offres/'; // + id

  // 📁 Dossier Endpoints
  static const String dossiers = '$baseUrl/dossiers';

  // 📝 Candidatures Endpoints
  static const String candidatures = '$baseUrl/candidatures';
  static const String mesCandidatures = '$baseUrl/candidatures/me';
  static const String postuler = '$baseUrl/candidatures/postuler';
  static const String candidatureById = '$baseUrl/candidatures/'; // + id

  // ⚠️ Réclamations Endpoints
  static const String reclamations = '$baseUrl/reclamations';
  static const String mesReclamations = '$baseUrl/reclamations/me';
}