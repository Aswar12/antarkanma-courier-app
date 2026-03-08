import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart' hide Response, FormData, MultipartFile;
import 'package:get/get.dart';
import '../../config.dart';
import '../services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class WalletProvider extends GetConnect {
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

  /// Submit topup request with payment proof
  Future<Response> submitTopup(double amount, File proof) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/courier/wallet/topups'),
      );

      // Add auth header
      final token = _authService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';

      // Add fields
      request.fields['amount'] = amount.toString();

      // Add file
      var file = await http.MultipartFile.fromPath(
        'payment_proof',
        proof.path,
        filename: basename(proof.path),
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(file);

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // Parse response body as JSON Map (not raw String)
      Map<String, dynamic>? parsedBody;
      try {
        parsedBody = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        parsedBody = null;
      }

      return Response(
        body: parsedBody,
        statusCode: response.statusCode,
        statusText: response.statusCode == 200 || response.statusCode == 201
            ? 'Success'
            : 'Error',
      );
    } catch (e) {
      return Response(
        body: null,
        statusCode: 500,
        statusText: 'Error: $e',
      );
    }
  }

  /// Get topup history
  Future<Response> getTopupHistory({int page = 1, int perPage = 20}) async {
    return get(
      '/courier/wallet/topups',
      query: {
        'per_page': perPage.toString(),
      },
    );
  }

  /// Get topup detail
  Future<Response> getTopupDetail(int id) async {
    return get('/courier/wallet/topups/$id');
  }

  /// Get courier wallet balance
  Future<Response> getWalletBalance() async {
    return get('/courier/wallet/balance');
  }

  /// Get QRIS code
  Future<Response> getQrisCode() async {
    return get('/courier/wallet/qris');
  }

  /// Download QRIS code and save to device
  Future<String?> downloadQrisCode() async {
    try {
      final token = _authService.getToken();
      final downloadUrl = '${Config.baseUrl}/courier/wallet/qris/download';

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
      };

      // Get device downloads directory
      // Android: /storage/emulated/0/Download
      // Fallback: app temp dir
      String savePath;
      if (Platform.isAndroid) {
        savePath = '/storage/emulated/0/Download/qris-antarkanma.png';
      } else {
        final tempDir = Directory.systemTemp;
        savePath = '${tempDir.path}/qris-antarkanma.png';
      }

      await dio.download(downloadUrl, savePath);

      return savePath;
    } catch (e) {
      print('Download QRIS error: $e');
      return null;
    }
  }
}
