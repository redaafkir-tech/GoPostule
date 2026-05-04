import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // shared_preferences fonctionne sur Android, iOS ET Web
   static const _tokenKey = 'jwt_token';

  // Sauvegarder le token après login
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token au logout
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Vérifier si connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}