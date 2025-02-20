import 'package:antarkanma_courier/app/modules/auth/bindings/auth_binding.dart';
import 'package:antarkanma_courier/app/modules/auth/views/login_view.dart';
import 'package:antarkanma_courier/app/modules/courier/bindings/courier_binding.dart';
import 'package:antarkanma_courier/app/modules/courier/views/main_page.dart';
import 'package:antarkanma_courier/app/modules/splash/bindings/splash_binding.dart';
import 'package:antarkanma_courier/app/modules/splash/views/splash_view.dart';
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:get/get.dart';

class AppPages {
  static const INITIAL = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashView(),
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
  ];
}
