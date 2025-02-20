import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/user_model.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';
import 'package:antarkanma_courier/app/services/messaging_service.dart';

class MainController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final MessagingService _messagingService = Get.find<MessagingService>();
  
  // Observable variables
  final Rx<UserModel?> courierData = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;
  final RxBool hasOrders = false.obs;
  final RxInt currentIndex = 0.obs;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    fetchCourierData();
    fetchOrders();
    initializeMessaging();
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
    pageController.dispose();
    super.onClose();
  }

  Future<void> fetchCourierData() async {
    try {
      final userData = _authService.getCurrentUser();
      if (userData != null) {
        courierData.value = userData;
        debugPrint('Courier data fetched successfully: ${userData.displayName}');
      }
    } catch (e) {
      debugPrint('Error fetching courier data: $e');
    }
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API call
      hasOrders.value = false; // Set based on API response
      
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      hasOrders.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshOrders() async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: Replace with actual API call
      hasOrders.value = false; // Set based on API response
      
    } catch (e) {
      debugPrint('Error refreshing orders: $e');
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
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
