// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:demo_modul5/app/data/models/ProductModel.dart';
import 'package:demo_modul5/app/data/services/ThemeService.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/data/models/CartItemModel.dart';
import 'app/routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:demo_modul5/app/data/services/notification_handler.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(CartItemAdapter());
  await Hive.openBox<Product>('productBox');
  await Hive.openBox<CartItem>('cartBox');

  // 3. Service & Theme
  await Get.putAsync(() => SupabaseService().init());
  await Get.putAsync(() => ThemeService().init());

  // 4. Inisialisasi Notification Handler
  final notificationHandler = NotificationHandler();
  await notificationHandler.initPushNotification();
  await notificationHandler.initLocalNotification();
  notificationHandler
      .listenForegroundMessage(); // Listen notifikasi saat aplikasi dibuka

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeService themeService = Get.find();

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Product Catalog",
      themeMode: themeService.theme,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),

      // --- MODIFIKASI: Rute awal adalah Splash ---
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
