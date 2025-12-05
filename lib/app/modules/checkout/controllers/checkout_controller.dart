import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/data/models/MeetingPointModel.dart';
import 'package:demo_modul5/app/modules/cart/controllers/cart_controller.dart';
import 'package:demo_modul5/app/modules/locationPicker/views/location_picker_view.dart';
import 'package:demo_modul5/app/modules/liveTracking/views/live_tracking_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';

class CheckoutController extends GetxController {
  final CartController cartC = Get.find<CartController>();
  final SupabaseClient supabase = Get.find<SupabaseService>().client;
  final addressController = TextEditingController();

  var selectedDeliveryMethod = 'cod'.obs;
  var selectedMeetingPoint = Rxn<MeetingPoint>();
  var selectedExpedition = 'JNE'.obs;
  var isLoading = false.obs;

  double get shippingFee => selectedDeliveryMethod.value == 'cod' ? 0.0 : 25.0;
  double get finalTotal => cartC.totalAmount + shippingFee;

  Future<void> pickLocation() async {
    final result = await Get.to(() => const LocationPickerView());
    if (result != null && result is MeetingPoint) {
      selectedMeetingPoint.value = result;
    }
  }

  Future<void> placeOrder() async {
    if (selectedDeliveryMethod.value == 'cod' && selectedMeetingPoint.value == null) {
      Get.snackbar("Error", "Pilih lokasi pertemuan untuk COD!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    if (selectedDeliveryMethod.value == 'expedition' && addressController.text.isEmpty) {
      Get.snackbar("Error", "Masukkan alamat pengiriman!", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw "User tidak terdeteksi";
      
      final orderData = {
        'user_id': user.id,
        'total_amount': finalTotal,
        'delivery_method': selectedDeliveryMethod.value,
        'status': 'Pending',
        'meeting_point_id': selectedDeliveryMethod.value == 'cod' ? selectedMeetingPoint.value!.id : null,
        'shipping_address': selectedDeliveryMethod.value == 'expedition' ? addressController.text : null,
      };

      await supabase.from('orders').insert(orderData);

      await cartC.clearCart(); 

      isLoading.value = false;

      Get.defaultDialog(
        title: "Order Berhasil",
        middleText: "Pesanan Anda telah disimpan.",
        barrierDismissible: false,
        confirm: ElevatedButton(
          onPressed: () {
            Get.back(); // Tutup Dialog
            Get.back(); // Tutup Halaman Checkout
            
            // Jika COD, tawarkan langsung tracking
            if (selectedDeliveryMethod.value == 'cod') {
               Get.to(() => const LiveTrackingView(), arguments: selectedMeetingPoint.value);
            }
          }, 
          child: Text(selectedDeliveryMethod.value == 'cod' ? "Buka Peta Tracking" : "OK")
        )
      );

    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Gagal", "Terjadi kesalahan: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
