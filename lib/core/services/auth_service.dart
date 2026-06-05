// lib/core/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';
import 'storage_service.dart';

class AuthService {
  static final DioClient _dio = DioClient.instance;

  // 🔐 LOGIN
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'Email': email, 'Password': password},
      );
      if (response.statusCode == 200) {
        final token = response.data['token'] ?? response.data['Token'];
        if (token != null) await StorageService.saveToken(token.toString());
        return response.data;
      }
      throw Exception('Email ou mot de passe incorrect');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['errors']?[0] ??
            'Erreur de connexion',
      );
    } catch (e) {
      throw Exception('Une erreur est survenue');
    }
  }

  // 📝 REGISTER
  static Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
  }) async {
    try {
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
        return response.data;
      }
      throw Exception("Erreur lors de l'inscription");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['errors']?[0] ??
            "Erreur d'inscription",
      );
    } catch (e) {
      throw Exception('Une erreur est survenue');
    }
  }

  //  GET PROFIL
  static Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      if (response.statusCode == 200) return response.data;
      throw Exception('Impossible de charger le profil');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await StorageService.removeToken();
        throw Exception('Session expirée, veuillez vous reconnecter');
      }
      throw Exception(e.response?.data?['message'] ?? 'Erreur de chargement');
    } catch (e) {
      throw Exception('Une erreur est survenue');
    }
  }

  // ✏ UPDATE PROFIL
  static Future<void> updateMe({
    required String nom,
    required String prenom,
    required String email,
    required String telephone,
    required String ville,
    String? photoUrl,
  }) async {
    try {
      final body = <String, String>{
        'Nom': nom,
        'Prenom': prenom,
        'Email': email,
        'Telephone': telephone,
        'Ville': ville,
      };
      if (photoUrl != null) body['PhotoUrl'] = photoUrl;

      final response = await _dio.put(ApiConstants.me, data: body);
      if (response.statusCode != 200) {
        throw Exception('Erreur lors de la mise à jour');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['errors']?[0] ??
            'Erreur de mise à jour',
      );
    } catch (e) {
      throw Exception('Une erreur est survenue');
    }
  }

  //  CHANGE PASSWORD
  static Future<void> changePassword({
    required String ancienMotDePasse,
    required String nouveauMotDePasse,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'AncienMotDePasse': ancienMotDePasse,
          'NouveauMotDePasse': nouveauMotDePasse,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur lors du changement de mot de passe');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message'] ??
            e.response?.data?['errors']?[0] ??
            'Ancien mot de passe incorrect',
      );
    } catch (e) {
      throw Exception('Une erreur est survenue');
    }
  }

  //  LOGOUT
  static Future<void> logout() async {
    try {
      await StorageService.removeToken();
    } catch (_) {
      await StorageService.removeToken();
    }
  }

  //  ENVOYER CODE CHANGEMENT EMAIL
  static Future<void> sendEmailChangeCode(String nouvelEmail) async {
    try {
      final response = await _dio.post(
        '/auth/send-email-change-code',
        data: {'NewEmail': nouvelEmail},
      );
      if (response.statusCode != 200) throw Exception('Erreur envoi code');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Erreur envoi code');
    }
  }

  //  CONFIRMER CHANGEMENT EMAIL — body corrigé : NewEmail + Code
  static Future<void> confirmEmailChange({
    required String nouvelEmail,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/confirm-email-change',
        data: {
          'NewEmail': nouvelEmail,
          'Code': code,
        },
      );

      if (response.statusCode != 200) throw Exception('Code invalide');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Code invalide');
    }
  }
}