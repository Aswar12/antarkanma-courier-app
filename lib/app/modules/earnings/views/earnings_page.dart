import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:antarkanma_courier/app/controllers/earnings_controller.dart';
import 'package:antarkanma_courier/theme.dart';

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EarningsController());

    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        title: Text(
          'Penghasilan',
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: backgroundColor1,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetchPerformance,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPerformanceCards(controller),
                const SizedBox(height: 20),
                _buildEarningsChart(controller),
                const SizedBox(height: 20),
                _buildStatsSummary(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPerformanceCards(EarningsController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Penghasilan',
          style: primaryTextStyle.copyWith(
            fontSize: 16,
            fontWeight: semiBold,
          ),
        ),
        const SizedBox(height: 12),
        // Today card - highlighted
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
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
                    'Hari Ini',
                    style: primaryTextStyle.copyWith(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Obx(() => Text(
                          '${controller.todayDeliveries.value} pengiriman',
                          style: primaryTextStyle.copyWith(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: medium,
                          ),
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                    controller.formatCurrency(controller.todayEarnings.value),
                    style: primaryTextStyle.copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: bold,
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Week and Month cards
        Row(
          children: [
            Expanded(
                child: _periodCard(
              'Minggu Ini',
              controller.weekEarnings,
              controller.weekDeliveries,
              const Color(0xFF3B82F6),
            )),
            const SizedBox(width: 12),
            Expanded(
                child: _periodCard(
              'Bulan Ini',
              controller.monthEarnings,
              controller.monthDeliveries,
              const Color(0xFF10B981),
            )),
          ],
        ),
      ],
    );
  }

  Widget _periodCard(
      String title, RxDouble earnings, RxInt deliveries, Color color) {
    final controller = Get.find<EarningsController>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: primaryTextStyle.copyWith(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Obx(() => Text(
                controller.formatCurrency(earnings.value),
                style: primaryTextStyle.copyWith(
                  fontSize: 15,
                  fontWeight: bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                '${deliveries.value} pengiriman',
                style: primaryTextStyle.copyWith(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildEarningsChart(EarningsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
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
                'Tren Penghasilan',
                style: primaryTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
              Obx(() => DropdownButton<String>(
                    value: controller.selectedPeriod.value,
                    underline: const SizedBox(),
                    isDense: true,
                    style: primaryTextStyle.copyWith(fontSize: 12),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('Harian')),
                      DropdownMenuItem(
                          value: 'weekly', child: Text('Mingguan')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Bulanan')),
                    ],
                    onChanged: (v) {
                      if (v != null) controller.changePeriod(v);
                    },
                  )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Obx(() {
              if (controller.chartData.isEmpty) {
                return Center(
                  child: Text(
                    'Belum ada data penghasilan',
                    style: primaryTextStyle.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 13,
                    ),
                  ),
                );
              }
              return SfCartesianChart(
                primaryXAxis: const CategoryAxis(
                  labelRotation: -45,
                  labelStyle: TextStyle(fontSize: 10),
                ),
                primaryYAxis: const NumericAxis(
                  labelStyle: TextStyle(fontSize: 10),
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  SplineAreaSeries<Map<String, dynamic>, String>(
                    dataSource: controller.chartData.toList(),
                    xValueMapper: (d, _) => (d['period'] ?? '').toString(),
                    yValueMapper: (d, _) =>
                        double.tryParse((d['earnings'] ?? '0').toString()) ?? 0,
                    name: 'Penghasilan',
                    color: primaryColor,
                    borderColor: primaryColor,
                    borderWidth: 2,
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.3),
                        primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  SplineSeries<Map<String, dynamic>, String>(
                    dataSource: controller.chartData.toList(),
                    xValueMapper: (d, _) => (d['period'] ?? '').toString(),
                    yValueMapper: (d, _) =>
                        (d['deliveries'] as num?)?.toDouble() ?? 0,
                    name: 'Pengiriman',
                    color: const Color(0xFF10B981),
                    width: 2,
                    yAxisName: 'deliveries',
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(EarningsController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik',
            style: primaryTextStyle.copyWith(
              fontSize: 14,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 16),
          Obx(() => Row(
                children: [
                  Expanded(
                    child: _statItem(
                      Icons.star,
                      'Rating',
                      controller.avgRating.value > 0
                          ? controller.avgRating.value.toStringAsFixed(1)
                          : '-',
                      const Color(0xFFF59E0B),
                    ),
                  ),
                  Expanded(
                    child: _statItem(
                      Icons.local_shipping,
                      'Total Kirim',
                      '${controller.monthDeliveries.value}',
                      const Color(0xFF3B82F6),
                    ),
                  ),
                  Expanded(
                    child: _statItem(
                      Icons.trending_up,
                      'Rata-rata/Hari',
                      controller.monthDeliveries.value > 0
                          ? (controller.monthEarnings.value /
                                  controller.monthDeliveries.value)
                              .toStringAsFixed(0)
                          : '-',
                      const Color(0xFF10B981),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: primaryTextStyle.copyWith(
            fontSize: 18,
            fontWeight: bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: primaryTextStyle.copyWith(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
