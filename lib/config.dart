class Config {
  // API Configuration
  static const String baseUrl = 'https://dev.antarkanmaa.my.id/api';
  static const int connectTimeout = 30; // seconds
  static const int receiveTimeout = 30; // seconds

  // App Configuration
  static const String appName = 'Antarkanma Courier';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String tokenKey = 'token';
  static const String userKey = 'user';
  static const String rememberMeKey = 'remember_me';
  static const String identifierKey = 'identifier';
  static const String passwordKey = 'password';

  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String logoutEndpoint = '/logout';
  static const String refreshTokenEndpoint = '/refresh';
  static const String profileEndpoint = '/profile';
  static const String updateProfileEndpoint = '/profile/update';
  static const String updatePhotoEndpoint = '/profile/photo';

  // New registration endpoint
  static const String registerEndpoint = '/courier/register';

  // Courier Specific Endpoints
  static const String verifyDeviceEndpoint = '/courier/verify-device';
  static const String updateStatusEndpoint = '/courier/status';
  static const String uploadDocumentEndpoint = '/courier/documents';
}
