import 'package:antarkanma_courier/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:antarkanma_courier/app/core/bindings/initial_binding.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

// Initialize FlutterLocalNotificationsPlugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Initialize notification channels for Android
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel',
  'High Importance Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

// Handle background messages
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Create notification channel
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Initialize local notifications
  await flutterLocalNotificationsPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
      ),
    ),
    onDidReceiveNotificationResponse: (NotificationResponse details) async {
      // Handle notification tap
      final String? payload = details.payload;
      if (payload != null) {
        debugPrint('notification payload: $payload');
        // Navigate based on payload
        Get.toNamed(Routes.splash, arguments: {'notificationData': payload});
      }
    },
  );

  // Set up foreground message handling
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: android.smallIcon,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  });

  // Set up notification tap handling when app is terminated
  FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      // Navigate based on notification data
      Get.toNamed(
        Routes.splash,
        arguments: {'notificationData': message.data.toString()},
      );
    }
  });

  // Set up notification tap handling when app is in background
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    Get.toNamed(
      Routes.splash,
      arguments: {'notificationData': message.data.toString()},
    );
  });

  runApp(
    GetMaterialApp(
      title: "Antarkanma Courier",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    ),
  );
}
