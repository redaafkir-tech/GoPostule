import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../services/storage_service.dart';

class DioClient {
  // Instance unique de Dio partagée dans toute l'app
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10), // Abandon si pas de connexion en 10s
      receiveTimeout: const Duration(seconds: 10), // Abandon si pas de réponse en 10s
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Initialiser les intercepteurs — à appeler une seule fois dans main.dart
  static void init() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Avant chaque requête : récupère le token JWT et l'ajoute automatiquement
          final token = await StorageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            // Bearer = protocole standard pour envoyer un JWT dans le header HTTP
          }
          return handler.next(options); // Continue la requête
        },
        onError: (error, handler) {
          // Si le serveur répond 401 = token expiré ou invalide
          if (error.response?.statusCode == 401) {
            // TODO : rediriger vers login
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Getter public pour utiliser Dio depuis les services
  static Dio get instance => _dio;
}