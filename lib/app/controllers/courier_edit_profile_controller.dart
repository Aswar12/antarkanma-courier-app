import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:antarkanma/app/services/courier_service.dart';
import 'package:antarkanma/app/data/models/courier_model.dart';

class CourierEditProfileController extends GetxController {
  final CourierService _courierService;

  CourierEditProfileController({
    required CourierService courierService,
  }) : _courierService = courierService;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final licensePlateController = TextEditingController();
  
  final imageUrl = ''.obs;
  final isLoading = false.obs;
  File? selectedImage;

  @override
  void onInit() {
    super.onInit();
    loadCourierData();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    vehicleTypeController.dispose();
    licensePlateController.dispose();
    super.onClose();
  }

  Future<void> loadCourierData() async {
    try {
      final courier = await _courierService.getCourierProfile();
      if (courier != null) {
        nameController.text = courier.user.name;
        phoneController.text = courier.user.phoneNumber ?? '';
        emailController.text = courier.user.email ?? '';
        vehicleTypeController.text = courier.vehicleType;
        licensePlateController.text = courier.licensePlate;
        imageUrl.value = courier.user.profilePhotoUrl ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load profile data');
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        selectedImage = File(image.path);
        await updateProfileImage();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  Future<void> updateProfileImage() async {
    if (selectedImage == null) return;

    try {
      isLoading.value = true;
      final success = await _courierService.updateProfileImage(selectedImage!);
      if (success) {
        await loadCourierData(); // Reload data to get new image URL
        Get.snackbar('Success', 'Profile image updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile image');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      final success = await _courierService.updateProfile(
        name: nameController.text,
        email: emailController.text,
        phoneNumber: phoneController.text,
        vehicleType: vehicleTypeController.text,
        licensePlate: licensePlateController.text,
      );
      if (success) {
        Get.snackbar('Success', 'Profile updated successfully');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      isLoading.value = false;
    }
  }

  bool validateForm() {
    if (nameController.text.isEmpty) {
      Get.snackbar('Error', 'Name is required');
      return false;
    }
    if (phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Phone number is required');
      return false;
    }
    if (vehicleTypeController.text.isEmpty) {
      Get.snackbar('Error', 'Vehicle type is required');
      return false;
    }
    if (licensePlateController.text.isEmpty) {
      Get.snackbar('Error', 'License plate is required');
      return false;
    }
    return true;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!GetUtils.isPhoneNumber(value)) {
      return 'Invalid phone number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  String? validateVehicleType(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vehicle type is required';
    }
    return null;
  }

  String? validateLicensePlate(String? value) {
    if (value == null || value.isEmpty) {
      return 'License plate is required';
    }
    return null;
  }
}
