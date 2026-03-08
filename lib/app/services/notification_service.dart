import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../routes/app_routes.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../firebase_options.dart';

import '../controllers/courier_order_controller.dart';
import '../controllers/main_controller.dart';
import '../modules/chat/controllers/chat_list_controller.dart';
import '../modules/chat/controllers/chat_controller.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize GetStorage for background notifications
  await GetStorage.init();

  // Then handle the background message
  if (message.data['type'] == 'new_order' ||
      message.data['type'] == 'order_ready') {
    final storage = GetStorage();
    await storage.write('pending_notification', {
      'type': message.data['type'],
      'status': message.data['status'] ?? '',
      'order_id': message.data['order_id'] ?? '',
    });
  }
}

class NotificationService extends GetxService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final GetStorage _storage = GetStorage();
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    // Initialize local notifications
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Handle notification permissions
    await _requestPermissions();

    // Set up Firebase Messaging handlers
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request Android notification channel
    final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Handle initial message if app was terminated
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      Get.log('Initial app opened from terminated state via notification');
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleMessageOpenedApp(initialMessage);
      });
    }

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'antarkanma_courier_channel',
          'Antarkanma Courier',
          description: 'Notifications for Antarkanma Courier app',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ),
      );
    }

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    // Request FCM permissions
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationNavigation(data);
      } catch (e) {
        Get.log('Error parsing notification payload: $e');
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    Get.log('Got a message whilst in the foreground!');
    Get.log('Message data: ${message.data}');

    if (message.notification != null) {
      await showNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: jsonEncode(message.data),
      );
    }

    // Handle different notification types
    switch (message.data['type']) {
      case 'new_order':
      case 'order_ready':
        // Refresh orders
        if (Get.isRegistered<CourierOrderController>()) {
          final orderController = Get.find<CourierOrderController>();
          await orderController.refresh();
        }
        if (Get.isRegistered<MainController>()) {
          Get.find<MainController>().fetchOrders();
          Get.find<MainController>().fetchDailyStats();
        }
        break;

      case 'chat_message':
      case 'CHAT_MESSAGE':
        if (Get.isRegistered<ChatController>()) {
          Get.find<ChatController>().refreshMessages();
        }
        if (Get.isRegistered<ChatListController>()) {
          Get.find<ChatListController>().fetchChats();
        }
        break;
    }
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    Get.log('Message opened app: ${message.data}');
    _handleNotificationNavigation(message.data);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (data['type'] == 'CHAT_MESSAGE' || data.containsKey('chatId')) {
      try {
        String? chatId = data['chatId']?.toString();
        // Fallback if the raw message has it in another format
        if (chatId == null && data.containsKey('chat_id')) {
          chatId = data['chat_id']?.toString();
        }

        if (chatId != null) {
          // Send to main page first
          Get.toNamed(Routes.main);

          Future.delayed(const Duration(milliseconds: 300), () {
            Get.toNamed('/chat/$chatId', arguments: {
              'chatId': int.tryParse(chatId!),
            });
          });
        }
      } catch (e) {
        Get.log('Error handling chat notification tap: $e');
        Get.toNamed(Routes.main);
      }
      return;
    }

    switch (data['type']) {
      case 'new_order':
      case 'order_ready':
        if (data['status'] != null) {
          Get.toNamed(
            Routes.main,
            arguments: {'pending_notification': data},
          );
        } else {
          Get.toNamed(Routes.main);
        }
        break;
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'antarkanma_courier_channel',
      'Antarkanma Courier',
      channelDescription: 'Notifications for Antarkanma Courier app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}
