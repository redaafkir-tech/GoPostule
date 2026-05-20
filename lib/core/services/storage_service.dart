// lib/core/services/storage_service.dart
import 'dart:convert'; // ✅ Pour jsonEncode/jsonDecode
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // ─────────────────────────────────────────────────────────────
  // 🚀 INITIALISATION
  // ─────────────────────────────────────────────────────────────
  static Future<void> init() async {
    await SharedPreferences.getInstance();
  }

  // ─────────────────────────────────────────────────────────────
  // 🔐 GESTION DU TOKEN JWT
  // ─────────────────────────────────────────────────────────────

  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Récupérer le token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Supprimer le token (déconnexion)
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // ✅ Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────
  // 👤 GESTION DES DONNÉES UTILISATEUR
  // ─────────────────────────────────────────────────────────────

  // Sauvegarder les données utilisateur
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  // Récupérer les données utilisateur
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return jsonDecode(data);
  }

  // Supprimer les données utilisateur
  static Future<void> removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // ─────────────────────────────────────────────────────────────
  // 🚪 DÉCONNEXION COMPLÈTE
  // ─────────────────────────────────────────────────────────────

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Supprime token + userData
  }
}