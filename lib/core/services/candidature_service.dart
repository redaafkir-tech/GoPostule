// lib/core/services/candidature_service.dart
import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class CandidatureService {
  final DioClient _dio = DioClient.instance;

  // POST /api/Candidatures — postuler à une offre
  Future<Map<String, dynamic>> postuler({
    required int offreId,
    String? lettreMotivation,
  }) async {
    print('📡 CandidatureService.postuler appelé');
    print('   OffreId: $offreId');
    print('   Lettre: ${lettreMotivation?.length ?? 0} caractères');

    try {
      final response = await _dio.post(ApiConstants.candidatures, data: {
        'OffreId': offreId,
        'LettreMotivation': lettreMotivation ?? '',
      });

      print('✅ Réponse API: ${response.statusCode}');
      print('   Données: ${response.data}');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ Erreur Dio postuler:');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');  // ← AJOUTÉ POUR DEBUG
      rethrow;
    }
  }

  // GET /api/Candidatures/me — mes candidatures
  Future<List<dynamic>> getMesCandidatures() async {
    try {
      print('🔄 Appel API: GET /api/Candidatures/me');

      final response = await _dio.get(ApiConstants.mesCandidatures);

      print('✅ Status: ${response.statusCode}');
      print('   Données: ${response.data}');
      print('   Nombre de candidatures: ${(response.data as List).length}');

      return response.data;
    } on DioException catch (e) {
      print('❌ Erreur API getMesCandidatures:');
      print('   Type: ${e.type}');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      print('   Response: ${e.response?.data}');
      rethrow;
    }
  }

  // GET /api/Candidatures/{id}
  Future<Map<String, dynamic>> getCandidatureById(int id) async {
    final response = await _dio.get('${ApiConstants.candidatures}/$id');
    return response.data as Map<String, dynamic>;
  }

  // GET /api/Candidatures/offre/{offreId} (admin/RH)
  Future<List<dynamic>> getCandidaturesByOffre(int offreId) async {
    final response = await _dio.get('${ApiConstants.candidatures}/offre/$offreId');
    return response.data as List<dynamic>;
  }

  // PATCH /api/Candidatures/{id}/phase (admin/RH)
  Future<Map<String, dynamic>> changerPhase({
    required int id,
    required String phase,
    String? commentaire,
  }) async {
    final response = await _dio.dio.patch(
      '${ApiConstants.candidatures}/$id/phase',
      data: {
        'Phase': phase,
        'Commentaire': commentaire ?? 'Passage en phase : $phase',
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // DELETE /api/Candidatures/{id}
  Future<Map<String, dynamic>> deleteCandidature(int id) async {
    final response = await _dio.delete('${ApiConstants.candidatures}/$id');
    return response.data as Map<String, dynamic>;
  }
}