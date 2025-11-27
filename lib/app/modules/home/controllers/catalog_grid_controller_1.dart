// lib/M2_T1/CatalogGridController.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CatalogGridController extends GetxController {
  // State sederhana
  Color bgColor = const Color.fromRGBO(220, 237, 200, 1);
  Color color = Colors.lightGreen.shade500;
  bool isPressed = false;

  void handleTap() {
    isPressed = !isPressed;

    if (isPressed) {
      bgColor = Colors.lightGreen.shade500;
      color = Colors.white;
    } else {
      bgColor = Colors.lightGreen.shade100;
      color = Colors.lightGreen.shade500;
    }
    // Panggil update() untuk memicu rebuild GetBuilder pada grid item
    update();
  }
}