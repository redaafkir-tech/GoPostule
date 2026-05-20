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
    final response = await _dio.post(ApiConstants.candidatures, data: {
      'OffreId': offreId,
      'LettreMotivation': lettreMotivation ?? '',
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /api/Candidatures/me — mes candidatures
  Future<List<dynamic>> getMesCandidatures() async {
    final response = await _dio.get(ApiConstants.mesCandidatures);
    return response.data;
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
  // Phases valides : soumise | examen_dossier | validee | rejetee | admise
  Future<Map<String, dynamic>> changerPhase({
    required int id,
    required String phase,
    String? commentaire,
  }) async {
    final response = await _dio.patch(
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