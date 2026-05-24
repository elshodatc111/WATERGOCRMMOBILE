import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/screen/splash_screen.dart';
import 'package:water_go/service/connectivity_service.dart';
import 'package:water_go/service/fcm_service.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> setupNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'water_go_channel', // channel ID
    'WaterGo Notifications', // channel nomi
    description: 'WaterGo bildirishnomalar',
    importance: Importance.high,
    sound: RawResourceAndroidNotificationSound('notification_sound'),
    // raw/notification_sound.mp3
    playSound: true,
  );
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(channel);
  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await setupNotificationChannel();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  final fcmService = FCMService();
  await fcmService.getToken();
  fcmService.onTokenRefresh();
  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'water_go_channel',
          'WaterGo Notifications',
          channelDescription: 'WaterGo bildirishnomalar',
          importance: Importance.high,
          priority: Priority.high,
          sound: RawResourceAndroidNotificationSound('notification_sound'),
          playSound: true,
        ),
      ),
    );
  });
  Get.put(ConnectivityController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'WaterGo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ConnectivityWrapper(
        child: SplashScreen(),
      ),
    );
  }
}
