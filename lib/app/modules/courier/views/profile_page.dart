import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/controllers/main_controller.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:antarkanma_courier/theme.dart';
import 'package:intl/intl.dart';

import 'package:flutter/services.dart';

class ProfilePage extends GetView<MainController> {
  const ProfilePage({super.key});

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
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(logoColor),
              ),
            );
          }

          final courier = controller.courierData.value;
          if (courier == null) {
            return const Center(child: Text('No profile data available'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildProfileHeader(courier),
                const SizedBox(height: 20),
                _buildWalletCard(),
                const SizedBox(height: 16),
                _buildEarningsCard(),
                const SizedBox(height: 16),
                _buildMenuSection(),
                const SizedBox(height: 100),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic courier) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF000040),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Profile Photo
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 3),
              color: Colors.grey[200],
            ),
            child: ClipOval(
              child: courier.hasProfilePhoto
                  ? CachedNetworkImage(
                      imageUrl: courier.profilePhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        color: logoColor,
                        size: 50,
                      ),
                    )
                  : Icon(
                      Icons.person,
                      color: logoColor,
                      size: 50,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            courier.displayName,
            style: primaryTextStyle.copyWith(
              fontSize: 20,
              fontWeight: bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          // Email
          Text(
            courier.email ?? 'Kurir Mitra',
            style: secondaryTextStyle.copyWith(
              fontSize: 13,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 4),
          // Phone
          if (courier.phoneNumber != null)
            Text(
              courier.phoneNumber!,
              style: secondaryTextStyle.copyWith(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: utils.Dimensions.width20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF000040),
              const Color(0xFF000040).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000040).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Saldo Deposit',
                      style: primaryTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: medium,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Aktif',
                    style: primaryTextStyle.copyWith(
                      fontSize: 10,
                      fontWeight: bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() {
              final balance = controller.courierData.value?.balance ?? 0;
              return Text(
                formatCurrency(balance),
                style: primaryTextStyle.copyWith(
                  fontSize: 28,
                  fontWeight: extraBold,
                  color: Colors.white,
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Saldo otomatis terpotong saat order selesai',
              style: secondaryTextStyle.copyWith(
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsCard() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: utils.Dimensions.width20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor1,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pendapatan Hari Ini',
              style: primaryTextStyle.copyWith(
                fontSize: 14,
                fontWeight: bold,
                color: const Color(0xFF000040),
              ),
            ),
            const SizedBox(height: 16),
            Obx(() => Row(
                  children: [
                    Expanded(
                      child: _buildEarningItem(
                        Icons.delivery_dining,
                        'Total Order',
                        '${controller.totalOrdersToday.value}',
                        logoColor,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildEarningItem(
                        Icons.check_circle,
                        'Selesai',
                        '${controller.completedOrdersToday.value}',
                        Colors.green,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.grey.withOpacity(0.2),
                    ),
                    Expanded(
                      child: _buildEarningItem(
                        Icons.payments,
                        'Ongkir',
                        formatCurrency(controller.totalEarningsToday.value),
                        logoColorSecondary,
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: primaryTextStyle.copyWith(
            fontSize: 14,
            fontWeight: bold,
            color: const Color(0xFF000040),
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: secondaryTextStyle.copyWith(
            fontSize: 10,
            fontWeight: medium,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: utils.Dimensions.width20),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.history,
            title: 'Riwayat Pengantaran',
            subtitle: 'Lihat semua pesanan yang telah diselesaikan',
            onTap: () {
              // Navigate to order history
              controller.changePage(1); // go to Orders tab
            },
          ),
          _buildMenuItem(
            icon: Icons.star_border,
            title: 'Review Saya',
            subtitle: 'Lihat ulasan dan rating dari pelanggan',
            onTap: () {
              final courierId = controller.courierData.value?.id;
              if (courierId != null) {
                Get.toNamed('/reviews', arguments: courierId);
              } else {
                Get.snackbar(
                  'Error',
                  'Gagal memuat data kurir',
                  backgroundColor: alertColor,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
          ),
          _buildMenuItem(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Riwayat Keuangan',
            subtitle: 'Lihat riwayat potongan dan saldo',
            onTap: () {
              Get.snackbar(
                'Segera Hadir',
                'Fitur riwayat keuangan sedang dalam pengembangan',
                backgroundColor: logoColor,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: 'Bantuan',
            subtitle: 'FAQ dan pusat bantuan',
            onTap: () {
              Get.snackbar(
                'Segera Hadir',
                'Fitur bantuan sedang dalam pengembangan',
                backgroundColor: logoColor,
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
          ),
          const SizedBox(height: 8),
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                await controller.logout();
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(
                'Keluar',
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: medium,
                  color: alertColor,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: alertColor,
                side:
                    BorderSide(color: alertColor.withOpacity(0.3), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: backgroundColor1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: logoColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: logoColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: primaryTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: semiBold,
                          color: const Color(0xFF000040),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: secondaryTextStyle.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.withOpacity(0.4),
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
