import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:demo_modul5/app/data/models/MeetingPointModel.dart';

class LiveTrackingController extends GetxController {
  final MeetingPoint destination = Get.arguments as MeetingPoint;

  var currentPosition = Rxn<Position>();
  var currentSpeed = 0.0.obs;
  var currentAccuracy = 0.0.obs;
  
  var isHighAccuracy = true.obs;

  StreamSubscription<Position>? _positionStreamSubscription;

  Position? _lastRecordedPosition;
  DateTime? _lastRecordedTime;

  // Konfigurasi Threshold (Batas Trigger)
  final double minDistanceChange = 2.0; // Refresh jika gerak > 2 meter
  final int minTimeInterval = 5;       // Refresh jika waktu > 10 detik

  @override
  void onInit() {
    super.onInit();
    _checkPermissions();
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "GPS belum diaktifkan");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Izin lokasi ditolak");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar("Error", "Izin lokasi ditolak permanen. Buka pengaturan HP.");
      return;
    }

    startTracking();
  }

  void startTracking() {
    _positionStreamSubscription?.cancel();

    _lastRecordedPosition = null;
    _lastRecordedTime = null;

    final LocationSettings locationSettings = LocationSettings(
      accuracy: isHighAccuracy.value ? LocationAccuracy.bestForNavigation : LocationAccuracy.low,
      distanceFilter: 0, 
    );

    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      
      if (_shouldUpdate(position)) {
        currentPosition.value = position;
        currentSpeed.value = position.speed;
        currentAccuracy.value = position.accuracy;

        _lastRecordedPosition = position;
        _lastRecordedTime = DateTime.now();
        
        print("Lokasi Diupdate: ${position.latitude}, ${position.longitude} | Akurasi: ${position.accuracy}m");
      }
    });
  }

  bool _shouldUpdate(Position newPos) {
    if (_lastRecordedPosition == null || _lastRecordedTime == null) {
      return true;
    }

    double distanceInMeters = Geolocator.distanceBetween(
      _lastRecordedPosition!.latitude,
      _lastRecordedPosition!.longitude,
      newPos.latitude,
      newPos.longitude,
    );

    final durationSinceLastUpdate = DateTime.now().difference(_lastRecordedTime!);

    bool isDistanceTrigger = distanceInMeters >= minDistanceChange;
    bool isTimeTrigger = durationSinceLastUpdate.inSeconds >= minTimeInterval;

    return isDistanceTrigger || isTimeTrigger;
  }

  void toggleMode() {
    isHighAccuracy.value = !isHighAccuracy.value;
    
    startTracking(); 
    
    Get.snackbar(
      "Mode Berubah", 
      isHighAccuracy.value ? "High Accuracy (GPS)" : "Low Accuracy (Network/WiFi)",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}