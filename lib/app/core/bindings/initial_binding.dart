import 'package:get/get.dart';
import 'package:antarkanma_courier/app/services/auth_service.dart';
import 'package:antarkanma_courier/app/services/storage_service.dart';
import 'package:antarkanma_courier/app/services/messaging_service.dart';
import 'package:antarkanma_courier/app/modules/auth/controllers/auth_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(StorageService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(MessagingService(), permanent: true);

    // Core Controllers
    Get.put(AuthController(), permanent: true);
  }
}
