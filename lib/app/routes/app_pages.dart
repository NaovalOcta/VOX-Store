import 'package:get/get.dart';

import '../modules/admin/bindings/admin_binding.dart';
import '../modules/admin/views/admin_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/detailProduct/bindings/detail_product_binding.dart';
import '../modules/detailProduct/views/detail_product_view.dart';
import '../modules/home/bindings/catalog_binding_1.dart';
import '../modules/home/views/catalog_page_1.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';

// lib/app/routes/app_pages.dart

// ... (semua import lainnya)
// HAPUS IMPORT SPLASH
// import '../modules/splash/bindings/splash_binding.dart';
// import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // --- 1. UBAH RUTE AWAL KE LOGIN ---
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const CatalogPage1(),
      binding: CatalogBinding(),
    ),

    // --- 2. HAPUS ATAU KOMENTARI GETPAGE SPLASH ---
    // GetPage(
    //   name: _Paths.SPLASH,
    //   page: () => const SplashView(),
    //   binding: SplashBinding(),
    // ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.ADMIN,
      page: () => const AdminView(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.DETAIL_PRODUCT,
      page: () => const DetailProductView(),
      binding: DetailProductBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
  ];
}
