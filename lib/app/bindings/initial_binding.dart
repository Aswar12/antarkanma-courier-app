import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../controllers/auth_controller.dart';
import '../modules/splash/controllers/splash_controller.dart';
import '../services/auth_service.dart';
import '../services/transaction_service.dart';
import '../services/notification_service.dart';
import '../services/fcm_token_service.dart';
import '../services/courier_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    debugPrint('Initializing dependencies...');

    // Services - Order matters due to dependencies
    debugPrint('Initializing AuthService...');
    Get.put(AuthService(), permanent: true);

    debugPrint('Initializing TransactionService...');
    Get.put(TransactionService(), permanent: true);

    debugPrint('Initializing CourierService...');
    Get.put(CourierService(), permanent: true);

    debugPrint('Initializing FCMTokenService...');
    Get.putAsync(() => FCMTokenService().init(), permanent: true);

    debugPrint('Initializing NotificationService...');
    Get.putAsync(() => NotificationService().init(), permanent: true);

    // Controllers
    debugPrint('Initializing SplashController...');
    Get.put(SplashController(), permanent: true);

    debugPrint('Initializing AuthController...');
    Get.put(AuthController(), permanent: true);

    debugPrint('Dependencies initialization complete');
  }
}
