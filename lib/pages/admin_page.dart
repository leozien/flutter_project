import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../models/order_model.dart';
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

  void _toggleTheme() {
    widget.appState.value.isDarkMode = !widget.appState.value.isDarkMode;
    widget.onAppStateChanged();
  }

  void _logout() async {
    // Tambah Konfirmasi Logout agar lebih aman
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Keluar"),
        content: const Text("Apakah Anda yakin ingin keluar dari Panel Admin?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Keluar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

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

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.appState.value.isDarkMode;
    final Color bgColor = isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
    final Color textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          "Admin Control Panel", 
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
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Profil
                  _buildHeader(textColor),
                  const SizedBox(height: 25),

                  // Statistik Utama
                  Text("Ringkasan Bisnis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.8))),
                  const SizedBox(height: 15),
                  _buildStatSection(isDark),

                  const SizedBox(height: 30),
                  Text("Manajemen Konten", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.8))),
                  const SizedBox(height: 15),

                  // Grid Menu
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
                  Center(child: Text("Leozien Market v1.0.2 • Dashboard Admin", style: TextStyle(color: textColor.withOpacity(0.3), fontSize: 11))),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color textColor) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.blueAccent.withOpacity(0.2),
          child: const Icon(Icons.admin_panel_settings, color: Colors.blueAccent, size: 30),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Halo, Administrator", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textColor)),
            Text("Kelola stok dan pantau pesanan Anda di sini", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatSection(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Produk Aktif
          _buildStatItem(
            "Total Produk", 
            _firestoreService.getProducts(), 
            Icons.layers, 
            Colors.blue, 
            isDark,
            subtitleBuilder: (data) {
              int sold = data.where((p) => (p as Product).isSold).length;
              return "$sold Terjual";
            }
          ),
          // Pendapatan (Estimasi dari Order Selesai)
          _buildStatItem(
            "Pendapatan", 
            _firestoreService.getAllOrders(), 
            Icons.account_balance_wallet, 
            Colors.green, 
            isDark,
            valueBuilder: (data) {
              int total = 0;
              for (var o in data) {
                if ((o as OrderModel).status == 'Selesai') total += o.price;
              }
              return widget.currency.format(total);
            },
            subtitleBuilder: (data) => "Dari order 'Selesai'"
          ),
          // Total Pesanan
          _buildStatItem(
            "Total Order", 
            _firestoreService.getAllOrders(), 
            Icons.receipt_long, 
            Colors.orange, 
            isDark,
            subtitleBuilder: (data) {
              int pending = data.where((o) => (o as OrderModel).status == 'Pending').length;
              return "$pending Perlu Diproses";
            }
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label, 
    Stream stream, 
    IconData icon, 
    Color color, 
    bool isDark, 
    {String Function(List)? valueBuilder, String Function(List)? subtitleBuilder}
  ) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        List data = [];
        if (snapshot.hasData && snapshot.data is List) {
          data = snapshot.data as List;
        }

        String mainValue = valueBuilder != null ? valueBuilder(data) : data.length.toString();
        String subValue = subtitleBuilder != null ? subtitleBuilder(data) : "";

        return Container(
          width: 180,
          margin: const EdgeInsets.only(right: 15),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            boxShadow: [
               if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 12),
              Text(mainValue, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black, overflow: TextOverflow.ellipsis)),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: (isDark ? Colors.white : Colors.black).withOpacity(0.7))),
              if (subValue.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(subValue, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8), fontWeight: FontWeight.bold)),
              ]
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