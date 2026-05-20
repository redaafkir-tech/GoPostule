// lib/core/services/candidature_service_enhanced.dart
import '../../shared/candidature_enhanced.dart';
import '../network/dio_client.dart';
import '../constants/api_constants.dart';

class CandidatureServiceEnhanced {
  final DioClient _dio = DioClient.instance;

  Future<CandidatureEnhanced> getCandidatureEnhanced(String id) async {
    try {
      final response = await _dio.get('${ApiConstants.candidatures}/$id');

      if (response.statusCode == 200) {
        return CandidatureEnhanced.fromJson(response.data);
      }
      throw Exception('Candidature non trouvée');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CandidatureEnhanced>> getMesCandidaturesEnhanced() async {
    try {
      final response = await _dio.get(ApiConstants.mesCandidatures);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data
            .map((json) => CandidatureEnhanced.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateDocument(String candidatureId, String type, String filePath) async {
    try {
      print('Upload document: $type pour candidature $candidatureId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> submitReclamation({
    required String candidatureId,
    required String sujet,
    required String message,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.reclamations}',
        data: {
          'candidatureId': candidatureId,
          'sujet': sujet,
          'message': message,
        },
      );
    } catch (e) {
      rethrow;
    }
  }
}