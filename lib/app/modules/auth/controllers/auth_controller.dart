import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/user_model.dart';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:antarkanma_courier/app/services/messaging_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  // Form key untuk validasi
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Observable variables
  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> _initializeAuth() async {
    try {
      await _authService.ensureInitialized();

      // Check if user is already logged in
      if (_authService.isLoggedIn.value) {
        Get.offAllNamed(Routes.main);
      }
    } catch (e) {
      debugPrint('Error initializing auth: $e');
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  // Auto login function
  Future<bool> tryAutoLogin() async {
    print('=== AuthController.tryAutoLogin() called ===');
    try {
      isLoading.value = true;

      final credentials = await _authService.getCredentials();
      print('Credentials retrieved: ${credentials != null}');
      
      if (credentials == null) {
        print('No credentials found, auto-login aborted');
        return false;
      }

      print('Attempting auto-login with: ${credentials.identifier}');
      // Try to login with saved credentials
      final result = await _authService.login(
        credentials.identifier,
        credentials.password,
      );
      print('Auto-login result: $result');
      return result;
    } catch (e) {
      print('Error during auto login: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  // Get current user data
  UserModel? getCurrentUser() {
    return _authService.getCurrentUser();
  }

  Future<void> login() async {
    print('=== AuthController.login() called ===');
    if (!formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    try {
      isLoading.value = true;
      print('Calling authService.login...');

      final success = await _authService.login(
        emailController.text,
        passwordController.text,
      );

      if (success) {
        print('Login successful, navigating to main page');
        Get.offAllNamed(Routes.main);
      } else {
        print('Login failed - keeping form data for user to retry');
        // Don't clear form - let user retry with same email/password
      }
    } catch (e) {
      print('Error during login: $e');
      // Don't clear form on error - let user retry
    } finally {
      isLoading.value = false;
      print('=== AuthController.login() complete ===');
    }
  }


  Future<void> logout() async {
    try {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          final messagingService = Get.find<MessagingService>();
          await messagingService.unregisterFcmToken(fcmToken);
        }
      } catch (e) {
        debugPrint('Error unregistering FCM token: $e');
      }

      await _authService.logout();
      // Navigasi di-handle oleh caller (MainController atau view)
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
