import 'package:dio/dio.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class ReclamationService {
  final DioClient _dio = DioClient.instance;

  // POST /api/Reclamations — soumettre une réclamation (candidat)
  Future<Map<String, dynamic>> createReclamation({
    required int candidatureId,
    required String objet,
    required String message,
  }) async {
    final response = await _dio.post(ApiConstants.reclamations, data: {
      'CandidatureId': candidatureId,
      'Objet': objet,
      'Message': message,
    });
    return response.data as Map<String, dynamic>;
  }

  // GET /api/Reclamations/me — mes réclamations (candidat)
  Future<List<dynamic>> getMesReclamations() async {
    final response = await _dio.get('${ApiConstants.reclamations}/me');
    return response.data as List<dynamic>;
  }

  // GET /api/Reclamations — toutes les réclamations (admin/RH)
  Future<List<dynamic>> getAllReclamations() async {
    final response = await _dio.get(ApiConstants.reclamations);
    return response.data as List<dynamic>;
  }

  // GET /api/Reclamations/{id}
  Future<Map<String, dynamic>> getReclamationById(int id) async {
    final response = await _dio.get('${ApiConstants.reclamations}/$id');
    return response.data as Map<String, dynamic>;
  }

  // PUT /api/Reclamations/{id}/repondre — répondre (admin/RH)
  // Statuts valides : en_attente | en_traitement | resolue | rejetee
  Future<Map<String, dynamic>> repondre({
    required int id,
    required String reponseAdmin,
    required String statut,
  }) async {
    final response = await _dio.put(
      '${ApiConstants.reclamations}/$id/repondre',
      data: {
        'ReponseAdmin': reponseAdmin,
        'Statut': statut,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  // DELETE /api/Reclamations/{id}
  Future<Map<String, dynamic>> deleteReclamation(int id) async {
    final response = await _dio.delete('${ApiConstants.reclamations}/$id');
    return response.data as Map<String, dynamic>;
  }
}