import 'package:get/get.dart';
import 'package:antarkanma/app/data/models/order_model.dart';

class CourierController extends GetxController {
  final RxList<OrderModel> availableOrders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAvailableOrders();
  }

  Future<void> loadAvailableOrders() async {
    try {
      isLoading.value = true;
      // TODO: Implement API call to get available orders
      // For now, using empty list
      availableOrders.value = [];
    } catch (e) {
      print('Error loading available orders: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      // TODO: Implement API call to accept order
      print('Accepting order: $orderId');
      await loadAvailableOrders(); // Refresh list after accepting
    } catch (e) {
      print('Error accepting order: $e');
    }
  }

  Future<void> rejectDelivery(String orderId) async {
    try {
      // TODO: Implement API call to reject order
      print('Rejecting order: $orderId');
      await loadAvailableOrders(); // Refresh list after rejecting
    } catch (e) {
      print('Error rejecting order: $e');
    }
  }
}
