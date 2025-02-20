import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../controllers/main_controller.dart';
import 'package:antarkanma_courier/app/modules/courier/views/home_page.dart';
import 'package:antarkanma_courier/app/modules/courier/views/order_page.dart';
import 'package:antarkanma_courier/app/modules/courier/views/profile_page.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: backgroundColor1,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Antarkanma Courier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        onPageChanged: controller.changePage,
        children: const [
          HomePage(),
          OrderPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Container(
          decoration: BoxDecoration(
            color: backgroundColor1,
            boxShadow: [
              BoxShadow(
                color: logoColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: controller.currentIndex.value,
            onTap: controller.changePage,
            selectedItemColor: logoColor,
            unselectedItemColor: secondaryTextColor,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_alt_outlined),
                activeIcon: Icon(Icons.list_alt),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
