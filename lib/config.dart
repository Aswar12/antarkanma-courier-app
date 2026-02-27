class Config {
  // API Configuration
  // HOST CONFIGURATION:
  // 1. Localhost (ADB Reverse): 'http://localhost:8000/api' -> run: adb reverse tcp:8000 tcp:8000
  // 2. Android Emulator: 'http://10.0.2.2:8000/api'
  // 3. Physical Device (Local IP): 'http://192.168.x.x:8000/api'
  static const String baseUrl = 'http://localhost:8000/api';

  static const int connectTimeout = 45; // seconds
  static const int receiveTimeout = 45; // seconds

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
