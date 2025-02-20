import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';

class SplashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    _initSplash();
  }

  void _initSplash() async {
    try {
      // Show splash screen for minimum 3 seconds
      await Future.delayed(const Duration(seconds: 3));
      
      // Attempt auto login
      final bool autoLoginSuccess = await _authController.tryAutoLogin();
      
      if (autoLoginSuccess) {
        // Get current user data to check role
        final UserModel? userData = _authController.getCurrentUser();
        
        // Only allow courier role
        if (userData?.isCourier ?? false) {
          Get.offAllNamed(Routes.main);
        } else {
          // If not a courier, logout and go to login
          await _authController.logout();
          Get.offAllNamed(Routes.login);
          Get.snackbar(
            'Akses Ditolak',
            'Aplikasi ini hanya untuk kurir',
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      // If any error occurs during auto login, redirect to login
      Get.offAllNamed(Routes.login);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat auto login',
        snackPosition: SnackPosition.TOP,
      );
    }
  }
}
