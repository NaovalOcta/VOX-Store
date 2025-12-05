import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingView extends StatelessWidget {
  const LiveTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LiveTrackingController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("OTW Lokasi COD"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_input_antenna),
            onPressed: () => controller.toggleMode(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.currentPosition.value == null) {
          return const Center(child: Text("Mencari Sinyal GPS..."));
        }

        final myPos = LatLng(
          controller.currentPosition.value!.latitude,
          controller.currentPosition.value!.longitude,
        );
        final destPos = LatLng(
          controller.destination.latitude,
          controller.destination.longitude,
        );

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(initialCenter: myPos, initialZoom: 16.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [myPos, destPos],
                      strokeWidth: 4.0,
                      color: Colors.blue,
                      pattern: const StrokePattern.dotted(),
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: myPos,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.directions_walk,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),
                    Marker(
                      point: destPos,
                      width: 60,
                      height: 60,
                      child: const Icon(
                        Icons.flag,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _info(
                        "Speed",
                        "${controller.currentSpeed.value.toStringAsFixed(1)} m/s",
                      ),
                      _info(
                        "Akurasi",
                        "${controller.currentAccuracy.value.toStringAsFixed(1)} m",
                      ),
                      _info(
                        "Mode",
                        controller.isHighAccuracy.value ? "GPS" : "Net",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _info(String label, String value) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 10)),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
