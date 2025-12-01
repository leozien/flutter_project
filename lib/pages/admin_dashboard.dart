import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_products.dart'; // Akses ke data produk
import '../models/product.dart';
import 'manage_products_page.dart'; // Import halaman form
// import 'home_page.dart'; // HAPUS ATAU KOMENTAR INI (Tidak lagi dibutuhkan jika pakai pop)

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil instance ProductManager
    // CATATAN: Idealnya ini dikirim dari main.dart agar data sinkron dengan Home
    final productManager = ProductManager();
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Kembali ke Menu Utama",
            onPressed: () {
              // --- PERBAIKAN FINAL ---
              // Cukup gunakan pop untuk menutup Admin dan kembali ke Home yang ada di belakangnya.
              // Ini menghilangkan error parameter HomePage yang rumit.
              Navigator.pop(context);
            },
          ),
        ],
      ),
      // Menggunakan ValueListenableBuilder agar List otomatis update
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: productManager.productsNotifier,
        builder: (context, products, child) {
          if (products.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada produk.\nTekan tombol + untuk menambah.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            padding: const EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: AssetImage(product.image),
                        fit: BoxFit.cover,
                        onError: (obj, stack) {},
                      ),
                    ),
                    child: product.image.isEmpty
                        ? const Icon(Icons.image, color: Colors.grey)
                        : null,
                  ),
                  title: Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    currencyFormat.format(product.price),
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.w600),
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
                              builder: (context) =>
                                  ManageProductPage(product: product),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Hapus Produk?"),
                              content: Text(
                                  "Yakin ingin menghapus ${product.name}?"),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Batal"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    productManager.deleteProduct(product.id);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("${product.name} dihapus")),
                                    );
                                  },
                                  child: const Text("Hapus",
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageProductPage()),
          );
        },
      ),
    );
  }
}
