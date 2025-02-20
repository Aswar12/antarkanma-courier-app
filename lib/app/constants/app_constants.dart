class AppConstants {
  // App Info
  static const String appName = 'Antarkanma Courier';
  static const String appVersion = '1.0.0';

  // API Base URL (from config.dart)
  static const String baseUrl = 'https://dev.antarkanmaa.my.id/api';

  // API Timeouts
  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;

  // Storage Keys (aligned with config.dart)
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String rememberMeKey = 'remember_me';
  static const String credentialsKey = 'credentials';

  // API Endpoints (from config.dart)
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String refreshTokenEndpoint = '/refresh-token';
  static const String logoutEndpoint = '/logout';
  static const String profileEndpoint = '/user/profile';
  static const String updateProfileEndpoint = '/user/profile/update';
  static const String updateProfilePhotoEndpoint = '/user/profile/photo';
  static const String changePasswordEndpoint = '/user/password';
  static const String deleteAccountEndpoint = '/user/delete';

  // FCM Endpoints
  static const String registerFcmTokenEndpoint = '/fcm/register';
  static const String unregisterFcmTokenEndpoint = '/fcm/unregister';

  // Courier Specific Endpoints
  static const String courierProfileEndpoint = '/courier/profile';
  static const String courierNewTransactionsEndpoint = '/courier/transactions/new';
  static const String courierTransactionsEndpoint = '/courier/transactions';

  // Delivery Status
  static const String statusPending = 'pending';
  static const String statusPickup = 'pickup';
  static const String statusInTransit = 'in_transit';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Courier Status
  static const String statusOnline = 'online';
  static const String statusOffline = 'offline';
  static const String statusBusy = 'busy';

  // Notification Types
  static const String notifNewOrder = 'new_order';
  static const String notifOrderUpdate = 'order_update';
  static const String notifMessage = 'message';
  static const String notifReminder = 'reminder';

  // Transaction Status Methods
  static String transactionStatus(String id) => '/transactions/$id/status';
  static String transactionApprove(String id) => '/transactions/$id/approve';
  static String transactionReject(String id) => '/transactions/$id/reject';
}
