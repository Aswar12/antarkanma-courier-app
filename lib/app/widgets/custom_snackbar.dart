import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar({
  required String title,
  required String message,
  bool isError = false,
}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    backgroundColor: isError ? Colors.red : Colors.green,
    colorText: Colors.white,
    duration: const Duration(seconds: 3),
  );
}
