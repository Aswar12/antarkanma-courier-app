import 'package:antarkanma/app/modules/auth/auth_binding.dart';
import 'package:antarkanma/app/modules/auth/views/sign_in_page.dart';
import 'package:antarkanma/app/modules/auth/views/sign_up_page.dart';
import 'package:antarkanma/app/modules/courier/courier_binding.dart';
import 'package:antarkanma/app/modules/courier/views/courier_main_page.dart';
import 'package:antarkanma/app/modules/courier/views/courier_profile_page.dart';
import 'package:antarkanma/app/modules/splash/views/splash_page.dart';
import 'package:get/get.dart';
import 'package:antarkanma/app/middleware/auth_middleware.dart';

abstract class Routes {
  // Common routes
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';

  // Courier routes
  static const courierMainPage = '/couriermain';
  static const courierProfile = '/couriermain/profile';
  static const courierDeliveries = '/couriermain/deliveries';
  static const courierHistory = '/couriermain/history';
}

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.login,
      page: () => SignInPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => SignUpPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.courierMainPage,
      page: () => const CourierMainPage(),
      binding: CourierBinding(),
      middlewares: [
        AuthMiddleware(),
      ],
      children: [
        GetPage(
          name: '/profile',
          page: () => const CourierProfilePage(),
        ),
      ],
    ),
  ];
}
