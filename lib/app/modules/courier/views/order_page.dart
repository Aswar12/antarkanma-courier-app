import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../theme.dart';
import '../../../controllers/main_controller.dart';
import '../../../controllers/courier_order_controller.dart';
import '../../../data/models/transaction_model.dart';

class OrderPage extends GetView<MainController> {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CourierOrderController orderController =
        Get.find<CourierOrderController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor1,
        body: SafeArea(
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                // ── Header Title & Tab Bar ──────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width16,
                    vertical: Dimensions.height12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan Masuk',
                        style: primaryTextStyle.copyWith(
                          fontSize: Dimensions.font20,
                          fontWeight: bold,
                        ),
                      ),
                      SizedBox(height: Dimensions.height16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius:
                              BorderRadius.circular(Dimensions.radius12),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            color: primaryColor,
                            borderRadius:
                                BorderRadius.circular(Dimensions.radius12),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: secondaryTextColor,
                          labelStyle:
                              primaryTextStyle.copyWith(fontWeight: semiBold),
                          dividerColor: Colors.transparent,
                          padding: EdgeInsets.all(Dimensions.width4),
                          tabs: const [
                            Tab(text: 'Dalam Proses'),
                            Tab(text: 'Selesai'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Tab Bar View ─────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    children: [
                      // Active Orders Tab
                      Obx(() {
                        if (orderController.isLoading.value) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor));
                        }
                        if (orderController.activeOrders.isEmpty) {
                          return _buildEmptyState(true);
                        }
                        return _buildOrderList(orderController,
                            orderController.activeOrders, true);
                      }),
                      // Completed Orders Tab
                      Obx(() {
                        if (orderController.isLoadingCompleted.value) {
                          return Center(
                              child: CircularProgressIndicator(
                                  color: primaryColor));
                        }
                        if (orderController.completedOrders.isEmpty) {
                          return _buildEmptyState(false);
                        }
                        return _buildOrderList(orderController,
                            orderController.completedOrders, false);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isActive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(Dimensions.width20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isActive
                  ? Icons.local_shipping_outlined
                  : Icons.check_circle_outline,
              size: Dimensions.height48 + 12,
              color: secondaryTextColor.withValues(alpha: 0.5),
            ),
          ),
          SizedBox(height: Dimensions.height16),
          Text(
            isActive ? 'Belum ada pesanan aktif' : 'Belum ada pesanan selesai',
            style: secondaryTextStyle.copyWith(
              fontSize: Dimensions.font16,
              fontWeight: semiBold,
            ),
          ),
          SizedBox(height: Dimensions.height8),
          Text(
            isActive
                ? 'Tunggu sebentar, pesanan baru akan muncul di sini.'
                : 'Pesanan yang telah kamu selesaikan akan masuk di sini.',
            textAlign: TextAlign.center,
            style: secondaryTextStyle.copyWith(fontSize: Dimensions.font12),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(CourierOrderController controller,
      List<TransactionModel> orders, bool isActive) {
    return RefreshIndicator(
      color: primaryColor,
      backgroundColor: Colors.white,
      onRefresh: () async => await controller.refresh(),
      child: ListView.builder(
        padding: EdgeInsets.only(
          left: Dimensions.width16,
          right: Dimensions.width16,
          bottom: Dimensions.height20,
        ),
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final transaction = orders[index];
          return _buildTransactionCard(controller, transaction, isActive);
        },
      ),
    );
  }

  Widget _buildTransactionCard(CourierOrderController controller,
      TransactionModel transaction, bool isActive) {
    return Container(
      margin: EdgeInsets.only(bottom: Dimensions.height16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radius20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: ID + Status Badge ─────────────────────────────────
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width16,
                vertical: Dimensions.height12,
              ),
              decoration: BoxDecoration(
                color: _getStatusColorForHeader(transaction.courierStatus)
                    .withValues(alpha: 0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      // Copy order ID to clipboard
                      Clipboard.setData(ClipboardData(text: transaction.id.toString()));
                      Get.snackbar(
                        'Berhasil',
                        'Order ID #${transaction.id} disalin!',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: primaryColor,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                        margin: const EdgeInsets.all(16),
                        borderRadius: 8,
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long,
                            size: 16, color: secondaryTextColor),
                        SizedBox(width: Dimensions.width8),
                        Text(
                          '#${transaction.id}',
                          style: primaryTextStyle.copyWith(
                            fontSize: Dimensions.font14,
                            fontWeight: bold,
                          ),
                        ),
                        SizedBox(width: Dimensions.width4),
                        Icon(
                          Icons.copy,
                          size: 14,
                          color: secondaryTextColor.withOpacity(0.6),
                        ),
                      ],
                    ),
                  ),
                  _buildCourierStatusBadge(transaction.courierStatus),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(Dimensions.width16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Customer Info ────────────────────────────────────────────
                  if (transaction.user != null) ...[
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: primaryColor.withValues(alpha: 0.2),
                                width: 2),
                          ),
                          child: ClipOval(
                            child: transaction.user?.profilePhotoUrl != null
                                ? CachedNetworkImage(
                                    imageUrl:
                                        transaction.user!.profilePhotoUrl!,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: primaryColor.withValues(
                                              alpha: 0.5),
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      color: primaryColor,
                                      size: 24,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                          ),
                        ),
                        SizedBox(width: Dimensions.width12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.user?.name ?? 'Customer',
                                style: primaryTextStyle.copyWith(
                                  fontSize: Dimensions.font14,
                                  fontWeight: bold,
                                ),
                              ),
                              SizedBox(height: Dimensions.height4),
                              if (transaction.userLocation != null)
                                Row(
                                  children: [
                                    Icon(Icons.location_on_rounded,
                                        size: 14, color: primaryColor),
                                    SizedBox(width: Dimensions.width4),
                                    Expanded(
                                      child: Text(
                                        transaction.userLocation!.address,
                                        style: secondaryTextStyle.copyWith(
                                          fontSize: Dimensions.font12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _launchGoogleMaps(
                                        transaction.userLocation!.latitude,
                                        transaction.userLocation!.longitude,
                                      ),
                                      icon: Icon(
                                        Icons.directions,
                                        size: 16,
                                        color: primaryColor,
                                      ),
                                      tooltip: 'Navigasi ke Lokasi Customer',
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        if (isActive && transaction.courierStatus != 'IDLE')
                          Container(
                            margin: EdgeInsets.only(left: Dimensions.width8),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              onPressed: () {
                                Get.toNamed('/chat/${transaction.id}',
                                    arguments: {
                                      'chatId': null,
                                      'orderId': transaction.id,
                                      'transactionId': transaction.id,
                                    });
                              },
                              icon: Icon(
                                Icons.chat_bubble_outline,
                                color: primaryColor,
                                size: 20,
                              ),
                              tooltip: 'Chat Customer',
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: Dimensions.height16),
                  ],

                  // ── Daftar Order (per-merchant) ──────────────────────────────
                  if (transaction.orders.isNotEmpty) ...[
                    Container(
                      padding: EdgeInsets.all(Dimensions.width12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius:
                            BorderRadius.circular(Dimensions.radius12),
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.storefront,
                                  size: 16, color: secondaryTextColor),
                              SizedBox(width: Dimensions.width8),
                              Expanded(
                                child: Text(
                                  'Detail Pick-up (${transaction.orders.length} Merchant)',
                                  style: secondaryTextStyle.copyWith(
                                    fontSize: Dimensions.font12,
                                    fontWeight: semiBold,
                                  ),
                                ),
                              ),
                              // Navigation button to first merchant
                              if (transaction.orders.isNotEmpty &&
                                  transaction.orders.first.orderItems.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    final merchant =
                                        transaction.orders.first.orderItems.first
                                            .merchant;
                                    if (merchant.latitude != null &&
                                        merchant.longitude != null) {
                                      _launchGoogleMaps(
                                        merchant.latitude!,
                                        merchant.longitude!,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'Error',
                                        'Lokasi merchant tidak tersedia',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  icon: Icon(
                                    Icons.directions,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  tooltip: 'Navigasi ke Merchant',
                                  padding: EdgeInsets.zero,
                                  constraints: BoxConstraints(
                                    minWidth: 32,
                                    minHeight: 32,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: Dimensions.height12),
                          ...transaction.orders.map((order) => _buildOrderRow(
                                controller,
                                order,
                                transaction,
                                isActive,
                              )),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height16),
                  ],

                  // ── Total ─────────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Tagihan',
                          style: secondaryTextStyle.copyWith(
                              fontSize: Dimensions.font14)),
                      Text(
                        transaction.formattedGrandTotal,
                        style: primaryTextStyle.copyWith(
                          fontSize: Dimensions.font18,
                          fontWeight: bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  
                  // ── Penghasilan Courier ───────────────────────────────────────
                  SizedBox(height: Dimensions.height16),
                  Container(
                    padding: EdgeInsets.all(Dimensions.width12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(Dimensions.radius12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.wallet,
                              size: 18,
                              color: primaryColor,
                            ),
                            SizedBox(width: Dimensions.width8),
                            Text(
                              'Rincian Penghasilan',
                              style: primaryTextStyle.copyWith(
                                fontSize: Dimensions.font14,
                                fontWeight: bold,
                                color: primaryColor,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Dimensions.height12),
                        _buildEarningRow(
                          'Base Ongkir',
                          transaction.formattedShippingPrice,
                          isBold: false,
                        ),
                        SizedBox(height: Dimensions.height4),
                        _buildEarningRow(
                          'Platform Fee (10%)',
                          '- ${transaction.formattedPlatformFee}',
                          isBold: false,
                          isNegative: true,
                        ),
                        Divider(height: Dimensions.height20, color: Colors.grey.shade300),
                        _buildEarningRow(
                          'Penghasilan Anda',
                          transaction.formattedCourierEarning,
                          isBold: true,
                          isPrimary: true,
                        ),
                      ],
                    ),
                  ),

                  // ── Tombol Aksi Utama (berdasarkan courier_status) ───────────
                  if (isActive) ...[
                    SizedBox(height: Dimensions.height16),
                    _buildMainActionButton(controller, transaction),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Baris per-order: tampilkan status + tombol Pickup/Selesai
  Widget _buildOrderRow(
    CourierOrderController controller,
    OrderModel order,
    TransactionModel transaction,
    bool isActive,
  ) {
    return Obx(() {
      final isLoadingPickup =
          controller.loadingActions['pickup_${order.id}'] == true;
      final isLoadingComplete =
          controller.loadingActions['complete_${order.id}'] == true;

      // Determine visual states
      final bool isReadyForPickup = order.orderStatus == 'READY_FOR_PICKUP';
      final bool isPickedUp = order.orderStatus == 'PICKED_UP';
      final bool isCompleted = order.orderStatus == 'COMPLETED';

      // Outline matching status
      Color rowBorderColor = Colors.transparent;
      if (isReadyForPickup) rowBorderColor = Colors.orange.shade200;
      if (isPickedUp) rowBorderColor = Colors.blue.shade200;
      if (isCompleted) rowBorderColor = Colors.green.shade200;

      return Container(
        margin: EdgeInsets.only(bottom: Dimensions.height8),
        padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width12, vertical: Dimensions.height10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Dimensions.radius8),
          border: Border.all(
              color: rowBorderColor.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            // Order status dot
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _orderStatusColor(order.orderStatus),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _orderStatusColor(order.orderStatus)
                        .withValues(alpha: 0.4),
                    blurRadius: 4,
                    spreadRadius: 1,
                  )
                ],
              ),
            ),
            SizedBox(width: Dimensions.width12),
            // Merchant name + status text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.merchantName,
                    style: primaryTextStyle.copyWith(
                        fontSize: Dimensions.font14, fontWeight: bold),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _orderStatusLabel(order.orderStatus),
                    style: secondaryTextStyle.copyWith(
                        fontSize: Dimensions.font12,
                        color: _orderStatusColor(order.orderStatus)
                            .withOpacity(0.8),
                        fontWeight: semiBold),
                  ),
                ],
              ),
            ),
            // Tombol aksi per-order
            if (isActive) ...[
              if (isReadyForPickup &&
                  transaction.courierStatus ==
                      TransactionModel.courierStatusAtMerchant)
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: isLoadingPickup
                        ? null
                        : () => controller.pickupOrder(order.id),
                    icon: isLoadingPickup
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.shopping_bag_outlined, size: 14),
                    label: Text('Ambil',
                        style: TextStyle(fontSize: 12, fontWeight: bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
              if (isPickedUp &&
                  transaction.courierStatus ==
                      TransactionModel.courierStatusAtCustomer)
                SizedBox(
                  height: 32,
                  child: ElevatedButton.icon(
                    onPressed: isLoadingComplete
                        ? null
                        : () => controller.completeOrder(order.id),
                    icon: isLoadingComplete
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_outline, size: 14),
                    label: Text('Selesai',
                        style: TextStyle(fontSize: 12, fontWeight: bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    });
  }

  /// Tombol aksi utama di level transaksi, berdasarkan courier_status
  Widget _buildMainActionButton(
      CourierOrderController controller, TransactionModel transaction) {
    return Obx(() {
      final courierStatus = transaction.courierStatus;
      final isLoadingAccept =
          controller.loadingActions['accept_${transaction.id}'] == true;
      final isLoadingMerchant =
          controller.loadingActions['arrive_merchant_${transaction.id}'] ==
              true;
      final isLoadingCustomer =
          controller.loadingActions['arrive_customer_${transaction.id}'] ==
              true;

      // IDLE = belum ada kurir, tampilkan tombol "Terima Pesanan"
      if (courierStatus == 'IDLE') {
        return _actionButton(
          label: 'Terima Pesanan',
          icon: Icons.check_circle_outline,
          color: Colors.green.shade600,
          isLoading: isLoadingAccept,
          onPressed: () => controller.acceptTransaction(transaction.id),
        );
      }

      if (courierStatus == TransactionModel.courierStatusHeadingToMerchant) {
        return _actionButton(
          label: 'Saya Sudah di Merchant',
          icon: Icons.storefront,
          color: Colors.orange.shade600,
          isLoading: isLoadingMerchant,
          onPressed: () => controller.arriveAtMerchant(transaction.id),
        );
      }

      if (courierStatus == TransactionModel.courierStatusHeadingToCustomer) {
        return _actionButton(
          label: 'Saya Sudah di Lokasi Customer',
          icon: Icons.location_on_rounded,
          color: Colors.blue.shade600,
          isLoading: isLoadingCustomer,
          onPressed: () => controller.arriveAtCustomer(transaction.id),
        );
      }

      // AT_MERCHANT atau AT_CUSTOMER: tombol aksi ada di level per-order
      return const SizedBox.shrink();
    });
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: color.withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: isLoading ? const SizedBox.shrink() : Icon(icon, size: 20),
        label: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white))
            : Text(label,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ),
    );
  }

  /// Badge status kurir berdasarkan courier_status
  Widget _buildCourierStatusBadge(String courierStatus) {
    final (label, color) = switch (courierStatus) {
      'IDLE' => ('Belum Diterima', Colors.grey.shade600),
      'HEADING_TO_MERCHANT' => ('Menuju Merchant 🛵', Colors.orange.shade700),
      'AT_MERCHANT' => ('Di Merchant 📦', Colors.blue.shade600),
      'HEADING_TO_CUSTOMER' => ('Menuju Customer 🚀', Colors.purple.shade600),
      'AT_CUSTOMER' => ('Tiba di Lokasi 📍', Colors.teal.shade600),
      'DELIVERED' => ('Terkirim ✅', Colors.green.shade600),
      _ => ('Aktif', Colors.grey.shade600),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  /// Row untuk rincian penghasilan courier
  Widget _buildEarningRow(
    String label,
    String amount, {
    bool isBold = false,
    bool isNegative = false,
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isNegative ? Colors.red.shade600 : null,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isPrimary
                ? primaryColor
                : isNegative
                    ? Colors.red.shade600
                    : null,
          ),
        ),
      ],
    );
  }

  Color _getStatusColorForHeader(String? courierStatus) {
    return switch (courierStatus) {
      'HEADING_TO_MERCHANT' => Colors.orange,
      'AT_MERCHANT' => Colors.blue,
      'HEADING_TO_CUSTOMER' => Colors.purple,
      'AT_CUSTOMER' => Colors.teal,
      'DELIVERED' => Colors.green,
      _ => Colors.grey,
    };
  }

  /// Launch Google Maps with the given coordinates
  Future<void> _launchGoogleMaps(double latitude, double longitude) async {
    // Google Maps URL with latitude and longitude
    final googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    
    try {
      final uri = Uri.parse(googleMapsUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in Google Maps app
        );
      } else {
        Get.snackbar(
          'Error',
          'Tidak dapat membuka Google Maps',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan saat membuka Google Maps',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Color _orderStatusColor(String status) {
    return switch (status) {
      'READY_FOR_PICKUP' => Colors.orange,
      'PICKED_UP' => Colors.blue,
      'COMPLETED' => Colors.green,
      'CANCELED' => Colors.red,
      'PROCESSING' => Colors.amber,
      _ => Colors.grey,
    };
  }

  String _orderStatusLabel(String status) {
    return switch (status) {
      'WAITING_APPROVAL' => 'Menunggu konfirmasi merchant',
      'PROCESSING' => 'Sedang disiapkan',
      'READY_FOR_PICKUP' => 'Siap diambil',
      'PICKED_UP' => 'Sudah diambil',
      'COMPLETED' => 'Selesai',
      'CANCELED' => 'Dibatalkan',
      _ => status,
    };
  }
}
