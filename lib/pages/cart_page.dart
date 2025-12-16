import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_state.dart';
// import '../models/product.dart'; // ❌ Dihapus karena tidak terpakai (Unused import)
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class CartPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;

  const CartPage({
    super.key,
    required this.appState,
    required this.onAppStateChanged,
    required this.currency,
  });

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  // --- HITUNG TOTAL HARGA ---
  int get total {
    return widget.appState.value.cart.fold(0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
  }

  // --- FUNGSI KURANGI JUMLAH ---
  void _removeSingle(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        widget.appState.value.cart.remove(item);
      }
    });
    widget.onAppStateChanged();
  }

  // --- FUNGSI TAMBAH JUMLAH ---
  void _addSingle(CartItem item) {
    setState(() {
      item.quantity++;
    });
    widget.onAppStateChanged();
  }

  // --- FUNGSI HAPUS ITEM ---
  void _removeAllOf(CartItem item) {
    setState(() {
      widget.appState.value.cart.remove(item);
    });
    widget.onAppStateChanged();
  }

  // --- FUNGSI CHECKOUT KE WHATSAPP & DATABASE ---
  Future<void> _checkout() async {
    final user = widget.appState.value.currentUser;
    final cart = widget.appState.value.cart;

    if (cart.isEmpty) return;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Silakan Login terlebih dahulu."),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1. Simpan Setiap Item ke Firebase (Agar muncul di Riwayat)
      final timestamp = DateTime.now();
      String orderSummary = ""; // Untuk pesan WA

      for (var item in cart) {
        // Buat ID unik untuk setiap item
        final orderId =
            "ORD-${timestamp.millisecondsSinceEpoch}-${item.product.name.hashCode}";

        final newOrder = OrderModel(
          id: orderId,
          userId: user.email,
          userName: user.email,
          productName: "${item.product.name} (x${item.quantity})",
          price: item.product.price * item.quantity,
          status: 'Pending',
          timestamp: timestamp,
        );

        await _firestoreService.placeOrder(newOrder);

        // Tambahkan ke ringkasan WA
        orderSummary +=
            "- ${item.product.name} (x${item.quantity}) = ${widget.currency.format(item.product.price * item.quantity)}\n";
      }

      // 2. Buka WhatsApp
      final String totalStr = widget.currency.format(total);
      final String message = "Halo Admin Leozien Market 👋\n"
          "Saya ingin checkout pesanan:\n\n"
          "$orderSummary\n"
          "*Total Bayar: $totalStr*\n\n"
          "Mohon diproses. Terima kasih!";

      // Ganti nomor ini dengan nomor admin Anda
      const String adminNumber = "6282341361739";
      final Uri url = Uri.parse(
          "https://wa.me/$adminNumber?text=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);

        // 3. Kosongkan Keranjang setelah berhasil
        setState(() {
          widget.appState.value.cart.clear();
          widget.onAppStateChanged();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Pesanan berhasil dibuat!"),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context); // Kembali ke Home
        }
      } else {
        throw "Tidak bisa membuka WhatsApp";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal Checkout: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.appState.value.isDarkMode;
    final bgColor =
        isDarkMode ? Colors.black : Colors.white; // Full Black/White
    final cardColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey.shade50;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final items = widget.appState.value.cart;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text("Keranjang Belanja",
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.redAccent),
              onPressed: () {
                setState(() {
                  items.clear();
                  widget.onAppStateChanged();
                });
              },
              tooltip: "Hapus Semua",
            )
        ],
      ),
      body: Column(
        children: [
          // LIST BARANG
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_cart_outlined,
                            size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text("Keranjang masih kosong",
                            style: TextStyle(
                                color: textColor.withValues(alpha: 0.6))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = item.product;

                      return Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: isDarkMode
                                  ? Colors.white10
                                  : Colors.grey.shade200),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Gambar Produk
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                product.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, error, stack) => Container(
                                    color: Colors.grey, width: 70, height: 70),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Detail Produk
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.currency.format(product.price),
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            // Kontrol Kuantitas
                            Row(
                              children: [
                                _qtyButton(Icons.remove,
                                    () => _removeSingle(item), isDarkMode),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  child: Text('${item.quantity}',
                                      style: TextStyle(
                                          color: textColor,
                                          fontWeight: FontWeight.bold)),
                                ),
                                _qtyButton(Icons.add, () => _addSingle(item),
                                    isDarkMode),
                                const SizedBox(width: 10),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.redAccent, size: 20),
                                  onPressed: () => _removeAllOf(item),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // BAGIAN BAWAH (TOTAL & CHECKOUT)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total Pembayaran",
                          style: TextStyle(
                              color: textColor.withValues(alpha: 0.7),
                              fontSize: 14)),
                      Text(
                        widget.currency.format(total),
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed:
                          (items.isEmpty || _isProcessing) ? null : _checkout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // Khas WhatsApp
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons
                              .chat), // ✅ Diubah ke Icons.chat karena Icons.whatsapp tidak ada
                      label: Text(
                          _isProcessing
                              ? "Memproses..."
                              : "Checkout via WhatsApp",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper untuk Tombol +/-
  Widget _qtyButton(IconData icon, VoidCallback onTap, bool isDarkMode) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white10 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            size: 16, color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
