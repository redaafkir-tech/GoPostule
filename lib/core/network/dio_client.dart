// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class DioClient {
  final Dio _dio;
  static DioClient? _instance;

  DioClient._internal() : _dio = Dio() {
    _dio.options.baseUrl = 'http://10.0.2.2:5000/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          print('❌ Erreur HTTP: ${error.response?.statusCode}');
          return handler.next(error);
        },
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // GET
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onReceiveProgress}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // POST
  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onSendProgress, void Function(int, int)? onReceiveProgress}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // PUT
  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onSendProgress, void Function(int, int)? onReceiveProgress}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // ✅ PATCH (NOUVELLE MÉTHODE)
  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken, void Function(int, int)? onSendProgress, void Function(int, int)? onReceiveProgress}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken, onSendProgress: onSendProgress, onReceiveProgress: onReceiveProgress);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  // DELETE
  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options, CancelToken? cancelToken}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    print('❌ DioException: ${error.type}');
    print('📍 URL: ${error.requestOptions.uri}');
    print('🔢 Status: ${error.response?.statusCode}');
  }
}