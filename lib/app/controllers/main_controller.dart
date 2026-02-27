import 'dart:async';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/user_model.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';
import 'package:antarkanma_courier/app/services/messaging_service.dart';
import 'package:antarkanma_courier/app/data/models/transaction_model.dart';
import 'package:antarkanma_courier/app/providers/courier_provider.dart';
import 'package:geolocator/geolocator.dart';

class MainController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final MessagingService _messagingService = Get.find<MessagingService>();
  final CourierProvider _courierProvider = Get.find<CourierProvider>();

  // Observable variables
  final Rx<UserModel?> courierData = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxList<TransactionModel> incomingTransactions =
      <TransactionModel>[].obs;
  final RxBool hasOrders = false.obs;
  final RxInt currentIndex = 0.obs;
  late PageController pageController;
  Timer? _pollingTimer;

  // Daily statistics
  final RxInt totalOrdersToday = 0.obs;
  final RxInt completedOrdersToday = 0.obs;
  final RxDouble totalEarningsToday = 0.0.obs;
  final RxDouble avgDeliveryTime = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    fetchCourierData();
    fetchOrders();
    fetchDailyStats();
    _startPolling();
    initializeMessaging();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchOrders(isBackground: true);
      fetchDailyStats();
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> initializeMessaging() async {
    try {
      await _messagingService.init();
      debugPrint('FCM messaging initialized successfully');
    } catch (e) {
      debugPrint('Error initializing FCM messaging: $e');
    }
  }

  @override
  void onClose() {
    _stopPolling();
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchCourierData() async {
    try {
      final userData = _authService.getCurrentUser();
      if (userData != null) {
        courierData.value = userData;
        debugPrint(
            'Courier data fetched successfully: ${userData.displayName}');
      }
    } catch (e) {
      debugPrint('Error fetching courier data: $e');
    }
  }

  Future<void> fetchOrders({bool isBackground = false}) async {
    try {
      if (!isBackground) {
        isLoading.value = true;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        hasOrders.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          hasOrders.value = false;
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            'Location permissions are permanently denied, we cannot request permissions.');
        hasOrders.value = false;
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      final response = await _courierProvider.getNewTransactions(
          position.latitude, position.longitude);

      if (response.status.hasError) {
        debugPrint('Error fetching orders: ${response.statusText}');
        hasOrders.value = false;
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
            debugPrint('Error parsing individual transaction: $e\nData: $json');
          }
        }

        incomingTransactions.value = parsedTransactions;
        hasOrders.value = incomingTransactions.isNotEmpty;
      } else {
        hasOrders.value = false;
      }
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      hasOrders.value = false;
    } finally {
      if (!isBackground) {
        isLoading.value = false;
      }
    }
  }

  Future<void> refreshOrders() async {
    await fetchOrders();
  }

  Future<void> fetchDailyStats() async {
    try {
      final response = await _courierProvider.getDailyStatistics();

      if (!response.status.hasError &&
          response.body != null &&
          response.body['meta']['status'] == 'success') {
        final data = response.body['data'];
        totalOrdersToday.value =
            int.tryParse('${data['total_orders'] ?? 0}') ?? 0;
        completedOrdersToday.value =
            int.tryParse('${data['completed_orders'] ?? 0}') ?? 0;
        totalEarningsToday.value =
            double.tryParse('${data['total_earnings'] ?? 0}') ?? 0.0;
        avgDeliveryTime.value =
            double.tryParse('${data['average_delivery_time'] ?? 0}') ?? 0.0;
      }
    } catch (e) {
      debugPrint('Error fetching daily stats: $e');
    }
  }

  Future<void> approveTransaction(TransactionModel transaction) async {
    try {
      // show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response =
          await _courierProvider.approveTransaction(transaction.id);
      Get.back(); // close dialog

      if (!response.status.hasError &&
          response.body != null &&
          response.body['meta']['status'] == 'success') {
        Get.snackbar(
          'Berhasil',
          'Pesanan #${transaction.id} telah Anda terima!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        // refresh list
        fetchOrders();
      } else {
        Get.snackbar(
          'Gagal',
          response.body?['meta']?['message'] ??
              'Terjadi kesalahan saat menyetujui pesanan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      debugPrint('Error approving transaction: $e');
      Get.snackbar('Error', 'Gagal menghubungi server.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> rejectTransaction(TransactionModel transaction) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await _courierProvider.rejectTransaction(transaction.id);
      Get.back();

      if (!response.status.hasError &&
          response.body != null &&
          response.body['meta']['status'] == 'success') {
        Get.snackbar(
          'Ditolak',
          'Pesanan #${transaction.id} telah Anda tolak.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        fetchOrders();
      } else {
        Get.snackbar(
          'Gagal',
          response.body?['meta']?['message'] ??
              'Terjadi kesalahan saat menolak pesanan.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      debugPrint('Error rejecting transaction: $e');
      Get.snackbar('Error', 'Gagal menghubungi server.',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> logout() async {
    try {
      // Get current FCM token before logout
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        // Unregister FCM token
        await _messagingService.unregisterFcmToken(fcmToken);
      }

      // Proceed with logout
      await _authService.logout();

      // Navigate to login page after logout completes
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
