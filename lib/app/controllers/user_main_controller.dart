import 'package:get/get.dart';
import 'package:antarkanma/app/data/providers/user_location_provider.dart';

class UserMainController extends GetxController {
  final UserLocationProvider _userLocationProvider = UserLocationProvider();

  Future<void> fetchUserLocations(String token) async {
    try {
      final response = await _userLocationProvider.getUserLocations(token);
      // Handle the response and update the UI accordingly
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user locations');
    }
  }
}
