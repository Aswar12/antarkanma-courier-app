import 'package:antarkanma_courier/app/modules/auth/bindings/auth_binding.dart';
import 'package:antarkanma_courier/app/modules/auth/views/login_view.dart';
import 'package:antarkanma_courier/app/modules/courier/bindings/courier_binding.dart';
import 'package:antarkanma_courier/app/modules/courier/views/main_page.dart';
import 'package:antarkanma_courier/app/modules/splash/bindings/splash_binding.dart';
import 'package:antarkanma_courier/app/modules/splash/views/splash_page.dart';
import 'package:antarkanma_courier/app/modules/courier/views/courier_reviews_page.dart';
import 'package:antarkanma_courier/app/modules/chat/views/chat_view.dart';
import 'package:antarkanma_courier/app/modules/chat/bindings/chat_binding.dart';
import 'package:antarkanma_courier/app/modules/chat/views/chat_list_page.dart';
import 'package:antarkanma_courier/app/modules/wallet/bindings/wallet_binding.dart';
import 'package:antarkanma_courier/app/modules/wallet/views/topup_page.dart';
import 'package:antarkanma_courier/app/modules/wallet/views/topup_history_page.dart';
import 'package:antarkanma_courier/app/modules/earnings/views/earnings_page.dart';
import 'package:antarkanma_courier/app/modules/delivery/views/delivery_history_page.dart';
import 'package:antarkanma_courier/app/modules/courier/views/map_view_page.dart';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.main,
      page: () => const MainPage(),
      binding: MainBinding(),
    ),
    // Chat route - for direct navigation from notifications
    GetPage(
      name: '/chat/:chatId',
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    // Chat list route - for bottom navigation
    GetPage(
      name: Routes.chat,
      page: () => const ChatListPage(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: Routes.reviews,
      page: () {
        final courierId = Get.arguments as int;
        return CourierReviewsPage(courierId: courierId);
      },
    ),
    GetPage(
      name: Routes.topup,
      page: () => const TopupPage(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.topupHistory,
      page: () => const TopupHistoryPage(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: Routes.earnings,
      page: () => const EarningsPage(),
    ),
    GetPage(
      name: Routes.deliveryHistory,
      page: () => const DeliveryHistoryPage(),
    ),
    GetPage(
      name: Routes.mapView,
      page: () {
        final transaction = Get.arguments;
        return MapViewPage(transaction: transaction);
      },
    ),
  ];
}
