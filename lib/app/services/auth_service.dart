import 'dart:io';

import 'package:antarkanma_courier/app/data/models/user_model.dart';
import 'package:antarkanma_courier/app/providers/auth_provider.dart';
import 'package:antarkanma_courier/app/services/storage_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:antarkanma_courier/app/utils/validators.dart';
import 'package:dio/dio.dart';

class Credentials {
  final String identifier;
  final String password;

  Credentials({required this.identifier, required this.password});
}

class AuthService extends GetxService {
  StorageService? _storageService;
  AuthProvider? _authProvider;
  final _isInitialized = false.obs;
  final _isRefreshing = false.obs;

  final RxBool isLoggedIn = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  // Getters for user info
  String? get userName => currentUser.value?.name;
  String? get userPhone => currentUser.value?.phoneNumber;
  String? get userEmail => currentUser.value?.email;

  // Token management
  String? getToken() => _storageService?.getToken();
  UserModel? getUser() => currentUser.value;

  AuthService();

  Future<void> _initializeService() async {
    if (_isInitialized.value) return;

    try {
      _storageService = StorageService.instance;
      await _storageService?.ensureInitialized();

      if (!Get.isRegistered<AuthProvider>()) {
        Get.put(AuthProvider(), permanent: true);
      }
      _authProvider = Get.find<AuthProvider>();

      // Check if there's a valid token and user data
      final token = _storageService?.getToken();
      final userData = _storageService?.getUser();

      if (token != null && userData != null) {
        try {
          final user = UserModel.fromJson(userData);
          if (user.isCourier) {
            currentUser.value = user;
            isLoggedIn.value = true;
            debugPrint(
                'Valid courier found in storage, setting logged in state');
          } else {
            debugPrint('Non-courier role found in storage, clearing auth data');
            await _clearAuthData(fullClear: true);
          }
        } catch (e) {
          debugPrint('Error parsing stored user data: $e');
          await _clearAuthData(fullClear: true);
        }
      } else {
        debugPrint('No valid auth data found in storage');
        isLoggedIn.value = false;
      }

      _isInitialized.value = true;
      debugPrint('AuthService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing AuthService: $e');
      rethrow;
    }
  }

  Future<void> ensureInitialized() async {
    if (!_isInitialized.value) {
      await _initializeService();
    }
  }

  Future<void> handleAuthError(DioException error) async {
    if (error.response?.statusCode == 401) {
      debugPrint('Handling 401 error - attempting token refresh');
      final token = _storageService?.getToken();
      if (token != null) {
        try {
          final response = await _authProvider!.refreshToken(token);
          if (response.statusCode == 200 && response.data != null) {
            final newToken = response.data['data']['access_token'];
            if (newToken != null) {
              await _storageService!.saveToken(newToken);
              debugPrint('Token refreshed successfully');
              return;
            }
          }
        } catch (e) {
          debugPrint('Error refreshing token: $e');
        }
      }
      debugPrint('Token refresh failed, logging out');
      await logout();
    }
  }

  Future<bool> verifyToken(String token) async {
    try {
      if (!_isInitialized.value || _authProvider == null) return false;

      final response = await _authProvider!.getProfile(token);
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];
        if (userData != null) {
          final user = UserModel.fromJson(userData);
          return user.isCourier;
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error verifying token: $e');
      return false;
    }
  }

  Future<void> _handleSuccessfulLogin(Response response) async {
    try {
      final data = response.data;
      Map<String, dynamic> userData;
      String? token;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('data')) {
          userData = data['data']['user'];
          token = data['data']['access_token'];
        } else if (data.containsKey('user')) {
          userData = data['user'];
          token = data['access_token'];
        } else {
          userData = data;
          token = data['access_token'];
        }
      } else {
        throw Exception('Invalid response data type');
      }

      if (token == null) {
        throw Exception('Missing token in response');
      }

      await _storageService!.saveToken(token);
      await _storageService!.saveUser(userData);

      currentUser.value = UserModel.fromJson(userData);
      isLoggedIn.value = true;

