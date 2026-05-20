// lib/core/services/auth_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';
import '../../shared/user_model.dart';

class AuthService {
  static final DioClient _dio = DioClient.instance;

  // ─────────────────────────────────────────────────────────────
  // 🔐 LOGIN
  // ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      print('📤 Login request: $email');

      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'Email': email,
          'Password': password,
        },
      );

      if (response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['Token'];
        if (token != null) {
          await StorageService.saveToken(token.toString());
          print('✅ Token sauvegardé');
        }
        print('✅ Login réussi');
        return response.data;
      } else {
        throw Exception('Email ou mot de passe incorrect');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']
          ?? e.response?.data?['errors']?[0]
          ?? 'Erreur de connexion';
      print('❌ Erreur login: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Erreur inattendue login: $e');
      throw Exception('Une erreur est survenue');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 📝 REGISTER
  // ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
  }) async {
    try {
      print('📤 Register request: $email');

      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'Nom': nom,
          'Prenom': prenom,
          'Email': email,
          'Password': password,
          'Telephone': telephone,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Inscription réussie');
        return response.data;
      } else {
        throw Exception('Erreur lors de l\'inscription');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']
          ?? e.response?.data?['errors']?[0]
          ?? 'Erreur d\'inscription';
      print('❌ Erreur register: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Erreur inattendue register: $e');
      throw Exception('Une erreur est survenue');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 👤 GET PROFIL (ME)
  // ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getMe() async {
    try {
      print('📤 GET /auth/me');

      final response = await _dio.get(ApiConstants.me);

      if (response.statusCode == 200) {
        print('✅ Profil chargé');
        return response.data;
      } else {
        throw Exception('Impossible de charger le profil');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await StorageService.removeToken();
        throw Exception('Session expirée, veuillez vous reconnecter');
      }
      final message = e.response?.data?['message'] ?? 'Erreur de chargement';
      print('❌ Erreur getMe: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Erreur inattendue getMe: $e');
      throw Exception('Une erreur est survenue');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // ✏️ UPDATE PROFIL - ✅ MODIFIÉ
  // ─────────────────────────────────────────────────────────────
  static Future<void> updateMe({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String ville,
    String? photoUrl,  // ✅ AJOUTÉ
  }) async {
    try {
      print('📤 PUT /auth/me');

      final body = {
        'Nom': nom,
        'Prenom': prenom,
        'Email': email,
        'Telephone': telephone,
        'Ville': ville,
      };

      // ✅ Ajoute PhotoUrl si fourni
      if (photoUrl != null) {
        body['PhotoUrl'] = photoUrl;
      }

      final response = await _dio.put(
        ApiConstants.me,
        data: body,
      );

      if (response.statusCode == 200) {
        print('✅ Profil mis à jour');
      } else {
        throw Exception('Erreur lors de la mise à jour');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']
          ?? e.response?.data?['errors']?[0]
          ?? 'Erreur de mise à jour';
      print('❌ Erreur updateMe: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Erreur inattendue updateMe: $e');
      throw Exception('Une erreur est survenue');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🔑 CHANGE PASSWORD
  // ─────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> changePassword({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      print('📤 POST /auth/change-password');

      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'AncienMotDePasse': ancienMotDePasse,
          'NouveauMotDePasse': nouveauMotDePasse,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Mot de passe changé');
        return response.data;
      } else {
        throw Exception('Erreur lors du changement de mot de passe');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message']
          ?? e.response?.data?['errors']?[0]
          ?? e.response?.statusMessage
          ?? 'Ancien mot de passe incorrect';
      print('❌ Erreur changePassword: $message');
      throw Exception(message);
    } catch (e) {
      print('❌ Erreur inattendue changePassword: $e');
      throw Exception('Une erreur est survenue');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🚪 LOGOUT
  // ─────────────────────────────────────────────────────────────
  static Future<void> logout() async {
    try {
      print('📤 POST /auth/logout');
      await StorageService.removeToken();
      print('✅ Déconnexion réussie');
    } catch (e) {
      await StorageService.removeToken();
      print('⚠️ Déconnexion partielle: $e');
    }
  }
}