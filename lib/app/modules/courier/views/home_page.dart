import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/controllers/main_controller.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import 'package:antarkanma_courier/theme.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/services.dart';
import 'package:antarkanma_courier/app/data/models/transaction_model.dart';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:antarkanma_courier/app/widgets/interactive_map.dart';

class HomePage extends GetView<MainController> {
  const HomePage({super.key});

  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor1,
        body: RefreshIndicator(
          onRefresh: () => controller.refreshOrders(),
          color: logoColor,
          backgroundColor: backgroundColor1,
          strokeWidth: 3,
          displacement: 40,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                _buildWalletSection(),
                _buildStatsSection(),
                // Quick action: Delivery History
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: utils.Dimensions.width20),
                  child: GestureDetector(
                    onTap: () => Get.toNamed(Routes.deliveryHistory),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: logoColor.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded,
                              color: logoColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Riwayat Pengantaran',
                              style: primaryTextStyle.copyWith(
                                fontSize: 14,
                                fontWeight: medium,
                                color: const Color(0xFF000040),
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: Colors.grey.shade400, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                _buildIncomingOrdersSection(),
                SizedBox(
                    height:
                        utils.Dimensions.height80), // Padding for bottom nav
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: 60, // approximate status bar + padding
        left: utils.Dimensions.width20,
        right: utils.Dimensions.width20,
        bottom: 50, // Extra padding for the overlapping wallet
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF000040), // navy-deep
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative Circle (top right)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: logoColor.withOpacity(0.1),
              ),
            ),
          ),
          // Header Content
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: logoColor.withOpacity(0.3), width: 2),
                      color: Colors.grey[200],
                    ),
                    child: ClipOval(
                      child: Obx(() {
                        final courierData = controller.courierData.value;
                        if (courierData?.hasProfilePhoto ?? false) {
                          return CachedNetworkImage(
                            imageUrl: courierData!.profilePhotoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              color: logoColor,
                              size: 30,
                            ),
                          );
                        } else {
                          return Icon(
                            Icons.person,
                            color: logoColor,
                            size: 30,
                          );
                        }
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SELAMAT BEKERJA,',
                        style: primaryTextStyle.copyWith(
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: bold,
                          letterSpacing: 1,
                        ),
                      ),
                      Obx(() {
                        final courierData = controller.courierData.value;
                        return Text(
                          courierData?.displayName ?? 'Kurir Mitra',
                          style: primaryTextStyle.copyWith(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: bold,
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Toggle switch for online/offline with onTap
                  GestureDetector(
                    onTap: controller.toggleOnlineOffline,
                    child: Container(
                      width: 44,
                      height: 24,
                      decoration: BoxDecoration(
                        color: controller.isOnline.value
                            ? logoColor
                            : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Row(
                        mainAxisAlignment: controller.isOnline.value
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() => Text(
                        controller.isOnline.value ? 'ONLINE' : 'OFFLINE',
                        style: primaryTextStyle.copyWith(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: bold,
                        ),
                      )),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWalletSection() {
    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: utils.Dimensions.width20),
        child: Container(
          padding: EdgeInsets.all(utils.Dimensions.height20),
          decoration: BoxDecoration(
            color: backgroundColor1,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dompet Driver',
                    style: secondaryTextStyle.copyWith(
                      fontSize: 12,
                      fontWeight: medium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    final balance = controller.courierData.value?.balance ?? 0;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rp',
                          style: primaryTextStyle.copyWith(
                            fontSize: 12,
                            fontWeight: bold,
                            color: const Color(0xFF000040),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          NumberFormat.currency(
                                  locale: 'id_ID', symbol: '', decimalDigits: 0)
                              .format(balance),
                          style: primaryTextStyle.copyWith(
                            fontSize: 24,
                            fontWeight: extraBold,
                            color: const Color(0xFF000040),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showWithdrawBottomSheet(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  elevation: 5,
                  shadowColor: logoColor.withOpacity(0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Tarik Dana',
                      style: primaryTextStyle.copyWith(
                        fontSize: 12,
                        fontWeight: bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: utils.Dimensions.width20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: Text(
              'Statistik Hari Ini',
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: bold,
                color: const Color(0xFF000040),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Obx(() {
            String earningsText =
                formatCurrency(controller.totalEarningsToday.value);
            // Shorten if too long
            if (earningsText.length > 8) {
              double val = controller.totalEarningsToday.value;
              if (val >= 1000000) {
                earningsText = '${(val / 1000000).toStringAsFixed(1)}jt';
              } else if (val >= 1000) {
                earningsText = '${(val / 1000).toStringAsFixed(0)}rb';
              }
            }
            return Row(
              children: [
                Expanded(
                    child: _buildStatCard(
                        '${controller.totalOrdersToday.value}',
                        'TOTAL ORDER',
                        Icons.delivery_dining)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        '${controller.completedOrdersToday.value}',
                        'SELESAI',
                        Icons.check_circle)),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildStatCard(
                        earningsText, 'PENDAPATAN', Icons.payments)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: logoColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: logoColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: primaryTextStyle.copyWith(
              fontSize: 18,
              fontWeight: bold,
              color: const Color(0xFF000040),
            ),
          ),
          Text(
            label,
            style: secondaryTextStyle.copyWith(
              fontSize: 9,
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingOrdersSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: utils.Dimensions.width20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pesanan Masuk',
                style: primaryTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: bold,
                  color: const Color(0xFF000040),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: logoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TERBARU',
                  style: primaryTextStyle.copyWith(
                    fontSize: 10,
                    fontWeight: extraBold,
                    color: logoColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Incoming orders list
          Obx(() {
            if (controller.isLoading.value &&
                controller.incomingTransactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.incomingTransactions.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.inbox,
                          size: 48, color: Colors.grey.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada pesanan masuk',
                        style: secondaryTextStyle.copyWith(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: controller.incomingTransactions.map((transaction) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildOrderCard(transaction),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildOrderCard(TransactionModel trx) {
    // extract data safely
    String merchantName = trx.baseMerchant?['name'] ?? 'Unknown Merchant';
    String dropoffAddr =
        trx.deliveryLocation?['address'] ?? 'Unknown Destination';

    // limit dropoff text to not overflow easily
    if (dropoffAddr.length > 25) {
      dropoffAddr = '${dropoffAddr.substring(0, 25)}...';
    }

    String estimatedEarning = formatCurrency(trx.shippingPrice);
    String distanceString = '-';
    if (trx.distance != null) {
      distanceString = '${trx.distance!.toStringAsFixed(1)} km';
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Interactive Map with flutter_map
          Stack(
            children: [
              SizedBox(
                height: 176,
                width: double.infinity,
                child: InteractiveMap(
                  transaction: trx,
                  showRoute: true,
                ),
              ),
              // "Lihat Peta" button overlay
              Positioned(
                right: 8,
                top: 8,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Get.toNamed(Routes.mapView, arguments: trx);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.fullscreen,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Lihat Peta',
                            style: primaryTextStyle.copyWith(
                              fontSize: 11,
                              fontWeight: bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Order Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JARAK',
                              style: secondaryTextStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: bold,
                                  letterSpacing: 1),
                            ),
                            Text(
                              distanceString,
                              style: primaryTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: bold,
                                  color: const Color(0xFF000040)),
                            ),
                          ],
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          width: 1,
                          height: 24,
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ESTIMASI',
                              style: secondaryTextStyle.copyWith(
                                  fontSize: 10,
                                  fontWeight: bold,
                                  letterSpacing: 1),
                            ),
                            Text(
                              estimatedEarning,
                              style: primaryTextStyle.copyWith(
                                  fontSize: 14,
                                  fontWeight: bold,
                                  color: logoColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'ID PESANAN',
                          style: secondaryTextStyle.copyWith(
                              fontSize: 10, fontWeight: bold, letterSpacing: 1),
                        ),
                        Text(
                          '#ANTAR-${trx.id}',
                          style: primaryTextStyle.copyWith(
                              fontSize: 11,
                              fontWeight: medium,
                              color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          controller.rejectTransaction(trx);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                              color: Colors.grey.withOpacity(0.2), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'TOLAK',
                          style: secondaryTextStyle.copyWith(
                              fontSize: 14, fontWeight: bold, letterSpacing: 1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.approveTransaction(trx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: logoColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 6,
                          shadowColor: logoColor.withOpacity(0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'TERIMA',
                          style: primaryTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: extraBold,
                              color: Colors.white,
                              letterSpacing: 1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showWithdrawBottomSheet() {
    final TextEditingController amountController = TextEditingController();
    final currentBalance = controller.totalEarningsToday.value;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tarik Dana',
                  style: primaryTextStyle.copyWith(
                    fontSize: 18,
                    fontWeight: semiBold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Saldo Tersedia',
              style: secondaryTextStyle.copyWith(
                fontSize: 12,
                color: chatTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              NumberFormat.currency(
                      locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                  .format(currentBalance),
              style: primaryTextStyle.copyWith(
                fontSize: 24,
                fontWeight: extraBold,
                color: logoColor,
              ),
            ),
            const SizedBox(height: 24),

            // Input Amount
            Text(
              'Jumlah Penarikan',
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: semiBold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Minimal Rp 10.000',
                prefixText: 'Rp ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: logoColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Auto-format to thousands
                final numericValue = double.tryParse(value.replaceAll('.', ''));
                if (numericValue != null) {
                  final formatted = NumberFormat('#,###', 'id_ID')
                      .format(numericValue.toInt());
                  if (value != formatted) {
                    amountController.value = TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                }
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Minimum penarikan: Rp 10.000',
              style: secondaryTextStyle.copyWith(
                fontSize: 11,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amountText = amountController.text.replaceAll('.', '');
                  final amount = double.tryParse(amountText);

                  if (amount == null || amount < 10000) {
                    Get.snackbar(
                      'Jumlah Tidak Valid',
                      'Minimum penarikan adalah Rp 10.000',
                      backgroundColor: Colors.orange,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  if (amount > currentBalance) {
                    Get.snackbar(
                      'Saldo Tidak Mencukupi',
                      'Jumlah penarikan melebihi saldo tersedia',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.TOP,
                    );
                    return;
                  }

                  Get.back(); // Close bottom sheet
                  controller.withdrawEarnings(amount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 3,
                ),
                child: Text(
                  'Tarik Sekarang',
                  style: primaryTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: semiBold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Info Note
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Dana akan ditransfer ke rekening Anda dalam 1-3 hari kerja.',
                      style: secondaryTextStyle.copyWith(
                        fontSize: 11,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
