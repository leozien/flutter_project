import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../pages/detail_dialog.dart'; // Pastikan file ini sudah diisi kode baru di atas
import '../pages/cart_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../data/dummy_products.dart';

class HomePage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final List<Product> products;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;
  final ProductManager productManager;

  const HomePage({
    super.key,
    required this.appState,
    required this.products,
    required this.onAppStateChanged,
    required this.currency,
    required this.productManager,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String searchQuery = '';
  bool _isDarkMode = true;

  late AnimationController _controller;
  late Animation<double> fadeAnimation;

  late AnimationController popupController;
  late Animation<double> scaleAnimation;

  bool contactOpen = false;
  bool adminOnline = true; // Status simulasi admin online

  final List<String> promoImages = [
    "assets/pro1.jpeg",
    "assets/pro2.jpeg",
    "assets/pro3.jpeg",
    "assets/pro4.jpeg",
  ];

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.appState.value.isDarkMode;
    widget.productManager.productsNotifier.addListener(_onProductsChanged);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);
    _controller.forward();

    popupController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    scaleAnimation =
        CurvedAnimation(parent: popupController, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    widget.productManager.productsNotifier.removeListener(_onProductsChanged);
    _controller.dispose();
    popupController.dispose();
    super.dispose();
  }

  void _onProductsChanged() {
    setState(() {});
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      widget.appState.value.isDarkMode = _isDarkMode;
      widget.onAppStateChanged();
    });
  }

  List<Product> get filteredProducts {
    final List<Product> currentProducts =
        widget.productManager.productsNotifier.value;
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return currentProducts;

    return currentProducts
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
  }

  // --- FUNGSI NAVIGASI ---
  void _openUserDashboard() {
    Navigator.pushNamed(context, '/user_dashboard');
  }

  void _openAdminPage() {
    Navigator.pushNamed(context, '/admin');
  }

  Future<void> _logout() async {
    bool? keluar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Konfirmasi Logout"),
        content: const Text("Apakah Anda yakin ingin keluar?"),
        actions: [
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text("Logout"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (keluar == true) {
      // Set user null dan refresh state
      widget.appState.value.currentUser = null;
      widget.onAppStateChanged();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            appState: widget.appState,
            products: widget.productManager.productsNotifier.value,
            onAppStateChanged: widget.onAppStateChanged,
            currency: widget.currency,
            productManager: widget.productManager,
          ),
        ),
      );
    }
  }

  void _login() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          appState: widget.appState,
          products: widget.productManager.productsNotifier.value,
          onAppStateChanged: widget.onAppStateChanged,
          currency: widget.currency,
          productManager: widget.productManager,
        ),
      ),
    );
  }

  void _register() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          // FIX: Sekarang RegisterPage menerima appState sesuai perbaikan langkah 3
          appState: widget.appState,
        ),
      ),
    );
  }

  Future<void> _openCart() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CartPage(
          appState: widget.appState,
          onAppStateChanged: widget.onAppStateChanged,
          currency: widget.currency,
        ),
      ),
    );
    // Refresh UI setelah kembali dari keranjang (jika ada item dihapus)
    if (mounted) setState(() {});
  }

  // Fungsi Helper URL Launcher
  void _launchWhatsAppWithMessage(String message) async {
    final Uri url = Uri.parse(
        "https://wa.me/6282341361739?text=${Uri.encodeComponent(message)}");
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Gagal membuka WhatsApp");
      }
    } catch (e) {
      debugPrint("Error membuka WhatsApp: $e");
    }
  }

  void _launchWhatsAppNumber(String number, String message) async {
    final Uri url =
        Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(message)}");
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Gagal membuka WhatsApp");
      }
    } catch (e) {
      debugPrint("Error membuka WhatsApp: $e");
    }
  }

  void _launchInstagram(String username) async {
    final Uri url = Uri.parse("https://instagram.com/$username");
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint("Gagal membuka Instagram");
      }
    } catch (e) {
      debugPrint("Error membuka Instagram: $e");
    }
  }

  // Bottom Sheet Options
  void _showBengkelOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "⚙️ Bengkel Mobile Legend",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blueAccent),
              title: const Text("Ganti Email ML (KHUSUS NO KGM)",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsAppWithMessage(
                    "Saya ingin Ganti Email ML (KHUSUS NO KGM)");
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.redAccent),
              title: const Text("Logout All Device (KONTAK GM)",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsAppWithMessage(
                    "Saya ingin proses Logout All Device (KONTAK GM)");
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  void _showRekberOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "🤝 Rekening Bersama (REKBER)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.greenAccent),
              title: const Text("Admin 1 (LEOZIEN)",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsAppNumber("6282341361739",
                    "Saya butuh Rekening Bersama dengan Admin 1.");
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.greenAccent),
              title: const Text("Admin 2 (LOURIENT)",
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsAppNumber("628819881157",
                    "Saya butuh Rekening Bersama dengan Admin 2.");
              },
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildFooter(Color primaryTextColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      width: double.infinity,
      color: Colors.black.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "LEOZIEN MARKET",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "LEOZIEN MARKET ADALAH TEMPAT JUAL BELI AKUN MLBB AMAN, MURAH dan TERPERCAYA. Proses cepat. Layanan 24 jam.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Peta Situs",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor)),
                  const SizedBox(height: 8),
                  const Text("Beranda",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text("Cek Transaksi",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text("Hubungi Kami",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dukungan",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor)),
                  const SizedBox(height: 8),
                  const Text("Whatsapp",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text("Instagram",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Legalitas",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor)),
                  const SizedBox(height: 8),
                  const Text("Kebijakan Privasi",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const Text("Syarat & Ketentuan",
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Text("Ikuti Kami",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: primaryTextColor)),
          Row(
            children: [
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon:
                      Image.asset('assets/wa.jpeg', width: 28.0, height: 28.0),
                  onPressed: () =>
                      _launchWhatsAppNumber("628819881157", "Halo!"),
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon:
                      Image.asset('assets/ig.jpeg', width: 28.0, height: 28.0),
                  onPressed: () => _launchInstagram("leozienmarket.id"),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              "© 2025 LEOZIEN MARKET. All Rights Reserved.",
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryTextColor = _isDarkMode ? Colors.white : Colors.black;
    final Color iconColor = _isDarkMode ? Colors.white70 : Colors.black87;
    final Color cardColor = _isDarkMode
        ? Colors.white.withOpacity(0.12)
        : Colors.black.withOpacity(0.05);
    final Color searchBarFillColor =
        _isDarkMode ? Colors.grey[800]! : Colors.white;
    final Color searchBarHintColor =
        _isDarkMode ? Colors.white54 : Colors.grey[600]!;
    final Color searchBarBorderColor =
        _isDarkMode ? Colors.white30 : Colors.grey[400]!;

    String today = DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());
    String greetingHour = DateFormat('HH').format(DateTime.now()).toString();
    String welcomeMessage;
    int hour = int.tryParse(greetingHour) ?? 0;

    if (hour >= 5 && hour < 12) {
      welcomeMessage = "Selamat Pagi! ☀️";
    } else if (hour >= 12 && hour < 18) {
      welcomeMessage = "Selamat Siang! 👋";
    } else {
      welcomeMessage = "Selamat Malam! 🌙";
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "𝐋𝐄𝐎𝐙𝐈𝐄𝐍 𝐌𝐀𝐑𝐊𝐄𝐓",
          style: TextStyle(
            color: primaryTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.shopping_cart, color: iconColor),
              onPressed: _openCart),
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode,
                color: iconColor),
            onPressed: _toggleTheme,
          ),
          if (widget.appState.value.isLoggedIn) ...[
            if (widget.appState.value.isAdmin)
              IconButton(
                icon: const Icon(Icons.admin_panel_settings,
                    color: Colors.redAccent),
                tooltip: 'Halaman Admin',
                onPressed: _openAdminPage,
              )
            else
              IconButton(
                icon: Icon(Icons.dashboard, color: iconColor),
                tooltip: 'Dasbor Pengguna',
                onPressed: _openUserDashboard,
              ),
            TextButton(
              onPressed: _logout,
              child: Text(
                'Logout',
                style: TextStyle(color: primaryTextColor),
              ),
            ),
          ] else
            Row(
              children: [
                TextButton(
                  onPressed: _login,
                  child: Text(
                    'Masuk',
                    style: TextStyle(color: primaryTextColor),
                  ),
                ),
                TextButton(
                  onPressed: _register,
                  child: Text(
                    'Daftar',
                    style: TextStyle(
                        color: primaryTextColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contactOpen)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ScaleTransition(
                scale: scaleAnimation,
                child: FloatingActionButton(
                  heroTag: "WA",
                  backgroundColor: Colors.green,
                  onPressed: () => _launchWhatsAppNumber(
                      "6282341361739", "Halo Admin, saya butuh bantuan."),
                  child: const Icon(Icons.phone, size: 26, color: Colors.white),
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: adminOnline ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  adminOnline ? "Online" : "Offline",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                heroTag: "MenuBtn",
                backgroundColor: Colors.blue,
                child: Icon(contactOpen ? Icons.close : Icons.support_agent),
                onPressed: () {
                  setState(() {
                    contactOpen = !contactOpen;
                    contactOpen
                        ? popupController.forward()
                        : popupController.reverse();
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/leozien.jpeg",
                fit: BoxFit.cover, colorBlendMode: BlendMode.darken),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          FadeTransition(
            opacity: fadeAnimation,
            child: ValueListenableBuilder<List<Product>>(
              valueListenable: widget.productManager.productsNotifier,
              builder: (context, products, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(
                      top: kToolbarHeight + 20, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SEARCH & REKBER
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: searchBarBorderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            TextField(
                              style: TextStyle(
                                  color: primaryTextColor, fontSize: 14),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 10.0),
                                filled: true,
                                fillColor: searchBarFillColor,
                                hintText: "Cari Game atau Voucher",
                                hintStyle: TextStyle(
                                    color: searchBarHintColor, fontSize: 14),
                                prefixIcon: Icon(Icons.search,
                                    color: searchBarHintColor, size: 20),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: (v) => setState(() => searchQuery = v),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTextButton('🤝 REKENING BERSAMA',
                                    _showRekberOptions, primaryTextColor),
                                const SizedBox(width: 20),
                                _buildTextButton('⚙️ BENGKEL MLBB',
                                    _showBengkelOptions, primaryTextColor),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // WELCOME
                      Text(welcomeMessage,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text(today,
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 15),

                      // PROMO
                      Text("Hot Promo 🔥",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 8),

                      // --- BAGIAN YANG DIUPDATE (Instagram Feed Style) ---
                      SizedBox(
                        height:
                            280, // 1. Tinggi diperbesar agar jadi Kotak Besar
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: promoImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width:
                                  280, // 2. Lebar disamakan dengan Tinggi (Rasio 1:1)
                              margin: const EdgeInsets.only(
                                  right: 15), // Jarak antar foto
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  // Efek bayangan agar terlihat timbul
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  promoImages[index],
                                  // 3. BoxFit.cover: Gambar akan mengisi penuh kotak secara proporsional (tidak gepeng)
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade800,
                                    child: const Center(
                                      child: Icon(Icons.broken_image,
                                          color: Colors.white54),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      // ----------------------------------------------------
                      const SizedBox(height: 10),
                      Text("Katalog Produk 🎮",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          final p = filteredProducts[index];
                          final liked =
                              widget.appState.value.wishlist.contains(p.id);

                          return GestureDetector(
                            onTap: () {
                              // TAMPILKAN DETAIL DIALOG
                              showDialog(
                                context: context,
                                builder: (_) => DetailDialog(
                                  product: p,
                                  appState: widget.appState,
                                  onAppStateChanged: widget.onAppStateChanged,
                                  currency: widget.currency,
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                                color: cardColor,
                              ),
                              child: Column(
                                children: [
                                  Expanded(
                                      child: ClipRRect(
                                          borderRadius:
                                              const BorderRadius.vertical(
                                                  top: Radius.circular(12)),
                                          child: Image.asset(p.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Container(
                                                      color: Colors.grey,
                                                      child: const Center(
                                                          child: Icon(
                                                              Icons.error)))))),
                                  Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: primaryTextColor)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                widget.currency.format(p.price),
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.greenAccent)),
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  liked
                                                      ? widget.appState.value
                                                          .wishlist
                                                          .remove(p.id)
                                                      : widget.appState.value
                                                          .wishlist
                                                          .add(p.id);
                                                  widget.onAppStateChanged();
                                                });
                                              },
                                              child: Icon(
                                                  liked
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  size: 18,
                                                  color: liked
                                                      ? Colors.red
                                                      : primaryTextColor),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 30),

                      // FOOTER BANNER
                      Text("Pesan Sekarang!",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/panorama.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.blueGrey,
                              child: const Center(
                                child: Text("Panorama Image",
                                    style: TextStyle(color: Colors.white70)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      _buildFooter(primaryTextColor, iconColor),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed, Color color) {
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
