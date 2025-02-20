import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../data/models/fcm_token_model.dart';
import '../providers/fcm_provider.dart';
import '../services/storage_service.dart';

class MessagingService extends GetxService {
  final FcmProvider _fcmProvider = Get.put(FcmProvider());
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StorageService _storageService = Get.find<StorageService>();

  Future<MessagingService> init() async {
    try {
      debugPrint('Initializing FCM messaging service...');
      // Request permission for notifications
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('FCM Authorization status: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('FCM Notifications authorized, getting token...');
        // Get FCM token
        String? token = await _messaging.getToken();
        debugPrint('FCM Token received: $token');
        
        if (token != null) {
          await registerFcmToken(token);
        }

        // Listen for token refresh
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('FCM Token refreshed: $newToken');
          registerFcmToken(newToken);
        });

        // Subscribe to topics
        await subscribeToTopics();
      } else {
        debugPrint('FCM Authorization denied: ${settings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('Error initializing messaging service: $e');
      if (e is DioException) {
        debugPrint('DioError response: ${e.response?.data}');
      }
    }
    return this;
  }

  Future<void> registerFcmToken(String token) async {
    try {
      debugPrint('Starting FCM token registration...');
      debugPrint('FCM Token: $token');
      
      final authToken = _storageService.getToken();
      if (authToken == null) {
        debugPrint('Auth token not found, skipping FCM token registration');
        return;
      }

      String deviceType = Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'web';
      String deviceId = _generateDeviceId();

      debugPrint('Device Type: $deviceType');
      debugPrint('Device ID: $deviceId');

      final fcmToken = FcmTokenModel(
        token: token,
        deviceType: deviceType,
        deviceId: deviceId,
      );

      debugPrint('Registering FCM token with data: ${fcmToken.toJson()}');
      final response = await _fcmProvider.registerToken(fcmToken.toJson(), authToken);
      debugPrint('FCM token registration response: ${response.data}');
      debugPrint('FCM token registration successful');
    } catch (e) {
      debugPrint('Error registering FCM token: $e');
      if (e is DioException) {
        debugPrint('DioError response: ${e.response?.data}');
      }
    }
  }

  Future<void> unregisterFcmToken(String token) async {
    try {
      debugPrint('Unregistering FCM token: $token');
      final authToken = _storageService.getToken();
      if (authToken == null) {
        debugPrint('Auth token not found, skipping FCM token unregistration');
        return;
      }
      
      await _fcmProvider.unregisterToken(token, authToken);
      debugPrint('FCM token unregistered successfully');
    } catch (e) {
      debugPrint('Error unregistering FCM token: $e');
      if (e is DioException) {
        debugPrint('DioError response: ${e.response?.data}');
      }
    }
  }

  Future<void> subscribeToTopics() async {
    try {
      debugPrint('Subscribing to topics...');
      await _messaging.subscribeToTopic('new_transactions');
      debugPrint('Successfully subscribed to new_transactions topic');
    } catch (e) {
      debugPrint('Error subscribing to topics: $e');
    }
  }

  String _generateDeviceId() {
    // Generate a unique device ID using timestamp and random values
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    String random = DateTime.now().microsecondsSinceEpoch.toString();
    String combined = timestamp + random;
    
    // Create SHA-256 hash of the combined string
    var bytes = utf8.encode(combined);
    var digest = sha256.convert(bytes);
    
    return digest.toString();
  }
}
