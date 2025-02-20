import 'package:get_storage/get_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  final _box = GetStorage();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static StorageService get instance => _instance;

  Future<void> ensureInitialized() async {
    await GetStorage.init();
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _box.write('token', token);
  }

  String? getToken() {
    return _box.read('token');
  }

  // User Management
  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _box.write('user', userData);
  }

  Map<String, dynamic>? getUser() {
    return _box.read('user');
  }

  // Credential Management
  Future<void> setString(String key, String value) async {
    await _box.write(key, value);
  }

  String? getString(String key) {
    return _box.read(key);
  }

  Future<void> remove(String key) async {
    await _box.remove(key);
  }

  Future<void> saveCredentials(String identifier, String password) async {
    await setString('identifier', identifier);
    await setString('password', password);
  }

  Map<String, String>? getSavedCredentials() {
    final identifier = getString('identifier');
    final password = getString('password');
    if (identifier != null && password != null) {
      return {
        'identifier': identifier,
        'password': password,
      };
    }
    return null;
  }

  Future<void> saveRememberMe(bool value) async {
    await _box.write('remember_me', value);
  }

  bool getRememberMe() {
    return _box.read('remember_me') ?? false;
  }

  // Clear Storage
  Future<void> clearAll() async {
    await _box.erase();
  }

  Future<void> clearAuth() async {
    await remove('token');
    await remove('user');
    await remove('identifier');
    await remove('password');
  }
}
