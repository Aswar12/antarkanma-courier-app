import 'package:antarkanma_courier/config.dart';
import 'package:dio/dio.dart';


class BaseProvider {
  final Dio _dio;

  BaseProvider() : _dio = Dio(BaseOptions(
    baseUrl: Config.baseUrl,
    connectTimeout: Duration(seconds: Config.connectTimeout),
    receiveTimeout: Duration(seconds: Config.receiveTimeout),
  ));

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, String? token}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParams,
        options: _getOptions(token),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParams,
        options: _getOptions(token),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParams,
        options: _getOptions(token),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(String path, {
    dynamic data,
    Map<String, dynamic>? queryParams,
    String? token,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParams,
        options: _getOptions(token),
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Options _getOptions(String? token) {
    return Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      validateStatus: (status) => status! < 500,
    );
  }

  dynamic _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response.data;
    } else {
      final message = response.data?['message'] ?? 'Terjadi kesalahan';
      throw message;
    }
  }

  String _handleError(DioException error) {
    if (error.response?.data?['message'] != null) {
      return error.response?.data['message'];
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Koneksi timeout. Silakan coba lagi.';
      case DioExceptionType.badResponse:
        return 'Terjadi kesalahan server.';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
}
