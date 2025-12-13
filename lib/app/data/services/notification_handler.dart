import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Handler Background (Harus top-level function)
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('--- Background Message Handler ---');
  print('Title: ${message.notification?.title}');
}

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotification =
      FlutterLocalNotificationsPlugin();

  // 1. Channel untuk Custom Sound
  final AndroidNotificationChannel _androidChannel =
      const AndroidNotificationChannel(
        'channel_custom_sound', // ID Channel harus unik
        'Custom Sound Notification', // Nama Channel
        description: 'Channel untuk notifikasi dengan suara custom',
        importance: Importance.max,
        playSound: true,
        // Pastikan file 'notif_sound.mp3' ada di android/app/src/main/res/raw/
        sound: RawResourceAndroidNotificationSound('notif_sound'),
      );

  // 2. Channel untuk Progress Notification (Silent)
  final AndroidNotificationChannel _progressChannel =
      const AndroidNotificationChannel(
        'channel_progress',
        'Progress Notification',
        description: 'Channel untuk notifikasi progress download',
        importance: Importance.defaultImportance,
        playSound: false, // Silent agar tidak berisik saat update progress
        enableVibration: false,
      );

  // 3. Channel Default/Simple
  final AndroidNotificationChannel _simpleChannel =
      const AndroidNotificationChannel(
        'channel_simple',
        'Simple Notification',
        description: 'Channel untuk notifikasi biasa',
        importance: Importance.max,
        playSound: true,
      );

  Future<void> initPushNotification() async {
    // Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${settings.authorizationStatus}');

    // Ambil Token FCM
    final prefs = await SharedPreferences.getInstance();
    bool isNotifEnabled = prefs.getBool('is_notif_enabled') ?? true;
    if (isNotifEnabled) {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
    }

    // Handler Background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handler Terminated & Background Open
    FirebaseMessaging.instance.getInitialMessage().then(
      _handleMessageNavigation,
    );
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);
  }

  Future<void> initLocalNotification() async {
    // Setup Android & iOS settings
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: ios);

    await _localNotification.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          print("Notifikasi lokal diklik: ${response.payload}");
        }
      },
    );

    // Create Channels di Android
    final platform = _localNotification
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (platform != null) {
      await platform.createNotificationChannel(_androidChannel);
      await platform.createNotificationChannel(_progressChannel);
      await platform.createNotificationChannel(_simpleChannel);
    }
  }

  // Listener untuk notifikasi saat aplikasi dibuka (Foreground)
  void listenForegroundMessage() {
    FirebaseMessaging.onMessage.listen((message) {
      print('--- Foreground Message Received ---');
      if (message.notification != null) {
        _localNotification.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _simpleChannel.id,
              _simpleChannel.name,
              channelDescription: _simpleChannel.description,
              icon: '@mipmap/ic_launcher',
            ),
          ),
          payload: jsonEncode(message.data),
        );
      }
    });
  }

  void _handleMessageNavigation(RemoteMessage? message) {
    if (message != null && message.data.containsKey('route')) {
      Get.toNamed(message.data['route']);
    }
  }

  // --- FUNGSI TESTING MANUAL ---

  // Test 1: Simple Notification
  Future<void> showSimpleNotification() async {
    await _localNotification.show(
      101,
      'Test Simple Notification',
      'Ini adalah notifikasi standar dengan suara default HP.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _simpleChannel.id,
          _simpleChannel.name,
          channelDescription: _simpleChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  // Test 2: Custom Sound Notification
  Future<void> showCustomSoundNotification() async {
    await _localNotification.show(
      102,
      'Test Custom Sound',
      'Mendengarkan suara custom ringtone...',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('notif_sound'),
        ),
      ),
    );
  }

  // Test 3: Progress Notification
  Future<void> showProgressNotification() async {
    const int maxProgress = 10;

    // Loop simulasi download 0% - 100%
    for (int i = 0; i <= maxProgress; i++) {
      await Future.delayed(const Duration(seconds: 1)); // Delay simulasi

      await _localNotification.show(
        103, // ID harus tetap sama agar notifikasi ter-update
        'Downloading Data...',
        '$i / $maxProgress items downloaded',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _progressChannel.id,
            _progressChannel.name,
            channelDescription: _progressChannel.description,
            channelShowBadge: false,
            importance: Importance.defaultImportance,
            priority: Priority.low,
            onlyAlertOnce: true, // Cegah bunyi 'ding' berkali-kali
            showProgress: true,
            maxProgress: maxProgress,
            progress: i,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    }

    // Update terakhir saat selesai
    await _localNotification.show(
      103,
      'Download Complete!',
      'Proses unduhan data telah selesai.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _simpleChannel.id,
          _simpleChannel.name,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
