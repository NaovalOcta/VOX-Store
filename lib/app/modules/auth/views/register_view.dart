import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema Gelap/Terang
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color bgColor = isDark ? const Color(0xFF1E2329) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E2329);
    final Color inputFill = isDark ? const Color(0xFF2A2F36) : const Color(0xFFF7F7F9);
    const Color primaryBlue = Color(0xFF5B9EE1); // Warna aksen utama

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.shade100,
            ),
            child: Icon(Icons.arrow_back_ios_new, size: 16, color: textColor),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's Create Account Together",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Name Input (Dummy)
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Your Name", 
                  style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFill,
                  hintText: 'Alisson Becker',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Email Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Email Address", 
                  style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.emailC,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFill,
                  hintText: 'alissonbecker@gmail.com',
                  hintStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 20),

              // Password Input
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Password", 
                  style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller.passwordC,
                obscureText: true,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputFill,
                  hintText: '●●●●●●●●',
                  hintStyle: const TextStyle(color: Colors.grey),
                  suffixIcon: const Icon(Icons.visibility_off_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.register(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isLoading.value 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Sign Up", 
                        style: TextStyle(
                          fontSize: 16, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                        ),
                      ),
                )),
              ),

              const SizedBox(height: 30),

              // Google Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata, size: 30),
                  label: Text(
                    "Sign in with google",
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    side: BorderSide(color: isDark ? Colors.transparent : Colors.grey.shade200),
                    backgroundColor: inputFill,
                  ),
                ),
              ),

              const SizedBox(height: 50),
              
              // --- BAGIAN YANG DIPERBAIKI ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already Have An Account? ", style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Text(
                      "Sign In",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primaryBlue, // MENGGUNAKAN WARNA BIRU AGAR TERLIHAT
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}