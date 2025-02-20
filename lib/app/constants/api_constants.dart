import '../../config.dart';

class ApiConstants {
  // API Endpoints
  static const String loginEndpoint = Config.loginEndpoint;
  static const String logoutEndpoint = Config.logoutEndpoint;
  static const String refreshTokenEndpoint = Config.refreshTokenEndpoint;
  static const String profileEndpoint = Config.profileEndpoint;

  // Courier Specific Endpoints
  static const String verifyDeviceEndpoint = '/courier/verify-device';
  static const String updateStatusEndpoint = '/courier/status';
  static const String updateProfileEndpoint = '/courier/profile';
  static const String uploadDocumentEndpoint = '/courier/documents';
}
