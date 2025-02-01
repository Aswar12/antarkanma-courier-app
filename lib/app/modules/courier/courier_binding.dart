import 'package:get/get.dart';
import '../../services/courier_service.dart';
import '../../services/user_location_service.dart';
import '../../controllers/courier_controller.dart';

class CourierBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<UserLocationService>(UserLocationService());
    Get.put<CourierController>(CourierController());
  }
}
