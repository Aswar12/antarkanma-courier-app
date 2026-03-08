abstract class Routes {
  Routes._();

  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const main = '/main';
  static const profile = '/profile';
  static const chat = '/chat';  // Added chat route for bottom navigation
  static const delivery = '/delivery';
  static const deliveryDetails = '/delivery/details';
  static const notifications = '/notifications';
  static const settings = '/settings';
  static const about = '/about';
  static const reviews = '/reviews';

  // Wallet routes
  static const topup = '/topup';
  static const topupHistory = '/topup-history';

  // Earnings route
  static const earnings = '/earnings';

  // Delivery history route
  static const deliveryHistory = '/delivery-history';

  // Map view route
  static const mapView = '/map-view';
}