      debugPrint('Login successful, data saved');
    } catch (e) {
      debugPrint('Error in _handleSuccessfulLogin: $e');
      throw e;
    }
  }

  Future<bool> tryAutoLogin() async {
    try {
      if (!_storageService!.getRememberMe()) return false;

      final credentials = _storageService!.getSavedCredentials();
      if (credentials == null) return false;

      final identifier = credentials['identifier'];
      final password = credentials['password'];

      if (identifier == null || password == null) return false;

      await login(identifier, password);
      return true;
    } catch (e) {
      debugPrint('Auto login failed: $e');
      return false;
    }
  }

  Future<bool> login(String identifier, String password) async {
    try {
      debugPrint('Login attempt - identifier: $identifier');
      if (!_isInitialized.value ||
          _authProvider == null ||
          _storageService == null) {
        debugPrint('Services not initialized');
        return false;
      }

      final validationError = Validators.validateIdentifier(identifier);
      if (validationError != null) {
        showCustomSnackbar(
            title: 'Error', message: validationError, isError: true);
        return false;
      }

      final response = await _authProvider!.login(identifier, password);
      debugPrint('Login response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint('Login response data structure: ${data.runtimeType}');
        debugPrint('Login response data: $data');

        try {
          if (!data.containsKey('data')) {
            debugPrint('Response missing data field');
            throw Exception('Invalid response structure: missing data field');
          }

          final responseData = data['data'];
          debugPrint('Response data: $responseData');

          if (!responseData.containsKey('user')) {
            debugPrint('Response missing user field');
            throw Exception('Invalid response structure: missing user data');
          }

          final userData = responseData['user'];
          final token = responseData['access_token'];

          debugPrint('Parsed user data: $userData');
          debugPrint('Parsed token: $token');

          final user = UserModel.fromJson(userData);

          // Check if user role is COURIER
          if (!user.isCourier) {
            debugPrint('Non-courier role detected: ${user.role}');
            showCustomSnackbar(
                title: 'Login Gagal',
                message: 'Aplikasi ini hanya untuk kurir.',
                isError: true);
            return false;
          }

          debugPrint('Login successful, saving credentials');
          await _storageService!.saveToken(token);
          await _storageService!.saveUser(userData);
          await _storageService!.saveCredentials(identifier, password);

          currentUser.value = user;
          isLoggedIn.value = true;
          Get.offAllNamed(Routes.main);
          return true;
        } catch (e) {
          debugPrint('Error parsing user data: $e');
          showCustomSnackbar(
              title: 'Login Gagal',
              message: 'Format data tidak valid: ${e.toString()}',
              isError: true);
          return false;
        }
      }

      if (response.statusCode != 200) {
        showCustomSnackbar(
            title: 'Login Gagal',
            message: response.data?['message'] ?? 'Terjadi kesalahan',
            isError: true);
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error during login: $e');
      showCustomSnackbar(
          title: 'Login Gagal',
          message: 'Terjadi kesalahan saat login.',
          isError: true);
      return false;
    }
  }

  UserModel? getCurrentUser() {
    return currentUser.value;
  }

  Future<bool> register(String name, String email, String phoneNumber,
      String password, String confirmPassword) async {
    try {
      if (!_isInitialized.value ||
          _authProvider == null ||
          _storageService == null) {
        return false;
      }

      if ([name, email, phoneNumber, password].any((field) => field.isEmpty)) {
        showCustomSnackbar(
            title: 'Error', message: 'Semua field harus diisi.', isError: true);
        return false;
      }

      final userData = {
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'password': password,
        'password_confirmation': confirmPassword,
        'role': 'COURIER',
      };

      final response = await _authProvider!.register(userData);
      if (response.statusCode == 200) {
        final userData = response.data['data']['user'];
        final token = response.data['data']['access_token'];
        if (token != null && userData != null) {
          try {
            final user = UserModel.fromJson(userData);
            await _storageService!.saveToken(token);
            await _storageService!.saveUser(userData);
            currentUser.value = user;
            isLoggedIn.value = true;
            Get.offAllNamed(Routes.main);
            return true;
          } catch (e) {
            debugPrint('Error parsing user data: $e');
            showCustomSnackbar(
                title: 'Error',
                message: 'Data pengguna tidak valid',
                isError: true);
            return false;
          }
        }
        showCustomSnackbar(
            title: 'Error', message: 'Data login tidak valid.', isError: true);
        return false;
      }

      showCustomSnackbar(
          title: 'Registrasi Gagal',
          message: response.data['meta']['message'] ?? 'Registrasi gagal',
          isError: true);
      return false;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal registrasi: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  Future<UserModel?> getProfile({bool showError = false}) async {
    try {
      if (!_isInitialized.value ||
          _authProvider == null ||
          _storageService == null) {
        return null;
      }

      final token = _storageService!.getToken();
      if (token == null) return null;

      final response = await _authProvider!.getProfile(token, silent: true);
      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'];
        if (userData != null) {
          try {
            final user = UserModel.fromJson(userData);
            await _storageService!.saveUser(userData);
            currentUser.value = user;
            return user;
          } catch (e) {
            debugPrint('Error parsing user data: $e');
            if (showError) {
              showCustomSnackbar(
                  title: 'Error',
                  message: 'Data profil tidak valid',
                  isError: true);
            }
            return null;
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error getting profile: $e');
      if (showError) {
        showCustomSnackbar(
            title: 'Error',
            message: 'Gagal mengambil profil: ${e.toString()}',
            isError: true);
      }
      return null;
    }
  }

  Future<bool> updateProfilePhoto(File photo) async {
    try {
      if (!_isInitialized.value ||
          _authProvider == null ||
          _storageService == null) {
        return false;
      }

      final token = _storageService!.getToken();
      if (token == null) {
        showCustomSnackbar(
            title: 'Error', message: 'Token tidak valid', isError: true);
        return false;
      }

      final fileSize = await photo.length();
      if (fileSize > 2 * 1024 * 1024) {
        showCustomSnackbar(
            title: 'Error',
            message: 'Ukuran file melebihi batas 2MB',
            isError: true);
        return false;
      }

      final extension = photo.path.split('.').last.toLowerCase();
      if (!['jpg', 'jpeg', 'png'].contains(extension)) {
        showCustomSnackbar(
            title: 'Error',
            message: 'Format file tidak valid. Gunakan JPG, JPEG, atau PNG',
            isError: true);
        return false;
      }

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photo.path,
          filename: 'profile_photo.$extension',
        ),
      });

      final response = await _authProvider!.updateProfilePhoto(token, formData);
      if (response.statusCode == 200) {
        final userResponse = await _authProvider!.getProfile(token);
        if (userResponse.statusCode == 200) {
          final userData = userResponse.data['data'];
          if (userData != null) {
            try {
              final user = UserModel.fromJson(userData);
              await _storageService!.saveUser(userData);
              currentUser.value = user;
              showCustomSnackbar(
                  title: 'Sukses', message: 'Foto profil berhasil diperbarui');
              return true;
            } catch (e) {
              debugPrint('Error parsing user data: $e');
              showCustomSnackbar(
                  title: 'Error',
                  message: 'Data profil tidak valid',
                  isError: true);
              return false;
            }
          }
        }
      }

      showCustomSnackbar(
          title: 'Error',
          message: response.data['message'] ?? 'Gagal memperbarui foto profil',
          isError: true);
      return false;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal memperbarui foto profil: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  Future<bool> updateProfile({
    required String name,
    required String email,
    String? phoneNumber,
  }) async {
    try {
      if (!_isInitialized.value ||
          _authProvider == null ||
          _storageService == null) {
        return false;
      }

      final token = _storageService!.getToken();
      if (token == null) {
        showCustomSnackbar(
            title: 'Error', message: 'Token tidak valid', isError: true);
        return false;
      }

      final updateData = {
        'name': name,
        'email': email,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'phone_number': phoneNumber,
      };

      final response = await _authProvider!.updateProfile(token, updateData);
      if (response.statusCode == 200) {
        final userResponse = await _authProvider!.getProfile(token);
        if (userResponse.statusCode == 200) {
          final userData = userResponse.data['data'];
          if (userData != null) {
            try {
              final user = UserModel.fromJson(userData);
              await _storageService!.saveUser(userData);
              currentUser.value = user;
              showCustomSnackbar(
                  title: 'Sukses', message: 'Profil berhasil diperbarui');
              return true;
            } catch (e) {
              debugPrint('Error parsing user data: $e');
              showCustomSnackbar(
                  title: 'Error',
                  message: 'Data profil tidak valid',
                  isError: true);
              return false;
            }
          }
        }
      }

      showCustomSnackbar(
          title: 'Error',
          message: response.data['message'] ?? 'Gagal memperbarui profil',
          isError: true);
      return false;
    } catch (e) {
      showCustomSnackbar(
          title: 'Error',
          message: 'Gagal memperbarui profil: ${e.toString()}',
          isError: true);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      if (!_isInitialized.value ||
          _authProvider == null ||
          _storageService == null) {
        return;
      }

      final token = _storageService!.getToken();
      if (token != null) {
        await _authProvider!.logout(token);
        await _handleFCMToken(register: false);
      }
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      await _clearAuthData(fullClear: true);
      Get.offAllNamed(Routes.login);
    }
  }

  Future<void> _clearAuthData({bool fullClear = false}) async {
    if (!_isInitialized.value || _storageService == null) return;

    if (fullClear) {
      if (_storageService!.getRememberMe()) {
        // Keep credentials if remember me is enabled
        final credentials = _storageService!.getSavedCredentials();
        await _storageService!.clearAll();
        if (credentials != null) {
          await _storageService!.saveRememberMe(true);
          await _storageService!.saveCredentials(
              credentials['identifier']!, credentials['password']!);
        }
      } else {
        await _storageService!.clearAll();
      }
    } else {
      await _storageService!.clearAuth();
    }

    isLoggedIn.value = false;
    currentUser.value = null;
  }

  // Credential management
  Future<Credentials?> getCredentials() async {
    final savedCreds = _storageService?.getSavedCredentials();
    if (savedCreds == null) return null;

    final identifier = savedCreds['identifier'];
    final password = savedCreds['password'];

    if (identifier == null || password == null) return null;

    return Credentials(identifier: identifier, password: password);
  }

  Future<void> saveCredentials(String identifier, String password) async {
    try {
      await _storageService?.setString('identifier', identifier);
      await _storageService?.setString('password', password);
      debugPrint('Credentials saved successfully');
    } catch (e) {
      debugPrint('Error saving credentials: $e');
    }
  }

  Future<void> clearCredentials() async {
    try {
      await _storageService?.remove('identifier');
      await _storageService?.remove('password');
      debugPrint('Credentials cleared successfully');
    } catch (e) {
      debugPrint('Error clearing credentials: $e');
    }
  }

  void showCustomSnackbar({
    required String title,
    required String message,
    bool isError = false,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _handleFCMToken({bool register = true}) async {
    // ... rest of the code remains the same ...
  }
}
