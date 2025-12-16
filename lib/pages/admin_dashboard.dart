import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';
import '../pages/login_page.dart';
import '../pages/manage_products_page.dart';
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

  // Fungsi Logout
  void _logout() async {
    await UserManager().logout();
    widget.appState.value.currentUser = null;
    widget.onAppStateChanged();

    if (!mounted) return;

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

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text("Yakin ingin menghapus ${product.name} secara permanen?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestoreService.deleteProduct(product.id);
              if (mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${product.name} dihapus")));
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: "Keluar dari Admin",
          )
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Belum ada produk.\nTekan + untuk menambah.",
                  textAlign: TextAlign.center),
            );
          }

          final products = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            separatorBuilder: (ctx, i) => const Divider(),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 8),
                // Jika sold out, warna card agak abu-abu
                color: product.isSold ? Colors.grey.shade200 : Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Stack(
                    children: [
                      ClipRRect(
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
                              child: const Icon(Icons.broken_image)),
                        ),
                      ),
                      // Badge SOLD kecil di gambar list admin
                      if (product.isSold)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.red.withValues(alpha: 0.8),
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: const Text("SOLD",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        )
                    ],
                  ),
                  title: Text(product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        // Coret nama jika sold
                        decoration:
                            product.isSold ? TextDecoration.lineThrough : null,
                        color: product.isSold ? Colors.grey : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.currency.format(product.price),
                          style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold)),
                      if (product.isSold)
                        const Text("Status: TERJUAL",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      ManageProductPage(product: product)));
                        },
                      ),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const ManageProductPage()));
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text("Tambah Produk", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
