import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/auth/controllers/auth_controller.dart';
import '../controllers/admin_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AdminController>(() => AdminController());
    // Admin view juga butuh AuthController untuk logout
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
