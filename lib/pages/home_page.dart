import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_state.dart';
import '../models/product.dart';
import '../pages/detail_dialog.dart';
import '../pages/cart_page.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../data/dummy_products.dart';
import '../services/firestore_service.dart';

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
  final FirestoreService _firestoreService = FirestoreService();

  String searchQuery = '';
  bool _isDarkMode = true;
  String _sortOrder = 'none';
  bool _onlyAvailable = false; // 🔥 Variabel Filter Akun Tersedia

  late AnimationController _controller;
  late Animation<double> fadeAnimation;

  late AnimationController popupController;
  late Animation<double> scaleAnimation;

  final ScrollController _scrollController = ScrollController();

  bool contactOpen = false;
  bool adminOnline = true;

  final List<String> promoImages = [
    "assets/pro1.jpeg",
    "assets/pro2.jpeg",
    "assets/promo5.jpeg",
    "assets/pro4.jpeg",
    "assets/promo6.jpeg",
  ];

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.appState.value.isDarkMode;

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
    _controller.dispose();
    popupController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      widget.appState.value.isDarkMode = _isDarkMode;
      widget.onAppStateChanged();
    });
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

  void _launchWhatsAppWithMessage(String message) async {
    _launchWhatsAppNumber("6282341361739", message);
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Urutkan Harga",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Paling Sesuai (Default)', 'none'),
              _buildSortOption('Harga Termurah ⬇️', 'lowest'),
              _buildSortOption('Harga Termahal ⬆️', 'highest'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, String value) {
    final isSelected = _sortOrder == value;
    final textColor = _isDarkMode ? Colors.white : Colors.black;

    return ListTile(
      title: Text(title,
          style: TextStyle(
            color: isSelected ? Colors.blueAccent : textColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          )),
      trailing:
          isSelected ? const Icon(Icons.check, color: Colors.blueAccent) : null,
      onTap: () {
        setState(() {
          _sortOrder = value;
        });
        Navigator.pop(context);
      },
    );
  }

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
      widget.appState.value.currentUser = null;
      widget.onAppStateChanged();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            appState: widget.appState,
            products: [],
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
          products: [],
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
        builder: (context) => RegisterPage(appState: widget.appState),
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
    if (mounted) setState(() {});
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kebijakan Privasi"),
        content: const SingleChildScrollView(
          child: Text(
              "Data Anda aman bersama kami. Kami tidak membagikan data ke pihak ketiga."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          )
        ],
      ),
    );
  }

  void _showRedeemDialog() {
    final TextEditingController codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text("Tukar Voucher",
            style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Masukkan kode unik untuk mendapatkan promo spesial.",
              style: TextStyle(
                  color: _isDarkMode ? Colors.white70 : Colors.black54,
                  fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              style:
                  TextStyle(color: _isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Contoh: LEOZIEN",
                hintStyle: TextStyle(
                    color: _isDarkMode ? Colors.white30 : Colors.black38),
                filled: true,
                fillColor: _isDarkMode ? Colors.white10 : Colors.grey.shade200,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("Batal",
                style: TextStyle(
                    color: _isDarkMode ? Colors.white54 : Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () {
              Navigator.pop(ctx);
              const List<String> validCodes = [
                "LEOZIEN8080",
                "LUNCTORIUM0808",
                "LUNCLEOZIEN8080"
              ];
              String inputCode = codeController.text.trim().toUpperCase();

              if (validCodes.contains(inputCode)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text("🎉 Kode '$inputCode' Berhasil! Potongan aktif."),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("❌ Kode tidak valid atau sudah kadaluarsa."),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child:
                const Text("Tukar Kode", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final bool isLoggedIn = widget.appState.value.isLoggedIn;
    final bool dark = _isDarkMode;

    return Drawer(
      backgroundColor: dark ? const Color(0xFF121212) : Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: dark
                      ? [Colors.black, const Color(0xFF1E1E1E)]
                      : [Colors.white, Colors.grey.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: isLoggedIn
                  ? _buildLoggedInDrawerContent()
                  : _buildGuestDrawerContent(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF0D0D0D) : Colors.grey.shade50,
              border: Border(
                  top: BorderSide(
                      color: dark ? Colors.white10 : Colors.black12)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Punya kode unik?",
                  style: TextStyle(
                      color: dark ? Colors.white54 : Colors.black54,
                      fontSize: 12),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showRedeemDialog,
                    icon: const Icon(Icons.card_giftcard,
                        color: Colors.blueAccent),
                    label: const Text("Tukar Kode Voucher"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blueAccent,
                      side: const BorderSide(color: Colors.blueAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, Color textColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Text("Ikuti Kami:",
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(width: 10),
          InkWell(
            onTap: () => _launchWhatsAppNumber("6282341361739", "Halo Admin"),
            child: Image.asset('assets/whatsap.png', width: 28, height: 28),
          ),
          const SizedBox(width: 15),
          InkWell(
            onTap: () => _launchInstagram("leozienmarket.id"),
            child: Image.asset('assets/instagram.png', width: 28, height: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestDrawerContent() {
    final dark = _isDarkMode;
    final textColor = dark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(Icons.stars, color: Colors.orangeAccent, size: 32),
            IconButton(
              icon: Icon(Icons.close, color: textColor),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        const SizedBox(height: 20),
        Text(
          "Gabung Leozien\nMarket Sekarang!",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textColor,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 30),
        _buildBenefitItem(
            Icons.flash_on,
            "Jadilah Sultan pertama yang mendapatkan promo menarik!",
            textColor),
        const SizedBox(height: 16),
        _buildBenefitItem(
            Icons.history, "Pantau histori pembelian tanpa ribet.", textColor),
        const SizedBox(height: 16),
        _buildBenefitItem(
            Icons.security, "Transaksi secepat kilat & 100% Aman.", textColor),
        const Spacer(),
        _buildSocialIcons(),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _register();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Daftar sekarang, gratis",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _login();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? Colors.white10 : Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("Masuk",
                style:
                    TextStyle(color: textColor, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildLoggedInDrawerContent() {
    final user = widget.appState.value.currentUser;
    final dark = _isDarkMode;
    final textColor = dark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: dark ? Colors.white10 : Colors.grey.shade300,
          child: Icon(Icons.person, size: 40, color: textColor),
        ),
        const SizedBox(height: 16),
        Text(
          "Halo, ${user?.email ?? 'Member'}",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 4),
        Text("Member Setia Leozien",
            style: TextStyle(color: textColor.withValues(alpha: 0.7))),
        const SizedBox(height: 30),
        const Divider(),
        ListTile(
          leading: Icon(Icons.dashboard, color: textColor),
          title: Text("Dasbor Saya", style: TextStyle(color: textColor)),
          onTap: () {
            Navigator.pop(context);
            if (widget.appState.value.isAdmin) {
              _openAdminPage();
            } else {
              _openUserDashboard();
            }
          },
        ),
        ListTile(
          leading: Icon(Icons.shopping_cart, color: textColor),
          title: Text("Keranjang", style: TextStyle(color: textColor)),
          onTap: () {
            Navigator.pop(context);
            _openCart();
          },
        ),
        _buildSocialIcons(),
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.redAccent),
          title:
              const Text("Keluar", style: TextStyle(color: Colors.redAccent)),
          onTap: () {
            Navigator.pop(context);
            _logout();
          },
        ),
      ],
    );
  }

  void _showBengkelOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _isDarkMode ? Colors.black87 : Colors.white,
      builder: (context) {
        final textColor = _isDarkMode ? Colors.white : Colors.black;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "⚙️ Bengkel Mobile Legend",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blueAccent),
              title: Text("Ganti Email ML (KHUSUS NO KGM)",
                  style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsAppWithMessage(
                    "Saya ingin Ganti Email ML (KHUSUS NO KGM)");
              },
            ),
            ListTile(
              leading: const Icon(Icons.security, color: Colors.redAccent),
              title: Text("Logout All Device (KONTAK GM)",
                  style: TextStyle(color: textColor)),
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
      backgroundColor: _isDarkMode ? Colors.black87 : Colors.white,
      builder: (context) {
        final textColor = _isDarkMode ? Colors.white : Colors.black;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "🤝 Rekening Bersama (REKBER)",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.greenAccent),
              title:
                  Text("Admin 1 (LEOZIEN)", style: TextStyle(color: textColor)),
              onTap: () {
                Navigator.pop(context);
                _launchWhatsAppNumber("6282341361739",
                    "Saya butuh Rekening Bersama dengan Admin 1.");
              },
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.greenAccent),
              title: Text("Admin 2 (LOURIENT)",
                  style: TextStyle(color: textColor)),
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

  Widget _buildFooterLink(String text, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          text,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(Color primaryTextColor, Color secondaryTextColor) {
    final footerBg = _isDarkMode ? Colors.black : const Color(0xFFF5F5F5);
    final footerText = _isDarkMode ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
      width: double.infinity,
      color: footerBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "LEOZIEN MARKET",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: footerText),
          ),
          const SizedBox(height: 10),
          Text(
            "TEMPAT JUAL BELI AKUN MLBB AMAN & TERPERCAYA. LAYANAN 24 JAM.",
            style: TextStyle(color: footerText.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Menu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: footerText)),
                  const SizedBox(height: 8),
                  _buildFooterLink("Beranda", () {
                    _scrollController.animateTo(0,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  }, footerText),
                  _buildFooterLink("Keranjang", _openCart, footerText),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bantuan",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: footerText)),
                  const SizedBox(height: 8),
                  _buildFooterLink("Hubungi Admin", () {
                    _launchWhatsAppNumber(
                        "6282341361739", "Halo Admin, saya butuh bantuan");
                  }, footerText),
                  _buildFooterLink("Instagram", () {
                    _launchInstagram("leozienmarket.id");
                  }, footerText),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Info",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: footerText)),
                  const SizedBox(height: 8),
                  _buildFooterLink("Privasi", _showPrivacyPolicy, footerText),
                ],
              ),
            ],
          ),
          const SizedBox(height: 30),
          Center(
            child: Text(
              "© 2025 LEOZIEN MARKET. All Rights Reserved.",
              style: TextStyle(
                  color: footerText.withValues(alpha: 0.5), fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, VoidCallback onTap, Color bgColor, Color textColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1),
            )
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool darkMode = _isDarkMode;
    final Color backgroundColor = darkMode ? Colors.black : Colors.white;
    final Color primaryTextColor = darkMode ? Colors.white : Colors.black87;
    final Color secondaryTextColor = darkMode ? Colors.white70 : Colors.black54;
    final Color cardColor = darkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color appBarColor = darkMode ? Colors.black : Colors.white;
    final Color searchBarFill =
        darkMode ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade100;
    final Color iconColor = darkMode ? Colors.white : Colors.black;
    final Color actionBtnColor = darkMode ? Colors.white : Colors.black;
    final Color actionBtnTextColor = darkMode ? Colors.black : Colors.white;

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
      extendBodyBehindAppBar: false,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        titleSpacing: 0,
        iconTheme: IconThemeData(color: iconColor),
        title: Row(
          children: [
            Text(
              "LEOZIEN",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: searchBarFill,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  cursorColor: primaryTextColor,
                  style: TextStyle(color: primaryTextColor, fontSize: 14),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "Cari...",
                    hintStyle: TextStyle(
                        color: darkMode ? Colors.white54 : Colors.black38),
                    prefixIcon: Icon(Icons.search,
                        color: darkMode ? Colors.white54 : Colors.black38,
                        size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onChanged: (v) => setState(() => searchQuery = v),
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart, color: iconColor),
            onPressed: _openCart,
            tooltip: 'Keranjang',
          ),
          IconButton(
            icon: Icon(
              darkMode ? Icons.light_mode : Icons.dark_mode,
              color: iconColor,
            ),
            onPressed: _toggleTheme,
            tooltip: 'Ganti Tema',
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
          FloatingActionButton(
            heroTag: "MenuBtn",
            backgroundColor: Colors.blueAccent,
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
      body: Stack(
        children: [
          Container(color: backgroundColor),
          FadeTransition(
            opacity: fadeAnimation,
            child: StreamBuilder<List<Product>>(
              stream: _firestoreService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Terjadi Kesalahan: ${snapshot.error}",
                          style: TextStyle(color: secondaryTextColor)));
                }

                final allProducts = snapshot.data ?? [];

                // 🔥 LOGIKA FILTER & PENCARIAN (LOKAL) TERMASUK FILTER TERSEDIA
                List<Product> displayProducts = allProducts.where((p) {
                  bool matchSearch = p.name
                      .toLowerCase()
                      .contains(searchQuery.trim().toLowerCase());
                  bool matchAvailable = _onlyAvailable ? !p.isSold : true;
                  return matchSearch && matchAvailable;
                }).toList();

                if (_sortOrder == 'lowest') {
                  displayProducts.sort((a, b) => a.price.compareTo(b.price));
                } else if (_sortOrder == 'highest') {
                  displayProducts.sort((a, b) => b.price.compareTo(a.price));
                }

                return SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 20, left: 16, right: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              _buildActionButton(
                                  '🤝 REKBER',
                                  _showRekberOptions,
                                  actionBtnColor,
                                  actionBtnTextColor),
                              const SizedBox(width: 8),
                              _buildActionButton(
                                  '⚙️ BENGKEL',
                                  _showBengkelOptions,
                                  actionBtnColor,
                                  actionBtnTextColor),
                            ],
                          ),
                          Row(
                            children: [
                              // 🔥 TOMBOL FILTER TERSEDIA
                              FilterChip(
                                label: const Text("Tersedia",
                                    style: TextStyle(fontSize: 11)),
                                selected: _onlyAvailable,
                                onSelected: (val) =>
                                    setState(() => _onlyAvailable = val),
                                selectedColor: Colors.green.withOpacity(0.2),
                                checkmarkColor: Colors.green,
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              const SizedBox(width: 8),
                              // TOMBOL FILTER HARGA
                              InkWell(
                                onTap: _showSortDialog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.filter_list,
                                          color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text("Harga",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(welcomeMessage,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor)),
                      Text(today, style: TextStyle(color: secondaryTextColor)),
                      const SizedBox(height: 15),
                      Text("Hot Promo 🔥",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: promoImages.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 280,
                              margin: const EdgeInsets.only(right: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  promoImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: darkMode
                                        ? Colors.white12
                                        : Colors.grey.shade300,
                                    child: Center(
                                      child: Icon(Icons.broken_image,
                                          color: secondaryTextColor),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Katalog Produk 🎮",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryTextColor)),
                          Text("${displayProducts.length} Produk",
                              style: TextStyle(
                                  color: secondaryTextColor, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      displayProducts.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(40),
                              child: Center(
                                  child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 50, color: secondaryTextColor),
                                  const SizedBox(height: 10),
                                  Text(
                                      allProducts.isEmpty
                                          ? "Belum ada produk dari server.\nLogin Admin untuk menambah."
                                          : "Produk tidak ditemukan.",
                                      textAlign: TextAlign.center,
                                      style:
                                          TextStyle(color: secondaryTextColor)),
                                ],
                              )))
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: displayProducts.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, index) {
                                final p = displayProducts[index];
                                final liked = widget.appState.value.wishlist
                                    .contains(p.id);

                                return GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => DetailDialog(
                                        product: p,
                                        appState: widget.appState,
                                        onAppStateChanged:
                                            widget.onAppStateChanged,
                                        currency: widget.currency,
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: darkMode
                                              ? Colors.white12
                                              : Colors.grey.shade300),
                                      color: cardColor,
                                      boxShadow: [
                                        if (!darkMode)
                                          BoxShadow(
                                              color: Colors.grey.shade200,
                                              blurRadius: 5)
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius
                                                          .vertical(
                                                          top: Radius.circular(
                                                              12)),
                                                  child: Image.asset(p.image,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context,
                                                              error,
                                                              stackTrace) =>
                                                          Container(
                                                            color: Colors.grey,
                                                            child: const Center(
                                                              child: Icon(Icons
                                                                  .broken_image),
                                                            ),
                                                          )),
                                                ),
                                              ),
                                              if (p.isSold)
                                                Positioned.fill(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withValues(
                                                              alpha: 0.7),
                                                      borderRadius:
                                                          const BorderRadius
                                                              .vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      12)),
                                                    ),
                                                    child: Center(
                                                      child: Transform.rotate(
                                                        angle: -0.2,
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    Colors.red,
                                                                width: 2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        4),
                                                          ),
                                                          child: const Text(
                                                            "SOLD OUT",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(p.name,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: primaryTextColor,
                                                      decoration: p.isSold
                                                          ? TextDecoration
                                                              .lineThrough
                                                          : null)),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      widget.currency
                                                          .format(p.price),
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: p.isSold
                                                              ? Colors.grey
                                                              : Colors.green)),
                                                  if (!p.isSold)
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          liked
                                                              ? widget
                                                                  .appState
                                                                  .value
                                                                  .wishlist
                                                                  .remove(p.id)
                                                              : widget
                                                                  .appState
                                                                  .value
                                                                  .wishlist
                                                                  .add(p.id);
                                                          widget
                                                              .onAppStateChanged();
                                                        });
                                                      },
                                                      child: Icon(
                                                          liked
                                                              ? Icons.favorite
                                                              : Icons
                                                                  .favorite_border,
                                                          size: 14,
                                                          color: liked
                                                              ? Colors.red
                                                              : primaryTextColor),
                                                    )
                                                ],
                                              ),
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
                      Text("Pesan Sekarang!",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryTextColor)),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
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
                              color: darkMode
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade300,
                              child: Center(
                                child: Text("Panorama Image",
                                    style:
                                        TextStyle(color: secondaryTextColor)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      _buildFooter(primaryTextColor, secondaryTextColor),
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
}