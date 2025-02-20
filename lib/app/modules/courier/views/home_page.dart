import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/controllers/main_controller.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import 'package:antarkanma_courier/theme.dart';
import 'package:intl/intl.dart';

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
    return Scaffold(
      backgroundColor: backgroundColor1,
      body: RefreshIndicator(
        onRefresh: () => controller.refreshOrders(),
        color: logoColor,
        backgroundColor: backgroundColor1,
        strokeWidth: 3,
        displacement: 40,
        child: CustomScrollView(
          slivers: [
            // Header Section with Status and Balance
            SliverAppBar(
              expandedHeight: 180,
              pinned: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: brandGradient,
                  ),
                ),
                child: FlexibleSpaceBar(
                  background: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(utils.Dimensions.height16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Online/Offline Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Text(
                                'Selamat datang, ${controller.courierData.value?.displayName ?? 'Kurir'}',
                                style: primaryTextStyle.copyWith(
                                  fontSize: utils.Dimensions.font16,
                                  fontWeight: medium,
                                  color: backgroundColor1,
                                ),
                              )),
                              Switch(
                                value: true,
                                onChanged: (value) {},
                                activeColor: logoColor,
                                activeTrackColor: logoColorSecondary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Balance Section
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saldo Anda',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: utils.Dimensions.font14,
                                        color: backgroundColor1,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Obx(() => Text(
                                          formatCurrency(controller.courierData.value?.balance ?? 0),
                                          style: primaryTextStyle.copyWith(
                                            fontSize: utils.Dimensions.font24,
                                            fontWeight: bold,
                                            color: backgroundColor1,
                                          ),
                                        )),
                                        const SizedBox(width: 8),
                                        Obx(() {
                                          final balance = controller.courierData.value?.balance ?? 0;
                                          return balance < 20000 ? Icon(
                                            Icons.warning,
                                            color: alertColor,
                                            size: utils.Dimensions.iconSize24,
                                          ) : const SizedBox.shrink();
                                        }),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Quick Stats Cards
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(utils.Dimensions.height16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Hari Ini',
                      style: primaryTextStyle.copyWith(
                        fontSize: utils.Dimensions.font18,
                        fontWeight: semiBold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(utils.Dimensions.height16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            logoColor.withOpacity(0.1),
                            logoColorSecondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
                        border: Border.all(
                          color: logoColor.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatItem(
                                  'Pendapatan',
                                  'Rp 150.000',
                                  Icons.monetization_on,
                                ),
                              ),
                              Expanded(
                                child: _buildStatItem(
                                  'Delivery',
                                  '5',
                                  Icons.delivery_dining,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.track_changes,
                                          color: logoColor,
                                          size: utils.Dimensions.iconSize24,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Target Harian',
                                          style: secondaryTextStyle.copyWith(
                                            fontSize: utils.Dimensions.font14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Stack(
                                      children: [
                                        Container(
                                          height: 4,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: logoColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(utils.Dimensions.radius5),
                                          ),
                                        ),
                                        Container(
                                          height: 4,
                                          width: 150, // Replace with actual progress
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: brandGradient,
                                            ),
                                            borderRadius: BorderRadius.circular(utils.Dimensions.radius5),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '5/10 Order',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: utils.Dimensions.font14,
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatItem(
                                  'Fee',
                                  'Rp 15.000',
                                  Icons.account_balance_wallet,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Active Orders Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: utils.Dimensions.height16,
                  vertical: utils.Dimensions.height8,
                ),
                child: Text(
                  'Pesanan Aktif',
                  style: primaryTextStyle.copyWith(
                    fontSize: utils.Dimensions.font18,
                    fontWeight: semiBold,
                  ),
                ),
              ),
            ),
            // Empty or List State
            SliverToBoxAdapter(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Padding(
                    padding: EdgeInsets.all(utils.Dimensions.height16),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(utils.Dimensions.height16),
                          decoration: BoxDecoration(
                            color: backgroundColor1,
                            borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
                            border: Border.all(
                              color: logoColor.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(logoColor),
                                  strokeWidth: 3,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Memuat Pesanan...',
                                style: primaryTextStyle.copyWith(
                                  fontSize: utils.Dimensions.font18,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (!controller.hasOrders.value) {
                  return Padding(
                    padding: EdgeInsets.all(utils.Dimensions.height16),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(utils.Dimensions.height16),
                          decoration: BoxDecoration(
                            color: backgroundColor1,
                            borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
                            border: Border.all(
                              color: logoColor.withOpacity(0.1),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      logoColor.withOpacity(0.1),
                                      logoColorSecondary.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.local_shipping_outlined,
                                  size: 60,
                                  color: logoColor,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum Ada Pesanan',
                                style: primaryTextStyle.copyWith(
                                  fontSize: utils.Dimensions.font18,
                                  fontWeight: semiBold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tarik ke bawah untuk memuat ulang',
                                style: secondaryTextStyle.copyWith(
                                  fontSize: utils.Dimensions.font14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: utils.Dimensions.height16,
                          vertical: utils.Dimensions.height8,
                        ),
                        child: _buildOrderCard(index),
                      );
                    },
                    childCount: 5,
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: logoColor,
          size: utils.Dimensions.iconSize24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: primaryTextStyle.copyWith(
            fontSize: utils.Dimensions.font24,
            fontWeight: bold,
          ),
        ),
        Text(
          label,
          style: secondaryTextStyle.copyWith(
            fontSize: utils.Dimensions.font14,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(int index) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor1,
        borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
        boxShadow: [
          BoxShadow(
            color: logoColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Handle tap
          },
          borderRadius: BorderRadius.circular(utils.Dimensions.radius12),
          child: Padding(
            padding: EdgeInsets.all(utils.Dimensions.height16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Time and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: utils.Dimensions.iconSize24,
                          color: logoColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '10:30 WIB',
                          style: subtitleTextStyle.copyWith(
                            fontSize: utils.Dimensions.font14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: brandGradient,
                        ),
                        borderRadius: BorderRadius.circular(utils.Dimensions.radius8),
                      ),
                      child: Text(
                        'Baru',
                        style: primaryTextStyle.copyWith(
                          fontSize: utils.Dimensions.font12,
                          color: backgroundColor1,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Merchant and Customer Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.store,
                                size: utils.Dimensions.iconSize24,
                                color: logoColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Merchant ABC',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: utils.Dimensions.font16,
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                    Text(
                                      'Jl. Merchant No. 123',
                                      style: secondaryTextStyle.copyWith(
                                        fontSize: utils.Dimensions.font14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: utils.Dimensions.iconSize24,
                                color: logoColorSecondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Customer XYZ',
                                      style: primaryTextStyle.copyWith(
                                        fontSize: utils.Dimensions.font16,
                                        fontWeight: semiBold,
                                      ),
                                    ),
                                    Text(
                                      'Jl. Customer No. 456',
                                      style: secondaryTextStyle.copyWith(
                                        fontSize: utils.Dimensions.font14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: logoColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(utils.Dimensions.radius8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: logoColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '2.5 km',
                                style: primaryTextStyle.copyWith(
                                  fontSize: utils.Dimensions.font14,
                                  color: logoColor,
                                  fontWeight: medium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rp 25.000',
                          style: priceTextStyle.copyWith(
                            fontSize: utils.Dimensions.font16,
                            fontWeight: semiBold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Accept Order Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle accept order
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: logoColor,
                      foregroundColor: backgroundColor1,
                      padding: EdgeInsets.symmetric(
                        vertical: utils.Dimensions.height10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(utils.Dimensions.radius8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: utils.Dimensions.iconSize24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Terima Order',
                          style: primaryTextStyle.copyWith(
                            fontSize: utils.Dimensions.font14,
                            fontWeight: medium,
                            color: backgroundColor1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
