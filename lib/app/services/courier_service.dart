import 'dart:io';
import 'package:antarkanma/app/data/models/courier_model.dart';
import 'package:antarkanma/app/data/models/order_model.dart';
import 'package:antarkanma/app/services/storage_service.dart';
import 'package:antarkanma/app/widgets/custom_snackbar.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:antarkanma/config.dart';

class CourierService extends GetxService {
  final StorageService _storageService = StorageService.instance;
  final dio.Dio _dio = dio.Dio(dio.BaseOptions(
    baseUrl: Config.baseUrl,
    validateStatus: (status) => status! < 500,
  ));

  Future<CourierModel?> getCourierProfile() async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return null;
      }

      final response = await _dio.get(
        '/api/courier/profile',
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        return CourierModel.fromJson(response.data['data']);
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to get profile',
        isError: true,
      );
      return null;
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to get profile: ${e.toString()}',
        isError: true,
      );
      return null;
    }
  }

  Future<List<OrderModel>> getActiveDeliveries() async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return [];
      }

      final response = await _dio.get(
        '/api/courier/deliveries/active',
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> deliveriesData = response.data['data'];
        return deliveriesData.map((data) => OrderModel.fromJson(data)).toList();
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to get active deliveries',
        isError: true,
      );
      return [];
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to get active deliveries: ${e.toString()}',
        isError: true,
      );
      return [];
    }
  }

  Future<List<OrderModel>> getAvailableOrders() async { // Add getAvailableOrders
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return [];
      }

      final response = await _dio.get(
        '/api/courier/deliveries/available',
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> availableOrdersData = response.data['data'];
        return availableOrdersData.map((data) => OrderModel.fromJson(data)).toList();
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to get available orders',
        isError: true,
      );
      return [];
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to get available orders: ${e.toString()}',
        isError: true,
      );
      return [];
    }
  }

  Future<List<OrderModel>> getDeliveryHistory() async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return [];
      }

      final response = await _dio.get(
        '/api/courier/deliveries/history',
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> historyData = response.data['data'];
        return historyData.map((data) => OrderModel.fromJson(data)).toList();
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to get delivery history',
        isError: true,
      );
      return [];
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to get delivery history: ${e.toString()}',
        isError: true,
      );
      return [];
    }
  }

  Future<bool> updateDeliveryStatus(
    String deliveryId,
    String status, {
    Map<String, dynamic>? location,
  }) async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return false;
      }

      final data = {
        'status': status,
        if (location != null) 'location': location,
      };

      final response = await _dio.put(
        '/api/courier/deliveries/$deliveryId/status',
        data: data,
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        showCustomSnackbar(
          title: 'Success',
          message: 'Delivery status updated successfully',
        );
        return true;
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to update delivery status',
        isError: true,
      );
      return false;
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to update delivery status: ${e.toString()}',
        isError: true,
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    required String phoneNumber,
    required String vehicleType,
    required String licensePlate,
  }) async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return false;
      }

      final response = await _dio.put(
        '/api/courier/profile',
        data: {
          'name': name,
          'email': email,
          'phone_number': phoneNumber,
          'vehicle_type': vehicleType,
          'license_plate': licensePlate,
        },
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        showCustomSnackbar(
          title: 'Success',
          message: 'Profile updated successfully',
        );
        return true;
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to update profile',
        isError: true,
      );
      return false;
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to update profile: ${e.toString()}',
        isError: true,
      );
      return false;
    }
  }

  Future<bool> updateProfileImage(File image) async {
    try {
      final token = _storageService.getToken();
      if (token == null) {
        showCustomSnackbar(
          title: 'Error',
          message: 'Token tidak valid',
          isError: true,
        );
        return false;
      }

      final formData = dio.FormData.fromMap({
        'photo': await dio.MultipartFile.fromFile(
          image.path,
          filename: 'profile_photo.${image.path.split('.').last}',
        ),
      });

      final response = await _dio.post(
        '/api/courier/profile/photo',
        data: formData,
        options: dio.Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        showCustomSnackbar(
          title: 'Success',
          message: 'Profile photo updated successfully',
        );
        return true;
      }

      showCustomSnackbar(
        title: 'Error',
        message: response.data['meta']['message'] ?? 'Failed to update profile photo',
        isError: true,
      );
      return false;
    } catch (e) {
      showCustomSnackbar(
        title: 'Error',
        message: 'Failed to update profile photo: ${e.toString()}',
        isError: true,
      );
      return false;
    }
  }
}
