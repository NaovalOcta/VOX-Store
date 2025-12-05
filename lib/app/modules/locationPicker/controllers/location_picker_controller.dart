import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo_modul5/app/data/models/MeetingPointModel.dart'; // Sesuaikan nama package Anda
import 'package:demo_modul5/app/data/services/supabase_service.dart';

class LocationPickerController extends GetxController {
  final SupabaseClient supabase = Get.find<SupabaseService>().client;
  
  var meetingPoints = <MeetingPoint>[].obs;
  var selectedPoint = Rxn<MeetingPoint>();
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMeetingPoints();
  }

  Future<void> fetchMeetingPoints() async {
    try {
      isLoading.value = true;
      final response = await supabase.from('meeting_points').select().eq('is_active', true);
      final List<dynamic> data = response;
      meetingPoints.value = data.map((json) => MeetingPoint.fromSupabase(json)).toList();
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat peta: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void selectPoint(MeetingPoint point) {
    selectedPoint.value = point;
  }

  void confirmSelection() {
    if (selectedPoint.value != null) {
      Get.back(result: selectedPoint.value);
    }
  }
}