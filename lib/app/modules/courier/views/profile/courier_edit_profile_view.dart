import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma/app/controllers/courier_edit_profile_controller.dart';
import 'package:antarkanma/app/widgets/custom_input_field.dart';
import 'package:antarkanma/app/widgets/profile_image.dart';

class CourierEditProfileView extends GetView<CourierEditProfileController> {
  const CourierEditProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Obx(() => ProfileImage(
                        imageUrl: controller.imageUrl.value,
                        size: 120,
                      )),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      radius: 20,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                        onPressed: controller.pickImage,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomInputField(
              label: 'Full Name',
              controller: controller.nameController,
              validator: controller.validateName,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Phone Number',
              controller: controller.phoneController,
              validator: controller.validatePhone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Email',
              controller: controller.emailController,
              validator: controller.validateEmail,
              keyboardType: TextInputType.emailAddress,
              enabled: false,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                    onPressed: controller.isLoading.value
                        ? null
                        : controller.updateProfile,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : const Text('Save Changes'),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
