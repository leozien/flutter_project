import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/app_state.dart';
import '../services/url_launcher_service.dart';

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
  // Menghitung total harga: (Harga Produk x Jumlah)
  int get total {
    return widget.appState.value.cart.fold(0, (sum, item) {
      return sum + (item.product.price * item.quantity);
    });
  }

  // Mengurangi jumlah item sebanyak 1
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

  // Menghapus item dari keranjang sepenuhnya
  void _removeAllOf(CartItem item) {
    setState(() {
      widget.appState.value.cart.remove(item);
    });
    widget.onAppStateChanged();
  }

  // Mengosongkan keranjang
  void _clearCart() {
    setState(() {
      widget.appState.value.cart.clear();
    });
    widget.onAppStateChanged();
  }

  @override
  Widget build(BuildContext context) {
    // items sekarang adalah List<CartItem>, bukan List<Product>
    final items = widget.appState.value.cart;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(child: Text('Keranjang kosong'))
                  : ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = item.product;

                        return ListTile(
                          leading: Image.asset(
                            product.image,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (ctx, error, stack) => Container(
                                color: Colors.grey, width: 60, height: 60),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${widget.currency.format(product.price)} x ${item.quantity} = ${widget.currency.format(product.price * item.quantity)}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeSingle(item),
                              ),
                              Text(
                                '${item.quantity}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever,
                                    color: Colors.red),
                                onPressed: () => _removeAllOf(item),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            // Bagian Bawah: Total & Tombol Aksi
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${widget.currency.format(total)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                          // Gabungkan nama produk untuk query pencarian
                          final q = items.map((e) => e.product.name).join(', ');
                          final Uri url = Uri.parse(
                            'https://www.tokopedia.com/search?navsource=product&q=${Uri.encodeComponent(q)}',
                          );
                          await openUrl(url, context);
                        },
                  child: const Text('Checkout (Tokopedia)'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: items.isEmpty ? null : _clearCart,
                  child: const Text('Kosongkan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
