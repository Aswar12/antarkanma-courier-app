import 'package:dio/dio.dart';
import 'package:antarkanma_courier/config.dart';
import 'package:flutter/foundation.dart';

class FcmProvider {
  final Dio _dio;

  FcmProvider() : _dio = Dio(BaseOptions(
    baseUrl: Config.baseUrl,
    connectTimeout: Duration(seconds: Config.connectTimeout),
    receiveTimeout: Duration(seconds: Config.receiveTimeout),
    validateStatus: (status) {
      return status! < 500;
    },
  ));

  Future<Response> registerToken(Map<String, dynamic> tokenData, String authToken) async {
    debugPrint('Making API call to register FCM token...');
    debugPrint('Endpoint: /api/fcm/token');
    debugPrint('Request data: $tokenData');
    
    try {
      final response = await _dio.post(
        '/fcm/token', 
        data: tokenData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
      debugPrint('API Response status: ${response.statusCode}');
      debugPrint('API Response data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('API call failed: $e');
      if (e is DioException) {
        debugPrint('DioError response: ${e.response?.data}');
      }
      rethrow;
    }
  }

  Future<Response> unregisterToken(String token, String authToken) async {
    debugPrint('Making API call to unregister FCM token...');
    debugPrint('Endpoint: /api/fcm/token/$token');
    
    try {
      final response = await _dio.delete(
        '/fcm/token/$token',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
      debugPrint('API Response status: ${response.statusCode}');
      debugPrint('API Response data: ${response.data}');
      return response;
    } catch (e) {
      debugPrint('API call failed: $e');
      if (e is DioException) {
        debugPrint('DioError response: ${e.response?.data}');
      }
      rethrow;
    }
  }
}
