import 'package:dio/dio.dart';
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

  // POST /api/Dossiers — multipart/form-data avec fichiers
  Future<Map<String, dynamic>> createDossier({
    required int userId,
    required int candidatureId,
    required String nom,
    required String prenom,
    required String cheminCIN,
    required String cheminDiplome,
    required String cheminCV,
    required String cheminPhoto,
  }) async {
    final formData = FormData.fromMap({
      'UserId': userId,
      'CandidatureId': candidatureId,
      'Nom': nom,
      'Prenom': prenom,
      'fileCIN': await MultipartFile.fromFile(cheminCIN),
      'fileDiplome': await MultipartFile.fromFile(cheminDiplome),
      'fileCV': await MultipartFile.fromFile(cheminCV),
      'filePhoto': await MultipartFile.fromFile(cheminPhoto),
    });
    final response = await _dio.post(ApiConstants.dossiers, data: formData);
    return response.data as Map<String, dynamic>;
  }

  // PUT /api/Dossiers/{id} — fichiers optionnels
  Future<Map<String, dynamic>> updateDossier({
    required int id,
    required String nom,
    required String prenom,
    String? cheminCIN,
    String? cheminDiplome,
    String? cheminCV,
    String? cheminPhoto,
  }) async {
    final map = <String, dynamic>{'Nom': nom, 'Prenom': prenom};
    if (cheminCIN != null) map['fileCIN'] = await MultipartFile.fromFile(cheminCIN);
    if (cheminDiplome != null) map['fileDiplome'] = await MultipartFile.fromFile(cheminDiplome);
    if (cheminCV != null) map['fileCV'] = await MultipartFile.fromFile(cheminCV);
    if (cheminPhoto != null) map['filePhoto'] = await MultipartFile.fromFile(cheminPhoto);

    final response = await _dio.put('${ApiConstants.dossiers}/$id', data: FormData.fromMap(map));
    return response.data as Map<String, dynamic>;
  }

  // DELETE /api/Dossiers/{id}
  Future<Map<String, dynamic>> deleteDossier(int id) async {
    final response = await _dio.delete('${ApiConstants.dossiers}/$id');
    return response.data as Map<String, dynamic>;
  }
}