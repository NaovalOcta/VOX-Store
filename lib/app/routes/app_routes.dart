// lib/app/routes/app_routes.dart
part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  // --- TAMBAHKAN RUTE BARU ---
  static const LOGIN = _Paths.LOGIN;
  static const REGISTER = _Paths.REGISTER;
  static const ADMIN = _Paths.ADMIN;
  static const SPLASH = _Paths.SPLASH;
  static const PROFILE = _Paths.PROFILE;
  static const DETAIL_PRODUCT = _Paths.DETAIL_PRODUCT;
  static const CART = _Paths.CART;
  static const LOCATION_PICKER = _Paths.LOCATION_PICKER;
  static const LIVE_TRACKING = _Paths.LIVE_TRACKING;
  static const CHECKOUT = _Paths.CHECKOUT;
  static const HISTORY = _Paths.HISTORY;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  // --- TAMBAHKAN PATH BARU ---
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const ADMIN = '/admin';
  static const SPLASH = '/splash';
  static const PROFILE = '/profile';
  static const DETAIL_PRODUCT = '/detail-product';
  static const CART = '/cart';
  static const LOCATION_PICKER = '/location-picker';
  static const LIVE_TRACKING = '/live-tracking';
  static const CHECKOUT = '/checkout';
  static const HISTORY = '/history';
}
