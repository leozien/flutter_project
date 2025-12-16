import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class DetailDialog extends StatefulWidget {
  final Product product;
  final ValueNotifier<AppState> appState;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;

  const DetailDialog({
    super.key,
    required this.product,
    required this.appState,
    required this.onAppStateChanged,
    required this.currency,
  });

  @override
  State<DetailDialog> createState() => _DetailDialogState();
}

class _DetailDialogState extends State<DetailDialog> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isProcessing = false;

  // --- LOGIKA ADD TO CART (TETAP BUTUH LOGIN) ---
  void _addToCart() {
    final user = widget.appState.value.currentUser;

    // 🔒 PENGAMAN: Hanya User Login yang boleh masuk keranjang
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan Login untuk menambah ke Keranjang."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final List<CartItem> newCart = List.from(widget.appState.value.cart);
    final product = widget.product;
    final existingIndex =
        newCart.indexWhere((item) => item.product.name == product.name);

    if (existingIndex != -1) {
      newCart[existingIndex].quantity++;
    } else {
      newCart.add(CartItem(product: product, quantity: 1));
    }

    widget.appState.value = widget.appState.value.copyWith(cart: newCart);
    widget.onAppStateChanged();

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} masuk keranjang!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // --- LOGIKA BELI SEKARANG (BISA TAMU) ---
  Future<void> _buyNow() async {
    final user = widget.appState.value.currentUser;

    setState(() => _isProcessing = true);

    try {
      // 1. Tentukan Identitas Pembeli
      String userId;
      String userName;

      if (user != null) {
        // Jika User Login
        userId = user.email;
        userName = user.email;
      } else {
        // ✅ JIKA TAMU: Buat ID Sementara
        userId = "guest-${DateTime.now().millisecondsSinceEpoch}";
        userName = "Tamu (Guest)";
      }

      // 2. Buat ID Pesanan Unik
      final orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";

      final newOrder = OrderModel(
        id: orderId,
        userId: userId,
        userName: userName,
        productName: widget.product.name,
        price: widget.product.price,
        status: 'Pending',
        timestamp: DateTime.now(),
      );

      // 3. Simpan ke Firebase (Tamu juga bisa simpan order)
      await _firestoreService.placeOrder(newOrder);

      // 4. Buka WhatsApp
      const String adminNumber = "6282341361739";
      final String message = "Halo Admin, saya ingin membeli:\n"
          "Produk: ${widget.product.name}\n"
          "Harga: ${widget.currency.format(widget.product.price)}\n"
          "Pembeli: $userName\n"
          "Order ID: $orderId\n\n"
          "Mohon diproses. Terima kasih!";

      final Uri url = Uri.parse(
          "https://wa.me/$adminNumber?text=${Uri.encodeComponent(message)}");

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Pesanan dibuat! Silakan lanjut di WhatsApp."),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.appState.value.isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;
    final borderColor = isDarkMode ? Colors.white12 : Colors.grey.shade200;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      backgroundColor: bgColor,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER GAMBAR ---
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.asset(
                    widget.product.image,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stack) => Container(
                      height: 220,
                      color: isDarkMode ? Colors.black : Colors.grey.shade200,
                      child: Center(
                          child: Icon(Icons.broken_image,
                              size: 50, color: subTextColor)),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ),
                // Badge Promo
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "HOT PROMO",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),

            // --- KONTEN INFORMASI ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.currency.format(widget.product.price),
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: borderColor),
                    const SizedBox(height: 10),
                    Text("Deskripsi Produk",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Text(
                        widget.product.desc.isEmpty
                            ? "Tidak ada deskripsi untuk produk ini."
                            : widget.product.desc,
                        style: TextStyle(
                            fontSize: 14, color: subTextColor, height: 1.5),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // --- TOMBOL AKSI ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(top: BorderSide(color: borderColor)),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // Tombol Keranjang (Masih Butuh Login)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("Keranjang"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textColor,
                        side:
                            BorderSide(color: textColor.withValues(alpha: 0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Tombol Beli (Sekarang Terbuka untuk Tamu)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _buyNow,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.flash_on),
                      label:
                          Text(_isProcessing ? "Proses..." : "Beli Sekarang"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
