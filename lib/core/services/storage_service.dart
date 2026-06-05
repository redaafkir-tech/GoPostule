// lib/core/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';


class StorageService {
  static SharedPreferences? _prefs;

  /// 🔹 Initialisation obligatoire dans main()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 🔹 TOKEN JWT
  static Future<void> saveToken(String token) async {
    await _prefs?.setString('token', token);
  }

  static String? getToken() {
    return _prefs?.getString('token');
  }

  static Future<void> removeToken() async {
    await _prefs?.remove('token');
  }

  static bool hasToken() {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }

  /// 🔹 USER ID
  static Future<void> saveUserId(int userId) async {
    await _prefs?.setInt('userId', userId);
  }

  static int? getUserId() {
    return _prefs?.getInt('userId');
  }

  static Future<void> removeUserId() async {
    await _prefs?.remove('userId');
  }

  /// 🔹 EMAIL (pour pré-remplir le login)
  static Future<void> saveEmail(String email) async {
    await _prefs?.setString('email', email);
  }

  static String? getEmail() {
    return _prefs?.getString('email');
  }

  static Future<void> removeEmail() async {
    await _prefs?.remove('email');
  }

  /// 🔹 ROLE UTILISATEUR
  static Future<void> saveRole(String role) async {
    await _prefs?.setString('role', role);
  }

  static String? getRole() {
    return _prefs?.getString('role');
  }

  static Future<void> removeRole() async {
    await _prefs?.remove('role');
  }

  /// 🔹 LOGOUT COMPLET
  static Future<void> logout() async {
    await removeToken();
    await removeUserId();
    await removeEmail();
    await removeRole();
    // Optionnel : clear() si vous voulez tout effacer
    // await _prefs?.clear();
  }

  /// 🔹 VÉRIFICATION SESSION
  static Future<bool> isAuthenticated() async {
    final token = getToken();
    return token != null && token.isNotEmpty;
  }
  /// 🔹 RESET COMPLET (utile pour tests ou réinstallation)
  static Future<void> clearAll() async {
    await _prefs?.clear();
  }

  /// 🔹 DEBUG : Affiche toutes les clés stockées (dev uniquement)
  static void debugPrintAll() {
    assert(() {
      // ignore: avoid_print
      print('🔍 StorageService debug:');
      _prefs?.getKeys().forEach((key) {
        // ignore: avoid_print
        print('   • $key = ${_prefs?.get(key)}');
      });
      return true;
    }());
  }
}