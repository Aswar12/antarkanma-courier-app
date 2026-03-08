import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:antarkanma_courier/app/providers/courier_provider.dart';
import 'package:antarkanma_courier/theme.dart';

class DeliveryHistoryPage extends StatefulWidget {
  const DeliveryHistoryPage({super.key});

  @override
  State<DeliveryHistoryPage> createState() => _DeliveryHistoryPageState();
}

class _DeliveryHistoryPageState extends State<DeliveryHistoryPage> {
  final CourierProvider _provider = Get.find<CourierProvider>();
  final currencyFormat =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedFilter = 'all';
  bool _isLoading = false;

  List<Map<String, dynamic>> _allDeliveries = [];
  List<Map<String, dynamic>> _filteredDeliveries = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final response = await _provider.getMyTransactions();
      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        List<dynamic> rawList = [];

        if (data is Map && data['data'] != null) {
          final d = data['data'];
          if (d is List) {
            rawList = d;
          } else if (d is Map && d['data'] != null) {
            rawList = d['data'] as List;
          }
        }

        _allDeliveries = rawList.map<Map<String, dynamic>>((item) {
          final tx = item as Map<String, dynamic>;
          return {
            'id': tx['id'],
            'status': tx['status'] ?? tx['transaction_status'] ?? 'UNKNOWN',
            'created_at': tx['created_at'] != null
                ? DateTime.tryParse(tx['created_at'].toString())
                : null,
            'total': tx['total_price'] ?? tx['total_amount'] ?? 0,
            'customer_name':
                tx['user']?['name'] ?? tx['customer_name'] ?? 'Customer',
            'customer_address': tx['shipping_address'] ?? '-',
          };
        }).toList();

        // Sort by date descending
        _allDeliveries.sort((a, b) {
          final dateA = a['created_at'] as DateTime?;
          final dateB = b['created_at'] as DateTime?;
          if (dateA == null || dateB == null) return 0;
          return dateB.compareTo(dateA);
        });

        _applyDateFilter();
      }
    } catch (e) {
      debugPrint('Error loading delivery history: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyDateFilter() {
    _filteredDeliveries = _allDeliveries.where((d) {
      final date = d['created_at'] as DateTime?;
      if (date == null) return true;
      if (_startDate != null && date.isBefore(_startDate!)) return false;
      if (_endDate != null) {
        final endOfDay = _endDate!.add(const Duration(days: 1));
        if (date.isAfter(endOfDay)) return false;
      }
      return true;
    }).toList();
    setState(() {});
  }

  void _applyQuickFilter(String filter) {
    final now = DateTime.now();
    _selectedFilter = filter;
    switch (filter) {
      case 'today':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = now;
        break;
      case 'week':
        _startDate = now.subtract(const Duration(days: 7));
        _endDate = now;
        break;
      case 'month':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = now;
        break;
      default:
        _startDate = null;
        _endDate = null;
    }
    _applyDateFilter();
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: logoColor,
              surface: const Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _selectedFilter = 'custom';
      _startDate = picked.start;
      _endDate = picked.end;
      _applyDateFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E21),
        foregroundColor: Colors.white,
        title: const Text('Riwayat Pengantaran'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDateRange,
            tooltip: 'Pilih Tanggal',
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick filter chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hari Ini', 'today'),
                  const SizedBox(width: 8),
                  _buildFilterChip('7 Hari', 'week'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Bulan Ini', 'month'),
                ],
              ),
            ),
          ),

          // Date range indicator
          if (_startDate != null && _endDate != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: logoColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.date_range, size: 16, color: logoColor),
                  const SizedBox(width: 8),
                  Text(
                    '${DateFormat('dd MMM yyyy').format(_startDate!)} — ${DateFormat('dd MMM yyyy').format(_endDate!)}',
                    style: TextStyle(color: logoColor, fontSize: 12),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Summary card
          _buildSummaryCard(),

          const SizedBox(height: 8),

          // Delivery list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white))
                : _filteredDeliveries.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadHistory,
                        color: logoColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredDeliveries.length,
                          itemBuilder: (context, index) =>
                              _buildDeliveryCard(_filteredDeliveries[index]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => _applyQuickFilter(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? logoColor : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? logoColor : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final totalEarnings = _filteredDeliveries.fold<double>(
        0, (sum, d) => sum + ((d['total'] as num?)?.toDouble() ?? 0));
    final totalDeliveries = _filteredDeliveries.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [logoColor.withOpacity(0.8), logoColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: logoColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Pengantaran',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '$totalDeliveries',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white30),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Pendapatan',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(totalEarnings),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    final createdAt = delivery['created_at'] as DateTime?;
    final dateStr = createdAt != null
        ? DateFormat('dd MMM yyyy, HH:mm').format(createdAt)
        : '-';
    final total = (delivery['total'] as num?)?.toDouble() ?? 0;
    final status = (delivery['status'] as String?) ?? 'UNKNOWN';
    final customerName = delivery['customer_name'] ?? 'Customer';

    Color statusColor;
    switch (status.toUpperCase()) {
      case 'COMPLETED':
      case 'DELIVERED':
        statusColor = Colors.green;
        break;
      case 'CANCELED':
      case 'CANCELLED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#${delivery['id']}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.white54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  customerName,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.access_time,
                      size: 14, color: Colors.white38),
                  const SizedBox(width: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              Text(
                currencyFormat.format(total),
                style: TextStyle(
                  color: logoColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_shipping_outlined,
              size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'Belum ada riwayat pengantaran',
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Riwayat pengantaran akan tampil di sini',
            style: TextStyle(
              color: Colors.white.withOpacity(0.3),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
