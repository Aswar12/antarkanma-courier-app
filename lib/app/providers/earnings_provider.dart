import 'package:get/get.dart';
import '../../config.dart';
import '../services/auth_service.dart';

class EarningsProvider extends GetConnect {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = Config.baseUrl;
    httpClient.timeout = Duration(seconds: Config.connectTimeout);

    httpClient.addRequestModifier<dynamic>((request) {
      final token = _authService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      return request;
    });
  }

  /// Get courier earnings analytics
  Future<Response> getEarnings({
    String period = 'daily',
    String? from,
    String? to,
  }) {
    final params = <String, String>{
      'period': period,
      if (from != null) 'from': from,
      if (to != null) 'to': to,
    };
    return get('/courier/analytics/earnings', query: params);
  }

  /// Get courier performance overview
  Future<Response> getPerformance() {
    return get('/courier/analytics/performance');
  }
}
