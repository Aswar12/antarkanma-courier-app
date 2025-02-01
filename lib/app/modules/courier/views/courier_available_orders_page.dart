import 'package:antarkanma/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma/app/controllers/courier_controller.dart';
import 'package:antarkanma/app/modules/courier/views/courier_order_detail_page.dart';

class CourierAvailableOrdersPage extends GetView<CourierController> {
  const CourierAvailableOrdersPage({super.key});

  Map<String, dynamic> _convertOrderToMap(order) {
    final merchantGroups = order.getItemsByMerchant();
    final merchants = merchantGroups.values.map((items) {
      final merchant = items.first.merchant;
      return {
        'name': merchant.name ?? '',
        'address': merchant.address ?? '',
        'items': items.map((item) => {
          'name': item.name,
          'quantity': item.quantity,
        }).toList(),
      };
    }).toList();

    return {
      'orderId': order.id,
      'earnings': order.formattedTotalAmount,
      'distance': '0',
      'estimatedTime': '0',
      'merchants': merchants,
      'customerName': order.transaction?.user?.name ?? 'Pelanggan',
      'customerPhone': order.transaction?.user?.phone ?? '-',
      'deliveryAddress': order.transaction?.userLocation?.address ?? 'Alamat tidak tersedia',
      'notes': order.transaction?.note,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor3,
      appBar: AppBar(
        backgroundColor: backgroundColor2,
        title: Text(
          'Orderan Tersedia',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: medium,
          ),
        ),
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(
        () => controller.availableOrders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hourglass_empty,
                      size: 50,
                      color: secondaryTextColor,
                    ),
                    SizedBox(height: Dimenssions.height16),
                    Text(
                      'Belum ada orderan tersedia',
                      style: secondaryTextStyle.copyWith(
                        fontSize: 16,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: () async {
                  await controller.loadAvailableOrders();
                },
                child: ListView.builder(
                  padding: EdgeInsets.all(Dimenssions.width16),
                  itemCount: controller.availableOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.availableOrders[index];
                    final merchantGroups = order.getItemsByMerchant();
                    return InkWell(
                      onTap: () =>
                          Get.to(CourierOrderDetailPage(order: _convertOrderToMap(order))),
                      child: Container(
                        margin: EdgeInsets.only(bottom: Dimenssions.height16),
                        padding: EdgeInsets.all(Dimenssions.width16),
                        decoration: BoxDecoration(
                          color: backgroundColor2,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.id}',
                                  style: primaryTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: semiBold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimenssions.width12,
                                    vertical: Dimenssions.height6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: logoColorSecondary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    order.formattedTotalAmount,
                                    style: priceTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Dimenssions.height12),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimenssions.width8,
                                vertical: Dimenssions.height4,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${merchantGroups.length} Merchant',
                                style: primaryTextStyle.copyWith(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: medium,
                                ),
                              ),
                            ),
                            SizedBox(height: Dimenssions.height12),
                            if (merchantGroups.isNotEmpty) ...[
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: merchantGroups.length,
                                itemBuilder: (context, merchantIndex) {
                                  final merchantItems = merchantGroups.values.elementAt(merchantIndex);
                                  final merchant = merchantItems.first.merchant;
                                  return Padding(
                                    padding: EdgeInsets.only(
                                        bottom: Dimenssions.height8),
                                    child: _buildLocationInfo(
                                      'Pickup ${merchantIndex + 1}',
                                      merchant.address ?? '',
                                      Icons.store,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: Dimenssions.height8),
                            ],
                            _buildLocationInfo(
                              'Delivery',
                              order.transaction?.userLocation?.address ?? 'Alamat tidak tersedia',
                              Icons.location_on,
                            ),
                            SizedBox(height: Dimenssions.height12),
                            Row(
                              children: [
                                _buildInfoChip(
                                  '0 km',
                                  Icons.directions_bike,
                                ),
                                SizedBox(width: Dimenssions.width12),
                                _buildInfoChip(
                                  '0 min',
                                  Icons.access_time,
                                ),
                              ],
                            ),
                            SizedBox(height: Dimenssions.height12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Get.to(CourierOrderDetailPage(order: _convertOrderToMap(order))),
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimenssions.width16,
                                      vertical: Dimenssions.height8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Lihat Detail',
                                        style: primaryTextStyle.copyWith(
                                          color: logoColorSecondary,
                                          fontWeight: medium,
                                        ),
                                      ),
                                      SizedBox(width: Dimenssions.width4),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 14,
                                        color: logoColorSecondary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildLocationInfo(String title, String address, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: secondaryTextColor,
        ),
        SizedBox(width: Dimenssions.width8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: secondaryTextStyle.copyWith(
                  fontSize: 12,
                ),
              ),
              Text(
                address,
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimenssions.width8,
        vertical: Dimenssions.height4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor4,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: secondaryTextColor,
          ),
          SizedBox(width: Dimenssions.width4),
          Text(
            text,
            style: secondaryTextStyle.copyWith(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
