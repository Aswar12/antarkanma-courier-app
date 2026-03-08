import 'package:get/get.dart';
import 'package:antarkanma_courier/app/providers/wallet_provider.dart';
import 'package:antarkanma_courier/app/controllers/wallet_controller.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy get untuk provider (dibuat saat pertama kali dipanggil)
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    
    // Lazy get untuk controller
    Get.lazyPut<WalletController>(() => WalletController());
  }
}
