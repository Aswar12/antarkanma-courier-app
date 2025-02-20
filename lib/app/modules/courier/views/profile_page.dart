import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antarkanma_courier/app/controllers/main_controller.dart';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:antarkanma_courier/app/utils/dimensions.dart' as utils;
import 'package:antarkanma_courier/theme.dart';

class ProfilePage extends GetView<MainController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(logoColor),
            );
          }
          
          final courier = controller.courierData.value;
          if (courier == null) {
            return const Text('No profile data available');
          }
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (courier.hasProfilePhoto)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(courier.profilePhotoUrl!),
                )
              else
                CircleAvatar(
                  radius: 50,
                  backgroundColor: logoColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: logoColor,
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                courier.displayName,
                style: primaryTextStyle.copyWith(
                  fontSize: utils.Dimensions.font18,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                courier.email ?? 'No email',
                style: secondaryTextStyle.copyWith(
                  fontSize: utils.Dimensions.font14,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  await controller.logout();
                  Get.offAllNamed(Routes.login);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoColor,
                  foregroundColor: backgroundColor1,
                  padding: EdgeInsets.symmetric(
                    horizontal: utils.Dimensions.width30,
                    vertical: utils.Dimensions.height10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(utils.Dimensions.radius8),
                  ),
                ),
                child: Text(
                  'Logout',
                  style: primaryTextStyle.copyWith(
                    fontSize: utils.Dimensions.font14,
                    fontWeight: medium,
                    color: backgroundColor1,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
