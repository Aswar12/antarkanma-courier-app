import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:antarkanma/config.dart';
import 'package:antarkanma/app/services/storage_service.dart';
import 'package:antarkanma/app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:antarkanma/app/widgets/custom_snackbar.dart';

class CourierProvider {
  final dio.Dio _dio = dio.Dio();
  final String baseUrl = Config.baseUrl;
  final StorageService _storageService = StorageService.instance;

  CourierProvider() {
    _setupBaseOptions();
    _setupInterceptors();
  }

  void _setupBaseOptions() {
    _dio.options = dio.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => true,
    );
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storageService.getToken();

          if (token != null) {
            options.headers.addAll({
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            });
          }

          debugPrint('\n=== API Request ===');
          debugPrint('URL: ${options.baseUrl}${options.path}');
          debugPrint('Method: ${options.method}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Data: ${options.data}');

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          debugPrint('\n=== API Response ===');
          debugPrint('Status code: ${response.statusCode}');
          debugPrint('Data: ${response.data}');

          return handler.next(response);
        },
        onError: (dio.DioException error, handler) async {
          debugPrint('\n=== API Error ===');
          debugPrint('Status code: ${error.response?.statusCode}');
          debugPrint('Error data: ${error.response?.data}');
          debugPrint('Error message: ${error.message}');

          if (error.response?.statusCode == 401) {
            try {
              final authService = Get.find<AuthService>();
              authService.handleAuthError(error);
            } catch (e) {
              debugPrint('Failed to handle auth error: $e');
            }
          }

          return handler.next(error);
        },
      ),
    );
  }

  void _handleError(dio.DioException error) {
    String message;
    switch (error.response?.statusCode) {
      case 401:
        message = 'Sesi anda telah berakhir. Silakan login kembali.';
        break;
      case 422:
        final data = error.response?.data;
        if (data != null && data['meta']?['message'] != null) {
          message = data['meta']['message'];
        } else {
          message = 'Validasi gagal';
        }
        break;
      case 403:
        message = 'Anda tidak memiliki akses ke halaman ini.';
        break;
      case 404:
        message = 'Data tidak ditemukan.';
        break;
      case 500:
        message =
            'Terjadi kesalahan pada server. Silakan coba beberapa saat lagi.';
        break;
      default:
        if (error.type == dio.DioExceptionType.connectionTimeout) {
          message = 'Koneksi timeout. Silakan periksa koneksi internet Anda.';
        } else if (error.type == dio.DioExceptionType.receiveTimeout) {
          message = 'Server tidak merespons. Silakan coba lagi.';
        } else {
          message = error.response?.data?['message'] ??
              'Terjadi kesalahan yang tidak diketahui';
        }
    }

    CustomSnackbarX.showError(
      title: 'Error',
      message: message,
      position: SnackPosition.BOTTOM,
    );
    throw Exception(message);
  }

  Future<dio.Response> getCourierProfile() async {
    try {
      debugPrint('\n=== Getting Courier Profile ===');
      final response = await _dio.get('/api/courier/profile');

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> updateCourierProfile({
    required String name,
    required String phoneNumber,
    required String vehicleType,
    required String licensePlate,
  }) async {
    try {
      debugPrint('\n=== Updating Courier Profile ===');
      final response = await _dio.put(
        '/api/courier/profile',
        data: {
          'name': name,
          'phone_number': phoneNumber,
          'vehicle_type': vehicleType,
          'license_plate': licensePlate,
        },
      );

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> uploadProfilePhoto(dio.FormData formData) async {
    try {
      debugPrint('\n=== Uploading Profile Photo ===');
      final response = await _dio.post(
        '/api/courier/profile/photo',
        data: formData,
        options: dio.Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getActiveDeliveries({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      debugPrint('\n=== Getting Active Deliveries ===');
      final response = await _dio.get(
        '/api/courier/deliveries/active',
        queryParameters: {
          'page': page,
          'page_size': pageSize,
          'include': 'transaction.items.merchant,transaction.user_location',
        },
      );

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getDeliveryHistory({
    int page = 1,
    int pageSize = 10,
    String? status,
  }) async {
    try {
      debugPrint('\n=== Getting Delivery History ===');
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        'include': 'transaction.items.merchant,transaction.user_location',
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '/api/courier/deliveries/history',
        queryParameters: queryParams,
      );

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> updateDeliveryStatus(
    String deliveryId,
    String status, {
    String? notes,
    Map<String, dynamic>? location,
  }) async {
    try {
      debugPrint('\n=== Updating Delivery Status ===');
      final data = {
        'status': status,
        if (notes != null) 'notes': notes,
        if (location != null) 'location': location,
      };

      final response = await _dio.put(
        '/api/courier/deliveries/$deliveryId/status',
        data: data,
      );

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<dio.Response> getDeliveryStatistics() async {
    try {
      debugPrint('\n=== Getting Delivery Statistics ===');
      final response = await _dio.get('/api/courier/statistics');

      if (response.statusCode != 200) {
        _handleError(dio.DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: dio.DioExceptionType.badResponse,
        ));
      }

      return response;
    } on dio.DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }
}
