import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:demo_modul5/app/modules/profile/controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2329);
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    final bgColor = isDark ? const Color(0xFF181C24) : const Color(0xFFFAFAFA);
    const primaryBlue = Color(0xFF5B9EE1);

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- 1. HEADER PROFIL ---
            Obx(
              () => Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: primaryBlue, width: 3),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://ui-avatars.com/api/?name=User&background=random",
                            ), // Placeholder Avatar
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(color: bgColor, width: 3),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.name.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.email.value,
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. MENU SECTIONS ---

            // Section: Account
            _buildSectionHeader("Account Settings", textColor),
            _buildMenuTile(
              context,
              icon: Icons.person_outline,
              title: "Edit Profile",
              onTap: () {},
            ),
            _buildMenuTile(
              context,
              icon: Icons.location_on_outlined,
              title: "Shipping Address",
              onTap: () {},
            ),
            _buildMenuTile(
              context,
              icon: Icons.history,
              title: "Order History",
              onTap: () {},
            ),
            _buildMenuTile(
              context,
              icon: Icons.account_balance_wallet_outlined,
              title: "Cards & Wallet",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // Section: App Settings
            _buildSectionHeader("App Settings", textColor),
            _buildMenuTile(
              context,
              icon: Icons.notifications_none,
              title: "Notifications",
              trailing: Switch(
                value: true,
                onChanged: (val) {},
                activeThumbColor: primaryBlue,
              ),
              onTap: () {},
            ),
            Obx(
              () => _buildMenuTile(
                context,
                icon: controller.themeService.isDarkMode.value
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
                title: "Dark Mode",
                trailing: Switch(
                  value: controller.themeService.isDarkMode.value,
                  onChanged: (val) => controller.themeService.toggleTheme(),
                  activeThumbColor: primaryBlue,
                ),
                onTap: () => controller.themeService.toggleTheme(),
              ),
            ),

            const SizedBox(height: 30),

            // --- 3. LOGOUT BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => controller.logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent.withOpacity(0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  "Log Out",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // Ruang kosong di bawah agar tidak tertutup Navbar
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2A2F36) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2329);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF5B9EE1).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF5B9EE1), size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: textColor,
            fontSize: 15,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
      ),
    );
  }
}
