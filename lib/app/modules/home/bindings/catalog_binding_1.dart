import 'package:demo_modul5/app/modules/home/controllers/catalog_controller_2.dart';
import 'package:demo_modul5/app/modules/home/controllers/catalog_grid_controller_1.dart';
import 'package:demo_modul5/app/modules/auth/controllers/auth_controller.dart';
import 'package:demo_modul5/app/modules/profile/controllers/profile_controller.dart';
import 'package:demo_modul5/app/modules/cart/controllers/cart_controller.dart';
import 'package:get/get.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CatalogController>(() => CatalogController());

    Get.lazyPut<CatalogGridController>(() => CatalogGridController());

    Get.lazyPut<AuthController>(() => AuthController());

    Get.lazyPut<ProfileController>(() => ProfileController());

    Get.put<CartController>(CartController(), permanent: true);
  }
}
