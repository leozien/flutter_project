import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/app_state.dart';
import 'edit_profile_page.dart';
import 'admin_dashboard.dart'; // PENTING: Import Dashboard Admin agar bisa dinavigasi

// Data global sementara (bisa dipindah ke database nanti)
String globalName = "Pengguna Baru";
String globalEmail = "email@example.com";
String globalHP = "08xxxxxxxxxx";

class ProfilePage extends StatelessWidget {
  final ValueNotifier<AppState> appState;
  final VoidCallback onAppStateChanged;

  const ProfilePage({
    super.key,
    required this.appState,
    required this.onAppStateChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Cek apakah user login DAN apakah dia admin
    // Pastikan di model AppState kamu ada variable 'isAdmin'
    // Jika belum ada, ganti baris ini menjadi: bool isAdmin = appState.value.isLoggedIn;
    bool isAdmin = appState.value.isLoggedIn && appState.value.isAdmin;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Profil"),
        backgroundColor: Colors.black.withOpacity(0.3),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "assets/leozien.jpeg",
              fit: BoxFit.cover,
              errorBuilder: (ctx, err, stack) =>
                  Container(color: Colors.grey[900]),
            ),
          ),
          // Overlay Gelap
          Container(
            color: Colors.black.withOpacity(0.45),
          ),

          // MAIN UI
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 120, left: 20, right: 20),
            child: Column(
              children: [
                // Avatar
                const CircleAvatar(
                  radius: 55,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 60, color: Colors.black87),
                ),
                const SizedBox(height: 15),

                // Nama User / Label Admin
                Text(
                  isAdmin ? "ADMINISTRATOR" : globalName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),

                const SizedBox(height: 25),

                // Frosted Glass Card
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white30),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          itemTile("Email", globalEmail),
                          itemTile("Nomor HP", globalHP),
                          const Divider(color: Colors.white30, height: 28),

                          // --- FITUR KHUSUS ADMIN ---
                          if (isAdmin) ...[
                            ElevatedButton.icon(
                              onPressed: () {
                                // NAVIGASI KE ADMIN DASHBOARD (List Produk)
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AdminDashboard(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.inventory_2),
                              label: const Text("Kelola Katalog Produk"),
                              style: buttonStyle().copyWith(
                                backgroundColor:
                                    MaterialStateProperty.all(Colors.redAccent),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Divider(color: Colors.redAccent, height: 28),
                          ],

                          // --- TOMBOL WISHLIST ---
                          ElevatedButton.icon(
                            onPressed: () {
                              final wishlistIds = appState.value.wishlist;
                              final message = wishlistIds.isEmpty
                                  ? 'Wishlist kosong'
                                  : 'Wishlist: ${wishlistIds.join(', ')}';

                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(message)));
                            },
                            icon: const Icon(Icons.favorite),
                            label: const Text("Lihat Wishlist"),
                            style: buttonStyle(),
                          ),

                          const SizedBox(height: 10),

                          // --- TOMBOL EDIT PROFIL ---
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditProfilePage(
                                    onSaved: () => onAppStateChanged(),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text("Edit Profil"),
                            style: buttonStyle(),
                          ),

                          const SizedBox(height: 10),

                          // Badge Info Admin
                          if (isAdmin)
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.redAccent.withOpacity(.3),
                                border: Border.all(color: Colors.redAccent),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.security,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    "Admin Mode Aktif",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget itemTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, color: Colors.white70, letterSpacing: .3)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.8),
      foregroundColor: Colors.black87,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
