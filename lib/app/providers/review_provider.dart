import 'package:antarkanma_courier/app/providers/base_provider.dart';

class ReviewProvider extends BaseProvider {
  /// Get courier reviews
  Future<dynamic> getCourierReviews(String token, int courierId,
      {int limit = 50}) async {
    return await get(
      '/couriers/$courierId/reviews',
      queryParams: {'limit': limit},
      token: token,
    );
  }
}
