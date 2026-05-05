import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class AuthService {

  // ── LOGIN AVEC DEBUG ──────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    // On prépare les données
    final dataToSend = {
      "Email": email,    // Majuscule pour correspondre au LoginDto C#
      "Password": password,
    };

    // ÉTAPE CRUCIALE : Vérifie ce message dans ta console Flutter (en bas)
    print('DEBUG DATA ENVOYÉE : $dataToSend');

    try {
      print('📤 Appel login vers : ${ApiConstants.login}');

      final response = await DioClient.instance.post(
        ApiConstants.login,
        data: dataToSend,
      );

      print('✅ Login réussi : ${response.data}');

// Ajoute ces lignes pour tester chaque champ manuellement
      print('Nom: ${response.data['Nom']}');
      print('Token: ${response.data['Token']}');

      return response.data;
    } on DioException catch (e) {
      // Si le serveur répond "Email introuvable", tu le verras ici :
      print('❌ Erreur serveur détaillée : ${e.response?.data}');
      throw Exception(
          e.response?.data?['message'] ?? 'Email ou mot de passe incorrect'
      );
    }
  }

  // ── REGISTER ───────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
  }) async {
    try {
      final response = await DioClient.instance.post(
        ApiConstants.register,
        data: {
          "Nom": nom,           // Majuscules pour le DTO
          "Prenom": prenom,
          "Email": email,
          "Password": password,
          "Telephone": telephone,
        },
      );
      print('✅ Inscription réussie !');
      return response.data;
    } on DioException catch (e) {
      print('❌ Erreur serveur : ${e.response?.data}');
      throw Exception('Erreur lors de l\'enregistrement');
    }
  }
}