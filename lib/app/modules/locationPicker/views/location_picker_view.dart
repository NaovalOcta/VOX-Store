import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/location_picker_controller.dart';

class LocationPickerView extends StatelessWidget {
  const LocationPickerView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationPickerController());

    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Titik COD")),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(-7.9213, 112.5993), // UMM
                initialZoom: 13.0,
                onTap: (_, __) => controller.selectedPoint.value = null,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.vox_store', // Ganti sesuai package name
                ),
                MarkerLayer(
                  markers: controller.meetingPoints.map((point) {
                    final isSelected = controller.selectedPoint.value?.id == point.id;
                    return Marker(
                      point: LatLng(point.latitude, point.longitude),
                      width: 80,
                      height: 80,
                      child: GestureDetector(
                        onTap: () => controller.selectPoint(point),
                        child: Column(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: isSelected ? 50 : 40,
                              color: isSelected ? Colors.red : Colors.redAccent,
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black26)]
                                ),
                                child: Text(
                                  point.name, 
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            
            if (controller.selectedPoint.value != null)
              Positioned(
                bottom: 30, left: 20, right: 20,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Lokasi Dipilih:", style: TextStyle(color: Colors.grey)),
                        Text(controller.selectedPoint.value!.name, 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: controller.confirmSelection,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B9EE1)),
                            child: const Text("Pilih Lokasi Ini", style: TextStyle(color: Colors.white)),
                          ),
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
}