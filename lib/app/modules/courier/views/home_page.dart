import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/controllers/main_controller.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import 'package:antarkanma_courier/theme.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/services.dart';
import 'package:antarkanma_courier/app/data/models/transaction_model.dart';

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
                  // Simulated toggle switch for online
                  Container(
                    width: 44,
                    height: 24,
                    decoration: BoxDecoration(
                      color: logoColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ONLINE',
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: bold,
                    ),
                  )
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
                onPressed: () {},
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
          // Map Background placeholder
          Container(
            height: 176, // 44 tailwind units
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDhR1eCqpfixIoAqo-2Tqceajt--dpTUIURQDg75e_28ypVqRJeOrsLggKa_nLnSWuEfx9tq2g4RmDHZdI1Ogs4Th2o_vuoczEVpsWXFnS4-2tFEFeqJdjuVWke1yHU-42lhK5KH_dB1G99yxUg_vWYn3tQ4BUJXvd521oWZN4rZxboZGmxIXMK7K7UT9swUiTtb10zQV99GeNJKQvUX1PUnzPuXadrNKpsWe1LM59QOfgLxYxNU4kv4X2Voi9n0CkG87uOt46Hnoq4'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: const Color(0xFF000040).withOpacity(0.1),
              padding: const EdgeInsets.all(16),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, color: logoColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Pick-up: $merchantName',
                            style: primaryTextStyle.copyWith(
                                fontSize: 9, fontWeight: bold),
                          )
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: logoColor.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.navigation,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Drop-off: $dropoffAddr',
                            style: primaryTextStyle.copyWith(
                                fontSize: 9,
                                fontWeight: bold,
                                color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Simple SVG-like curve approximation using CustomPaint would be complex,
                  // using a simple dashed line icon placeholder
                  Center(
                    child: Icon(Icons.route, color: logoColor, size: 36),
                  ),
                ],
              ),
            ),
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
                          '#ANT-${trx.id}',
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
}
