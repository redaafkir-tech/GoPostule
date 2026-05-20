// lib/core/services/offre_service.dart
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';
import '../../shared/offre.dart';  // ← IMPORTANT : Import du modèle

class OffreService {
  final DioClient _dio = DioClient.instance;

  // ✅ RETOURNE List<Offre> typed
  Future<List<Offre>> getAllOffres() async {
    try {
      final response = await _dio.get(ApiConstants.offres);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // 🔁 Conversion JSON → List<Offre>
        return data.map((json) => Offre.fromJson(json)).toList();
      }

      return [];  // Retourne liste vide si erreur
    } on DioException catch (e) {
      print('❌ Erreur getAllOffres: ${e.message}');
      print('📄 Détails: ${e.response?.data}');
      rethrow;  // Propage l'erreur pour gestion dans l'UI
    } catch (e) {
      print('❌ Erreur inattendue getAllOffres: $e');
      rethrow;
    }
  }

  // ✅ RETOURNE Offre? typed
  Future<Offre?> getOffreById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.offres}/$id');

      if (response.statusCode == 200) {
        return Offre.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      print('❌ Erreur getOffreById: ${e.message}');
      rethrow;
    }
  }

  // ✅ Crée une nouvelle offre
  Future<Offre> createOffre({
    required String titre,
    required String entreprise,
    required String description,
    required String localisation,
    required String typeContrat,
    required String secteur,
    String? missions,
    String? competences,
    String? salaire,
    String? dateLimite,
    int? placesDisponibles,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.offres,
        data: {
          'Titre': titre,
          'Entreprise': entreprise,
          'Description': description,
          'Localisation': localisation,
          'TypeContrat': typeContrat,
          'Secteur': secteur,
          'Missions': missions,
          'Competences': competences,
          'Salaire': salaire,
          'DateLimite': dateLimite,
          'PlacesDisponibles': placesDisponibles,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Offre.fromJson(response.data);
      }

      throw Exception('Erreur création offre');
    } on DioException catch (e) {
      print('❌ Erreur createOffre: ${e.message}');
      rethrow;
    }
  }

  // ✅ Met à jour une offre
  Future<Offre> updateOffre(
      int id, {
        required String titre,
        required String entreprise,
        required String description,
        required String localisation,
        required String typeContrat,
        required String secteur,
        String? missions,
        String? competences,
        String? salaire,
        String? dateLimite,
        int? placesDisponibles,
      }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.offres}/$id',
        data: {
          'Titre': titre,
          'Entreprise': entreprise,
          'Description': description,
          'Localisation': localisation,
          'TypeContrat': typeContrat,
          'Secteur': secteur,
          'Missions': missions,
          'Competences': competences,
          'Salaire': salaire,
          'DateLimite': dateLimite,
          'PlacesDisponibles': placesDisponibles,
        },
      );

      if (response.statusCode == 200) {
        return Offre.fromJson(response.data);
      }

      throw Exception('Erreur mise à jour offre');
    } on DioException catch (e) {
      print('❌ Erreur updateOffre: ${e.message}');
      rethrow;
    }
  }

  // ✅ Supprime une offre (soft delete)
  Future<void> deleteOffre(int id) async {
    try {
      final response = await _dio.delete('${ApiConstants.offres}/$id');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Erreur suppression offre');
      }
    } on DioException catch (e) {
      print('❌ Erreur deleteOffre: ${e.message}');
      rethrow;
    }
  }

  // ✅ Recherche d'offres
  Future<List<Offre>> searchOffres(String query) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.offresSearch}?q=$query',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Offre.fromJson(json)).toList();
      }

      return [];
    } on DioException catch (e) {
      print('❌ Erreur searchOffres: ${e.message}');
      rethrow;
    }
  }
}