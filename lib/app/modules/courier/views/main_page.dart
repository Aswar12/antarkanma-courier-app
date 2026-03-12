import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme.dart';
import '../../../controllers/main_controller.dart';
import 'package:antarkanma_courier/app/modules/courier/views/home_page.dart';
import 'package:antarkanma_courier/app/modules/courier/views/order_page.dart';
import 'package:antarkanma_courier/app/modules/chat/views/chat_list_page.dart';
import 'package:antarkanma_courier/app/modules/courier/views/profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MainController>()) {
      Get.put(MainController(), permanent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return Scaffold(
      backgroundColor: backgroundColor1,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: controller.pageController,
        onPageChanged: (index) {
          controller.currentIndex.value = index;
        },
        children: const [
          HomePage(),
          OrderPage(),
          ChatListPage(),
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
            onTap: (index) {
              if (controller.currentIndex.value != index) {
                controller.changePage(index);
              }
            },
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
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Icon(Icons.chat),
                label: 'Chat',
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
