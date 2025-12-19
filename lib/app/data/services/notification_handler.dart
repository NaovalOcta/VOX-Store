import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_pages.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('--- Background Message Handler ---');
  await Hive.initFlutter();
  if (!Hive.isBoxOpen('notificationBox')) {
    await Hive.openBox('notificationBox');
  }
  var box = Hive.box('notificationBox');

  final newLog = {
    'title': message.notification?.title ?? "Background Info",
    'body': message.notification?.body ?? "No Body",
    'date': DateTime.now().toString(),
    'data': message.data,
    'isRead': false,
  };
  await box.add(newLog);
}

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _firebaseChannel =
      const AndroidNotificationChannel(
        'channel_firebase_custom', // ID Channel
        'App Updates & Promo', // Nama Channel
        description: 'Notifikasi aplikasi dengan nada dering khusus',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notif_sound'),
      );

  final AndroidNotificationChannel _testChannel =
      const AndroidNotificationChannel(
        'channel_testing_default',
        'Test Notifications',
        description: 'Channel standar untuk pengujian modul',
        importance: Importance.max,
        playSound: true,
        // sound: null,
      );

  final AndroidNotificationChannel _progressChannel =
      const AndroidNotificationChannel(
        'channel_progress',
        'Progress Notification',
        description: 'Notifikasi progress (silent)',
        importance: Importance.defaultImportance,
        playSound: false,
        enableVibration: false,
      );

  Future<void> initPushNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    final prefs = await SharedPreferences.getInstance();
    bool isNotifEnabled = prefs.getBool('is_notif_enabled') ?? true;
    if (isNotifEnabled) {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) _handleMessageNavigation(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
  }

  Future<void> initLocalNotification() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        Get.toNamed(Routes.LOG_NOTIFICATION);
      },
    );

    final platform = _localNotification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (platform != null) {
      await platform.createNotificationChannel(_firebaseChannel);
      await platform.createNotificationChannel(_testChannel);
      await platform.createNotificationChannel(_progressChannel);
    }
  }

  void listenForegroundMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        _localNotification.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _firebaseChannel.id,
              _firebaseChannel.name,
              channelDescription: _firebaseChannel.description,
              icon: '@mipmap/ic_launcher',
              playSound: true,
              sound: const RawResourceAndroidNotificationSound('notif_sound'),
            ),
          ),
          payload: jsonEncode(message.data),
        );

        _saveToLog(
          message.notification?.title ?? "No Title",
          message.notification?.body ?? "No Body",
          message.data,
        );
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage message) {
    Get.toNamed(Routes.LOG_NOTIFICATION);
  }

  Future<void> _saveToLog(
    String title,
    String body,
    Map<String, dynamic> data,
  ) async {
    if (!Hive.isBoxOpen('notificationBox')) {
      await Hive.openBox('notificationBox');
    }
    final box = Hive.box('notificationBox');
    final newLog = {
      'title': title,
      'body': body,
      'date': DateTime.now().toString(),
      'data': data,
      'isRead': false,
    };
    await box.add(newLog);
  }

  Future<void> showSimpleNotification() async {
    const title = 'Test Simple Notification';
    const body = 'Ini notifikasi dengan suara STANDARD Android.';

    await _localNotification.show(
      101,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _testChannel.id,
          _testChannel.name,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
    _saveToLog(title, body, {'type': 'local_test_simple'});
  }

  Future<void> showCustomSoundNotification() async {
    const title = 'Test Custom Sound';
    const body = 'Cek sound... notifikasi ini pakai nada dering aplikasi.';

    await _localNotification.show(
      102,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _firebaseChannel.id,
          _firebaseChannel.name,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('notif_sound'),
        ),
      ),
    );
    _saveToLog(title, body, {'type': 'local_test_custom'});
  }

  Future<void> showProgressNotification() async {
    const int maxProgress = 5;
    _saveToLog('Download Started', 'Memulai unduhan...', {
      'type': 'progress_start',
    });

    for (int i = 0; i <= maxProgress; i++) {
      await Future.delayed(const Duration(seconds: 1));
      await _localNotification.show(
        103,
        'Downloading Data...',
        '$i / $maxProgress items',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _progressChannel.id,
            _progressChannel.name,
            channelShowBadge: false,
            importance: Importance.defaultImportance,
            priority: Priority.low,
            onlyAlertOnce: true,
            showProgress: true,
            maxProgress: maxProgress,
            progress: i,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }

    await _localNotification.show(
      103,
      'Download Complete!',
      'Unduhan selesai.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _testChannel.id,
          _testChannel.name,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
    _saveToLog('Download Complete!', 'Unduhan selesai.', {
      'type': 'progress_end',
    });
  }
}
