import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../pages/login_page.dart';
import '../pages/manage_products_page.dart';
import 'manage_orders_page.dart'; 
import 'manage_users_page.dart';
import 'manage_promos_page.dart';
import '../pages/user_manager.dart';

class AdminPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final List<Product> products;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;
  final dynamic productManager;

  const AdminPage({
    super.key,
    required this.appState,
    required this.products,
    required this.onAppStateChanged,
    required this.currency,
    required this.productManager,
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirestoreService _firestoreService = FirestoreService();

  // Fungsi Ganti Tema
  void _toggleTheme() {
    widget.appState.value.isDarkMode = !widget.appState.value.isDarkMode;
    widget.onAppStateChanged();
  }

  // Perbaikan Logout: Tambah Konfirmasi & Mounted Guard
  void _logout() async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari Admin Panel?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), 
            child: const Text("Batal")
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await UserManager().logout();
      if (!mounted) return;

      widget.appState.value.currentUser = null;
      widget.onAppStateChanged();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(
            appState: widget.appState,
            products: [],
            onAppStateChanged: widget.onAppStateChanged,
            currency: widget.currency,
            productManager: widget.productManager,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.appState.value.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Control Panel", 
          style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 1),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _toggleTheme,
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: textColor),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900), // Membatasi lebar di Laptop
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Profil Admin
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.blueAccent.withOpacity(0.2),
                        child: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Halo, Administrator", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                          Text("Overview sistem hari ini", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // Bagian Statistik Real-time
                  _buildStatSection(isDark),

                  const SizedBox(height: 30),
                  Text("Manajemen Konten", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.8))),
                  const SizedBox(height: 15),

                  // Grid Menu Responsif
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: 1.0,
                    ),
                    children: [
                      _buildElegantCard("Produk", Icons.inventory_2_outlined, const Color(0xFF6C63FF), const ManageProductPage(), isDark),
                      _buildElegantCard("Pesanan", Icons.shopping_bag_outlined, const Color(0xFFFF6584), const ManageOrdersPage(), isDark),
                      _buildElegantCard("Pengguna", Icons.people_outline_rounded, const Color(0xFF43CBFF), const ManageUsersPage(), isDark),
                      _buildElegantCard("Promo", Icons.auto_awesome_outlined, const Color(0xFF2AF598), const ManagePromosPage(), isDark),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  Center(child: Text("Versi 1.0.2 • Made with Flutter", style: TextStyle(color: textColor.withOpacity(0.3), fontSize: 11))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatSection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatItem("Total Produk", _firestoreService.getProducts(), Icons.layers, Colors.blue, isDark),
          _buildStatItem("Total Pesanan", _firestoreService.getAllOrders(), Icons.receipt_long, Colors.orange, isDark),
          _buildStatItem("Total User", _firestoreService.getAllUsers(), Icons.person_search, Colors.green, isDark),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, Stream stream, IconData icon, Color color, bool isDark) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        int count = 0;
        if (snapshot.hasData && snapshot.data is List) {
          count = (snapshot.data as List).length;
        }
        return Container(
          width: 150,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 10),
              Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black)),
              Text(label, style: TextStyle(fontSize: 11, color: (isDark ? Colors.white : Colors.black).withOpacity(0.5))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildElegantCard(String title, IconData icon, Color color, Widget target, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.4) : Colors.blueGrey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => target)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Icon(icon, size: 28, color: color),
              ),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: isDark ? Colors.white.withOpacity(0.9) : Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}