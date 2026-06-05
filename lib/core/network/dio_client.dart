// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class DioClient {
  final Dio _dio;
  static DioClient? _instance;

  DioClient._internal() : _dio = Dio() {
    // ── baseUrl : localhost pour Web, 10.0.2.2 pour émulateur Android
    _dio.options.baseUrl = 'http://localhost:5000/api';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Récupération du token depuis StorageService
          final token = StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // debugPrint en dev uniquement — pas de print en prod
          assert(() {
            // ignore: avoid_print
            print('  HTTP ${error.response?.statusCode} — ${error.requestOptions.uri}');
            return true;
          }());
          return handler.next(error);
        },
      ),
    );
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  // Getter pour accéder à l'instance Dio
  Dio get dio => _dio;

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _log(e);
      rethrow;
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _log(e);
      rethrow;
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _log(e);
      rethrow;
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _log(e);
      rethrow;
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      _log(e);
      rethrow;
    }
  }

  // Méthode pour upload de fichiers
  Future<Response> upload(
      String path, {
        required FormData formData,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      _log(e);
      rethrow;
    }
  }

  void _log(DioException e) {
    assert(() {
      // ignore: avoid_print
      print('❌ DioException [${e.type}] ${e.requestOptions.uri}');
      print('   Status: ${e.response?.statusCode}');
      print('   Message: ${e.message}');
      return true;
    }());
  }
}