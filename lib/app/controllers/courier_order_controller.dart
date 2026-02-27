import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/transaction_model.dart';
import 'package:antarkanma_courier/app/providers/courier_provider.dart';

class CourierOrderController extends GetxController {
  final CourierProvider _courierProvider = Get.find<CourierProvider>();

  final RxList<TransactionModel> activeOrders = <TransactionModel>[].obs;
  final RxList<TransactionModel> completedOrders = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingCompleted = false.obs;

  // Loading state per action
  final RxMap<String, bool> loadingActions = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchActiveOrders();
    fetchCompletedOrders();
    _setupFCMListener();
  }

  // ── FCM Listener: auto-refresh tanpa pull-to-refresh ──────────────────────
  void _setupFCMListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final type = message.data['type'] as String?;

      // Semua event ini perlu refresh data kurir
      const refreshEvents = [
        'order_ready',
        'courier_found',
        'order_assigned',
        'order_picked_up',
        'order_completed',
        'courier_arrived_at_merchant',
      ];

      if (type != null && refreshEvents.contains(type)) {
        refresh();

        // Tampilkan snackbar info
        final title = message.notification?.title ?? 'Update Pesanan';
        final body = message.notification?.body ?? '';
        if (body.isNotEmpty) {
          Get.snackbar(
            title,
            body,
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.blue.shade700,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(8),
          );
        }
      }
    });
  }

  // ── Fetch Data ─────────────────────────────────────────────────────────────
  Future<void> fetchActiveOrders() async {
    try {
      isLoading.value = true;
      final response = await _courierProvider.getMyTransactions();

      if (response.status.hasError) {
        debugPrint('Error fetching active orders: ${response.statusText}');
        return;
      }

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        final data = response.body['data']['data'] as List;

        final List<TransactionModel> parsedTransactions = [];
        for (var json in data) {
          try {
            parsedTransactions.add(TransactionModel.fromJson(json));
          } catch (e) {
            debugPrint('Error parsing transaction: $e');
          }
        }

        // Aktif = belum COMPLETED/CANCELED
        activeOrders.value = parsedTransactions
            .where((t) => t.status != 'COMPLETED' && t.status != 'CANCELED')
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching active orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCompletedOrders() async {
    try {
      isLoadingCompleted.value = true;
      final response = await _courierProvider.getMyTransactions();

      if (response.status.hasError) {
        debugPrint('Error fetching completed orders: ${response.statusText}');
        return;
      }

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        final data = response.body['data']['data'] as List;

        final List<TransactionModel> parsedTransactions = [];
        for (var json in data) {
          try {
            parsedTransactions.add(TransactionModel.fromJson(json));
          } catch (e) {
            debugPrint('Error parsing transaction: $e');
          }
        }

        completedOrders.value = parsedTransactions
            .where((t) => t.status == 'COMPLETED' || t.status == 'CANCELED')
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching completed orders: $e');
    } finally {
      isLoadingCompleted.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchActiveOrders();
    await fetchCompletedOrders();
  }

  // ── Aksi Kurir Tracking ────────────────────────────────────────────────────

  /// Kurir tap "Terima Pesanan" (approve transaction)
  Future<void> acceptTransaction(dynamic transactionId) async {
    final key = 'accept_$transactionId';
    if (loadingActions[key] == true) return;

    try {
      loadingActions[key] = true;
      final response = await _courierProvider.acceptTransaction(transactionId);

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        await refresh();
        Get.snackbar(
          '✅ Pesanan Diterima',
          'Silakan menuju merchant untuk mengambil pesanan.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          '❌ Gagal',
          response.body?['meta']['message'] ?? 'Gagal menerima pesanan',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error acceptTransaction: $e');
      Get.snackbar('❌ Error', 'Terjadi kesalahan. Coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      loadingActions.remove(key);
    }
  }

  /// Kurir tap "Saya Sudah di Merchant"
  Future<void> arriveAtMerchant(dynamic transactionId) async {
    final key = 'arrive_merchant_$transactionId';
    if (loadingActions[key] == true) return;

    try {
      loadingActions[key] = true;
      final response = await _courierProvider.arriveAtMerchant(transactionId);

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        await refresh();
        Get.snackbar(
          '✅ Lokasi Diupdate',
          'Merchant diberitahu bahwa Anda sudah tiba.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          '❌ Gagal',
          response.body?['meta']['message'] ?? 'Gagal update status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error arriveAtMerchant: $e');
      Get.snackbar('❌ Error', 'Terjadi kesalahan. Coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      loadingActions.remove(key);
    }
  }

  /// Kurir tap "Ambil Pesanan ini" (per-order)
  Future<void> pickupOrder(dynamic orderId) async {
    final key = 'pickup_$orderId';
    if (loadingActions[key] == true) return;

    try {
      loadingActions[key] = true;
      final response = await _courierProvider.pickupOrder(orderId);

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        final data = response.body['data'];
        final allPickedUp = data['all_picked_up'] == true;
        await refresh();
        Get.snackbar(
          '✅ Pesanan Diambil',
          allPickedUp
              ? 'Semua pesanan sudah diambil. Silakan menuju customer.'
              : 'Pesanan diambil. Lanjutkan ke merchant berikutnya.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          '❌ Gagal',
          response.body?['meta']['message'] ?? 'Gagal pickup order',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error pickupOrder: $e');
      Get.snackbar('❌ Error', 'Terjadi kesalahan. Coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      loadingActions.remove(key);
    }
  }

  /// Kurir tap "Saya Sudah di Lokasi Customer"
  Future<void> arriveAtCustomer(dynamic transactionId) async {
    final key = 'arrive_customer_$transactionId';
    if (loadingActions[key] == true) return;

    try {
      loadingActions[key] = true;
      final response = await _courierProvider.arriveAtCustomer(transactionId);

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        await refresh();
        Get.snackbar(
          '✅ Lokasi Diupdate',
          'Customer diberitahu bahwa Anda sudah tiba.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          '❌ Gagal',
          response.body?['meta']['message'] ?? 'Gagal update status',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error arriveAtCustomer: $e');
      Get.snackbar('❌ Error', 'Terjadi kesalahan. Coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      loadingActions.remove(key);
    }
  }

  /// Kurir tap "Selesaikan Order ini" (per-order)
  Future<void> completeOrder(dynamic orderId) async {
    final key = 'complete_$orderId';
    if (loadingActions[key] == true) return;

    try {
      loadingActions[key] = true;
      final response = await _courierProvider.completeOrder(orderId);

      if (response.body != null &&
          response.body['meta']['status'] == 'success') {
        final data = response.body['data'];
        final transactionCompleted = data['transaction_completed'] == true;
        await refresh();
        Get.snackbar(
          transactionCompleted ? '🎉 Transaksi Selesai!' : '✅ Order Selesai',
          transactionCompleted
              ? 'Semua pesanan berhasil diantarkan. Kerja bagus!'
              : 'Order diselesaikan. Lanjutkan ke order berikutnya.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else {
        Get.snackbar(
          '❌ Gagal',
          response.body?['meta']['message'] ?? 'Gagal menyelesaikan order',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint('Error completeOrder: $e');
      Get.snackbar('❌ Error', 'Terjadi kesalahan. Coba lagi.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      loadingActions.remove(key);
    }
  }
}
