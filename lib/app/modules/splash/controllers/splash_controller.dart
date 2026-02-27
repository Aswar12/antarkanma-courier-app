import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';

class SplashController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final AuthService _authService = Get.find<AuthService>();

  // Observable for splash animation
  final RxBool isInitializing = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSplash();
  }

  void _initSplash() async {
    print('=== COURIER SPLASH: Starting initialization ===');

    try {
      // Show animation first
      isInitializing.value = true;
      await Future.delayed(const Duration(milliseconds: 500));

      print('=== Checking fast path: isLoggedIn=${_authService.isLoggedIn.value} ===');
      if (_authService.isLoggedIn.value &&
          _authService.getCurrentUser()?.isCourier == true) {
        print('Fast path: User is logged in as courier, navigating to main');
        Get.offAllNamed(Routes.main);
        return;
      }

      print('=== Checking auto-login eligibility ===');
      final bool autoLoginSuccess = await _authController.tryAutoLogin();
      print('Auto-login result: $autoLoginSuccess');

      if (autoLoginSuccess) {
        final UserModel? userData = _authController.getCurrentUser();
        print('User role after auto-login: ${userData?.role}');

        if (userData?.isCourier ?? false) {
          print('Auto-login success, navigating to main');
          Get.offAllNamed(Routes.main);
        } else {
          print('User is not courier, logging out and going to login');
          await _authController.logout();
          Get.offAllNamed(Routes.login);
          Get.snackbar(
            'Akses Ditolak',
            'Aplikasi ini hanya untuk kurir',
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        print('Auto-login failed, navigating to login');
        Get.offAllNamed(Routes.login);
      }
    } catch (e, stackTrace) {
      print('Error in splash controller: $e');
      print('Stack trace: $stackTrace');
      Get.offAllNamed(Routes.login);
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat memeriksa sesi login',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      print('=== COURIER SPLASH: Initialization complete ===');
    }
  }
}
