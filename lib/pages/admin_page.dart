import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../services/firestore_service.dart'; // ✅ Import Service Firebase
import '../pages/login_page.dart';
import '../pages/manage_products_page.dart';
import '../pages/user_manager.dart'; // ✅ Import UserManager untuk Logout

class AdminPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final List<Product> products;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;
  final dynamic
      productManager; // Tidak dipakai lagi tapi dibiarkan agar tidak error di main.dart

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
  // ✅ Panggil Service Database
  final FirestoreService _firestoreService = FirestoreService();

  // --- FUNGSI LOGOUT ---
  void _logout() async {
    // 1. Logout dari Firebase
    await UserManager().logout();

    // 2. Reset user di AppState
    widget.appState.value.currentUser = null;
    widget.onAppStateChanged();

    if (!mounted) return;

    // 3. Navigasi kembali ke Login Page
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

  // --- FUNGSI HAPUS PRODUK ---
  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text(
            "Yakin ingin menghapus ${product.name} secara permanen dari server?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // ✅ Hapus dari Firebase
              await _firestoreService.deleteProduct(product.id);
              if (mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("${product.name} berhasil dihapus")),
              );
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: "Logout",
          )
        ],
      ),
      // ✅ GUNAKAN STREAMBUILDER (REAL-TIME)
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }

          // 3. Data Kosong
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada produk di Server.\nTekan tombol + untuk menambah.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final products = snapshot.data!;

          // 4. List Produk
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child:
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    widget.currency.format(product.price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOMBOL EDIT
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ManageProductPage(product: product),
                            ),
                          );
                        },
                      ),
                      // TOMBOL HAPUS
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(product),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // TOMBOL TAMBAH PRODUK (+)
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          // BUKA HALAMAN TAMBAH PRODUK
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ManageProductPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
