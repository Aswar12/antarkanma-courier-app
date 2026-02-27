import 'package:dio/dio.dart';
import 'package:antarkanma_courier/config.dart';

class AuthProvider {
  final Dio _dio;

  AuthProvider()
      : _dio = Dio(BaseOptions(
          baseUrl: Config.baseUrl,
          connectTimeout: Duration(seconds: Config.connectTimeout),
          receiveTimeout: Duration(seconds: Config.receiveTimeout),
          validateStatus: (status) {
            return status! < 500;
          },
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) {
        String message = 'Terjadi kesalahan koneksi';

        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          message = 'Koneksi timeout. Silakan cek koneksi Anda.';
        } else if (error.type == DioExceptionType.connectionError) {
          message = 'Tidak dapat terhubung ke server. Pastikan backend aktif.';
        } else if (error.response?.data != null &&
            error.response?.data is Map) {
          message = error.response?.data['message'] ?? error.message;
        } else {
          message = error.message ?? 'Terjadi kesalahan tidak dikenal';
        }

        error = error.copyWith(message: message);
        return handler.next(error);
      },
    ));
  }

  Future<Response> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        Config.loginEndpoint,
        data: {
          'identifier': identifier,
          'password': password,
        },
        options: Options(
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return response;
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  Future<Response> getProfile(String token, {bool silent = false}) async {
    return await _dio.get(Config.profileEndpoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
  }

  Future<Response> refreshToken(String token) async {
    return await _dio.post(Config.refreshTokenEndpoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
  }

  Future<Response> logout(String token) async {
    return await _dio.post(Config.logoutEndpoint,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
  }

  Future<Response> updateProfile(
      String token, Map<String, dynamic> updateData) async {
    return await _dio.put(Config.updateProfileEndpoint,
        data: updateData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
  }

  Future<Response> updateProfilePhoto(String token, FormData formData) async {
    return await _dio.post(Config.updatePhotoEndpoint,
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
        }));
  }

  Future<Response> register(Map<String, dynamic> userData) async {
    return await _dio.post(Config.registerEndpoint, data: userData);
  }

  Future<Response> registerFcmToken(
      String token, Map<String, dynamic> tokenData) async {
    return await _dio.post(
      '/api/fcm/token',
      data: tokenData,
      options: Options(headers: {
        'Authorization': 'Bearer $token',
      }),
    );
  }
}
