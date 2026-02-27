import 'package:flutter/material.dart';
import 'package:antarkanma_courier/app/providers/review_provider.dart';
import 'package:antarkanma_courier/app/theme/app_theme.dart';
import 'package:get_storage/get_storage.dart';

class CourierReviewsPage extends StatefulWidget {
  final int courierId;

  const CourierReviewsPage({super.key, required this.courierId});

  @override
  State<CourierReviewsPage> createState() => _CourierReviewsPageState();
}

class _CourierReviewsPageState extends State<CourierReviewsPage> {
  final ReviewProvider _reviewProvider = ReviewProvider();
  List<dynamic> _reviews = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    try {
      final token = GetStorage().read('token');
      if (token == null) return;

      final response = await _reviewProvider.getCourierReviews(
        token,
        widget.courierId,
      );

      if (response != null && response['meta']?['status'] == 'success') {
        setState(() {
          final data = response['data'];
          _reviews = data['reviews']?['data'] ?? [];
          _stats = data['stats'] ?? {};
        });
      }
    } catch (e) {
      debugPrint('Error loading courier reviews: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final avgRating = (_stats['average_rating'] ?? 0).toDouble();
    final totalReviews = _stats['total_reviews'] ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Review Saya'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadReviews,
              child: CustomScrollView(
                slivers: [
                  // Stats Header
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.delivery_dining,
                              color: Colors.white, size: 40),
                          const SizedBox(height: 8),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (i) {
                              return Icon(
                                i < avgRating.round()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$totalReviews ulasan dari pelanggan',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Reviews List
                  _reviews.isEmpty
                      ? SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rate_review_outlined,
                                    size: 64, color: Colors.grey.shade400),
                                const SizedBox(height: 12),
                                Text('Belum ada review',
                                    style:
                                        TextStyle(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildReviewCard(_reviews[index]),
                            childCount: _reviews.length,
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final userName = review['user']?['name'] ?? 'Pelanggan';
    final rating = review['rating'] ?? 0;
    final note = review['note'] ?? '';
    final createdAt = review['created_at'] ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                radius: 18,
                child: Text(userName[0].toUpperCase(),
                    style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(userName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Row(
                      children: List.generate(
                          5,
                          (i) => Icon(
                                i < rating ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                                size: 16,
                              )),
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(createdAt),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(note, style: const TextStyle(fontSize: 14)),
          ],
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
