import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_modul5/app/data/models/MeetingPointModel.dart';
import 'package:demo_modul5/app/data/services/supabase_service.dart';
import 'package:demo_modul5/app/modules/liveTracking/views/live_tracking_view.dart';

class HistoryController extends GetxController {
  final SupabaseClient supabase = Get.find<SupabaseService>().client;
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    try {
      isLoading.value = true;
      final user = supabase.auth.currentUser;

      final response = await supabase
          .from('orders')
          .select('*, meeting_points(*)')
          .eq('user_id', user!.id)
          .order('created_at', ascending: false);

      orders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat riwayat: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void resumeTracking(Map<String, dynamic> order) {
    final meetingData = order['meeting_points'];

    if (meetingData != null) {
      final point = MeetingPoint.fromSupabase(meetingData);

      Get.to(() => const LiveTrackingView(), arguments: point);
    } else {
      Get.snackbar("Error", "Data lokasi tidak ditemukan");
    }
  }
}
