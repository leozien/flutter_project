import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart'; // 1. IMPORT INI PENTING
import '../models/app_state.dart';
import '../models/product.dart';

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
  // --- Fungsi Add to Cart (Kode sebelumnya) ---
  void _addToCart() {
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
          content: Text('${widget.product.name} berhasil masuk keranjang!'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // 2. FUNGSI BARU: Buka WhatsApp (Beli Sekarang)
  Future<void> _buyNow() async {
    // Mengambil URL dari dummy_products.dart (shopUrl)
    final String urlString = widget.product.shopUrl;
    final Uri url = Uri.parse(urlString);

    try {
      // Membuka link secara eksternal (masuk ke aplikasi WA / Browser)
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Jika gagal (misal di emulator tidak ada WA), tampilkan error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal membuka WhatsApp / Link error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.appState.value.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subTextColor = isDarkMode ? Colors.white70 : Colors.black54;
    final bgColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: bgColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gambar Produk
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.asset(
              widget.product.image,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (ctx, error, stack) => Container(
                height: 200,
                color: Colors.grey,
                child: const Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama Produk
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),

                // Harga
                Text(
                  widget.currency.format(widget.product.price),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Deskripsi
                Text(
                  widget.product.desc,
                  style: TextStyle(fontSize: 14, color: subTextColor),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),

                // --- TOMBOL AKSI (ROW) ---
                SingleChildScrollView(
                  // Tambahkan scroll horizontal jika layar sempit
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tombol Tutup
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("Tutup"),
                      ),

                      const SizedBox(width: 8),

                      // 3. TOMBOL BARU: Beli Sekarang (WhatsApp)
                      ElevatedButton.icon(
                        onPressed: _buyNow,
                        // Ganti Icons.whatsapp dengan Icons.chat
                        icon: const Icon(Icons.chat),
                        label: const Text("Beli Sekarang"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Tombol Keranjang
                      ElevatedButton.icon(
                        onPressed: _addToCart,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Keranjang"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
