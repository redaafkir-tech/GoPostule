// lib/core/services/dossier_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class DossierService {
  final DioClient _dio = DioClient.instance;

  // GET /api/Dossiers
  Future<List<dynamic>> getAllDossiers() async {
    final response = await _dio.get(ApiConstants.dossiers);
    return response.data as List<dynamic>;
  }

  // GET /api/Dossiers/{id}
  Future<Map<String, dynamic>> getDossierById(int id) async {
    final response = await _dio.get('${ApiConstants.dossiers}/$id');
    return response.data as Map<String, dynamic>;
  }

  // ✅POST /api/Dossiers
  Future<Map<String, dynamic>> createDossier({
    required int userId,
    required int candidatureId,
    required String nom,
    required String prenom,
    required String cheminCIN,
    required String cheminCV,
    required String cheminDiplome,
    required String cheminPhoto,
  }) async {
    try {
      final data = {
        'userId': userId,
        'candidatureId': candidatureId,
        'nom': nom,
        'prenom': prenom,
        'cheminCIN': cheminCIN,  // ← Envoyer même si vide
        'cheminCV': cheminCV,
        'cheminDiplome': cheminDiplome,
        'cheminPhoto': cheminPhoto,
      };

      print('📡 Envoi createDossier (JSON):');
      print('   userId: $userId');
      print('   candidatureId: $candidatureId');
      print('   nom: $nom');
      print('   prenom: $prenom');
      print('   cheminCIN: ${cheminCIN.isEmpty ? "(vide)" : "(présent)"}');
      print('   cheminCV: ${cheminCV.isEmpty ? "(vide)" : "(présent)"}');

      //  S'assurer que le Content-Type est application/json
      final response = await _dio.post(
        ApiConstants.dossiers,
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('✅ Dossier créé: ${response.data}');
      return response.data as Map<String, dynamic>;

    } on DioException catch (e) {
      print('❌ Erreur Dio createDossier:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');

      if (e.response?.statusCode == 415) {
        print('⚠️ ERREUR 415: Le serveur n\'accepte pas le format JSON envoyé');
        print('   Vérifiez que le backend accepte application/json');
      }

      rethrow;
    } catch (e) {
      print('❌ Erreur createDossier: $e');
      rethrow;
    }
  }

  // PUT /api/Dossiers/{id}
  Future<Map<String, dynamic>> updateDossier({
    required int id,
    required String nom,
    required String prenom,
    String? cheminCIN,
    String? cheminDiplome,
    String? cheminCV,
    String? cheminPhoto,
  }) async {
    try {
      final data = {
        'nom': nom,
        'prenom': prenom,
        'cheminCIN': cheminCIN ?? '',
        'cheminDiplome': cheminDiplome ?? '',
        'cheminCV': cheminCV ?? '',
        'cheminPhoto': cheminPhoto ?? '',
      };

      final response = await _dio.put(
        '${ApiConstants.dossiers}/$id',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      return response.data as Map<String, dynamic>;
    } catch (e) {
      print('❌ Erreur updateDossier: $e');
      rethrow;
    }
  }

  // DELETE /api/Dossiers/{id}
  Future<Map<String, dynamic>> deleteDossier(int id) async {
    final response = await _dio.delete('${ApiConstants.dossiers}/$id');
    return response.data as Map<String, dynamic>;
  }
}