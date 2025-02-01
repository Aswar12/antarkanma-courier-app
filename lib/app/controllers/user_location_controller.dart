import 'package:get/get.dart';
import 'package:antarkanma/app/data/providers/user_location_provider.dart';

class UserLocationController extends GetxController {
  final UserLocationProvider _userLocationProvider = UserLocationProvider();

  Future<void> fetchUserLocations(String token) async {
    try {
      final response = await _userLocationProvider.getUserLocations(token);
      // Handle the response and update the UI accordingly
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user locations');
    }
  }

  Future<void> addUserLocation(String token, Map<String, dynamic> data) async {
    try {
      await _userLocationProvider.addUserLocation(token, data);
      Get.snackbar('Success', 'Location added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add user location');
    }
  }

  Future<void> updateUserLocation(String token, int locationId, Map<String, dynamic> data) async {
    try {
      await _userLocationProvider.updateUserLocation(token, locationId, data);
      Get.snackbar('Success', 'Location updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update user location');
    }
  }

  Future<void> deleteUserLocation(String token, int locationId) async {
    try {
      await _userLocationProvider.deleteUserLocation(token, locationId);
      Get.snackbar('Success', 'Location deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user location');
    }
  }
}
