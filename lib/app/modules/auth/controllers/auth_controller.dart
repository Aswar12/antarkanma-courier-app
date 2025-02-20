import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/data/models/user_model.dart';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';

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
    try {
      isLoading.value = true;
      
      final credentials = await _authService.getCredentials();
      if (credentials == null) return false;

      // Try to login with saved credentials
      return await _authService.login(
        credentials.identifier,
        credentials.password,
      );
    } catch (e) {
      debugPrint('Error during auto login: $e');
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
    if (!formKey.currentState!.validate()) return;
    
    try {
      isLoading.value = true;
      
      final success = await _authService.login(
        emailController.text,
        passwordController.text,
      );
      
      if (success) {
        debugPrint('Login successful, navigating to main page');
        Get.offAllNamed(Routes.main);
      } else {
        debugPrint('Login failed, clearing form');
        emailController.clear();
        passwordController.clear();
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      emailController.clear();
      passwordController.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }
}
