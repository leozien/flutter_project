import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ FIX: Import untuk NumberFormat

import '../models/app_state.dart';
import '../models/product.dart';
import '../data/dummy_products.dart'; // ✅ FIX: Import untuk ProductManager
import '../pages/login_page.dart';

class AdminPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final List<Product> products;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;
  final ProductManager productManager; // ✅ FIX: Tambah parameter ini

  const AdminPage({
    super.key,
    required this.appState,
    required this.products,
    required this.onAppStateChanged,
    required this.currency,
    required this.productManager, // ✅ FIX: Wajib ada di konstruktor
  });

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // =========================
  // LOGOUT
  // =========================
  void _logout() {
    widget.appState.value = widget.appState.value.copyWith(currentUser: null);
    widget.onAppStateChanged();

    Future.microtask(() {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginPage(
            appState: widget.appState,
            products: widget.products,
            onAppStateChanged: widget.onAppStateChanged,
            currency: widget.currency,
            productManager:
                widget.productManager, // ✅ FIX: Teruskan ke LoginPage
          ),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "WELCOME ADMIN 👑",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text("Kelola produk dan transaksi di sini."),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tambah logika tambah produk di sini
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Fitur Tambah Produk")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
