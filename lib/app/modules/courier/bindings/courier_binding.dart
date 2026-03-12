import 'package:get/get.dart';
import '../../../controllers/main_controller.dart';
import '../../../controllers/courier_order_controller.dart';
import '../../../providers/courier_provider.dart';
import '../../chat/controllers/chat_list_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut<CourierProvider>(
      () => CourierProvider(),
    );
    
    // Main Controller - permanent karena digunakan di seluruh halaman
    Get.put<MainController>(
      MainController(),
      permanent: true,
    );
    
    // Courier Order Controller
    Get.put<CourierOrderController>(
      CourierOrderController(),
      permanent: true,
    );
    
    // Chat List Controller - permanent untuk menghindari re-inisialisasi
    Get.put<ChatListController>(
      ChatListController(),
      permanent: true,
    );
  }
}
