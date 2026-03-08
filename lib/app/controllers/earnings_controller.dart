import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../providers/earnings_provider.dart';

class EarningsController extends GetxController {
  final EarningsProvider _provider = Get.put(EarningsProvider());

  // State
  final isLoading = true.obs;
  final selectedPeriod = 'daily'.obs;

  // Performance overview
  final todayDeliveries = 0.obs;
  final todayEarnings = 0.0.obs;
  final weekDeliveries = 0.obs;
  final weekEarnings = 0.0.obs;
  final monthDeliveries = 0.obs;
  final monthEarnings = 0.0.obs;
  final avgRating = 0.0.obs;

  // Chart data
  final chartData = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPerformance();
  }

  Future<void> fetchPerformance() async {
    try {
      isLoading.value = true;
      final response = await _provider.getPerformance();
      debugPrint(
          '[Earnings] Performance response: status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['meta']?['status'] == 'success' && data['data'] != null) {
          final perf = data['data'];

          todayDeliveries.value = perf['today']?['deliveries'] ?? 0;
          todayEarnings.value =
              double.tryParse(perf['today']?['earnings']?.toString() ?? '0') ??
                  0;

          weekDeliveries.value = perf['this_week']?['deliveries'] ?? 0;
          weekEarnings.value = double.tryParse(
                  perf['this_week']?['earnings']?.toString() ?? '0') ??
              0;

          monthDeliveries.value = perf['this_month']?['deliveries'] ?? 0;
          monthEarnings.value = double.tryParse(
                  perf['this_month']?['earnings']?.toString() ?? '0') ??
              0;

          avgRating.value =
              double.tryParse(perf['avg_rating']?.toString() ?? '0') ?? 0;

          // Chart data
          if (perf['chart_data'] != null) {
            chartData.assignAll(
              (perf['chart_data'] as List)
                  .map((e) => Map<String, dynamic>.from(e))
                  .toList(),
            );
          }

          debugPrint(
              '[Earnings] Today: ${todayDeliveries.value} deliveries, ${todayEarnings.value}');
        } else {
          debugPrint('[Earnings] Performance data is null or not success');
        }
      }
    } catch (e) {
      debugPrint('[Earnings] Error fetching performance: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchEarnings() async {
    try {
      isLoading.value = true;
      final response =
          await _provider.getEarnings(period: selectedPeriod.value);

      if (response.statusCode == 200) {
        final data = response.body;
        if (data['meta']?['status'] == 'success' && data['data'] != null) {
          chartData.assignAll(
            (data['data']['data'] as List?)
                    ?.map((e) => Map<String, dynamic>.from(e))
                    .toList() ??
                [],
          );
        }
      }
    } catch (e) {
      debugPrint('[Earnings] Error fetching earnings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void changePeriod(String period) {
    selectedPeriod.value = period;
    fetchEarnings();
  }

  String formatCurrency(double amount) {
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(amount);
  }
}
