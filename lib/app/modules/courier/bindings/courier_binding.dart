import 'package:get/get.dart';
import '../../../controllers/main_controller.dart';
import '../../../controllers/courier_order_controller.dart';
import '../../../providers/courier_provider.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CourierProvider>(
      () => CourierProvider(),
    );
    Get.lazyPut<MainController>(
      () => MainController(),
    );
    Get.lazyPut<CourierOrderController>(
      () => CourierOrderController(),
    );
  }
}
