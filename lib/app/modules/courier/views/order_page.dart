import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import '../../../../theme.dart';
import '../../../controllers/main_controller.dart';

class OrderPage extends GetView<MainController> {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab Bar
          Container(
            color: backgroundColor1,
            child: TabBar(
              labelColor: primaryColor,
              unselectedLabelColor: secondaryTextColor,
              indicatorColor: primaryColor,
              tabs: const [
                Tab(text: 'Dalam Proses'),
                Tab(text: 'Selesai'),
              ],
            ),
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              children: [
                // Active Orders Tab
                _buildOrderList(true),
                // Completed Orders Tab
                _buildOrderList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(bool isActive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? Icons.local_shipping_outlined : Icons.check_circle_outline,
            size: utils.Dimensions.height48,
            color: secondaryTextColor,
          ),
          SizedBox(height: utils.Dimensions.height8),
          Text(
            isActive ? 'Belum ada pesanan aktif' : 'Belum ada pesanan selesai',
            style: secondaryTextStyle.copyWith(
              fontSize: utils.Dimensions.font14,
            ),
          ),
        ],
      ),
    );
  }
}
