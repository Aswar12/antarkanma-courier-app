import 'package:get/get.dart';
import '../../config.dart';
import '../services/auth_service.dart';

class CourierProvider extends GetConnect {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
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

  // ── Daftar transaksi baru yang tersedia (READY_FOR_PICKUP) ─────────────────
  Future<Response> getNewTransactions(double latitude, double longitude) {
    return get('/courier/new-transactions', query: {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
    });
  }

  // ── Daftar transaksi kurir ini ─────────────────────────────────────────────
  Future<Response> getMyTransactions() {
    return get('/courier/my-transactions');
  }

  Future<Response> getTransactionStatusCounts() {
    return get('/courier/transactions/status-counts');
  }

  // ── Approve / Reject transaksi ────────────────────────────────────────────
  Future<Response> approveTransaction(dynamic id) {
    return post('/courier/transactions/$id/approve', {});
  }

  Future<Response> rejectTransaction(dynamic id) {
    return post('/courier/transactions/$id/reject', {});
  }

  // ── Accept transaksi (untuk order yang sudah READY_FOR_PICKUP) ────────────
  Future<Response> acceptTransaction(dynamic transactionId) {
    return post('/courier/transactions/$transactionId/approve', {});
  }

  // ── Tracking posisi kurir (real-time) ─────────────────────────────────────
  /// Kurir lapor sudah sampai di merchant
  Future<Response> arriveAtMerchant(dynamic transactionId) {
    return post('/courier/transactions/$transactionId/arrive-merchant', {});
  }

  /// Kurir lapor sudah sampai di lokasi customer
  Future<Response> arriveAtCustomer(dynamic transactionId) {
    return post('/courier/transactions/$transactionId/arrive-customer', {});
  }

  // ── Aksi per-Order ────────────────────────────────────────────────────────
  /// Pickup 1 order (bisa partial untuk multi-merchant)
  Future<Response> pickupOrder(dynamic orderId) {
    return post('/courier/orders/$orderId/pickup', {});
  }

  /// Selesaikan 1 order (auto-complete Transaction jika semua order selesai)
  Future<Response> completeOrder(dynamic orderId) {
    return post('/courier/orders/$orderId/complete', {});
  }

  // ── Wallet & Statistics ───────────────────────────────────────────────────
  /// Get courier wallet balance
  Future<Response> getWalletBalance() {
    return get('/courier/wallet/balance');
  }

  /// Get daily statistics (total orders, completed, earnings, avg delivery time)
  Future<Response> getDailyStatistics() {
    return get('/courier/statistics/daily');
  }
}
