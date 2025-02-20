import 'package:get/get.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(StorageService(), permanent: true);
    Get.put(AuthService(), permanent: true);

    // Core Controllers
    Get.put(AuthController(), permanent: true);
  }
}
