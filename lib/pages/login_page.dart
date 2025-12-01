// pages/login_page.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:penjualan_mobile_legend/models/user.dart';

// ✅ IMPORT BARU: Import UserManager dan User model
import '../pages/user_manager.dart' hide User;
import '../models/app_state.dart';

// Pastikan jalur impor ini benar
import '../models/product.dart';
import '../pages/home_page.dart';
import '../pages/register_page.dart';
import '../data/dummy_products.dart';

class LoginPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final List<Product> products;
  final VoidCallback onAppStateChanged;
  final NumberFormat currency;
  final ProductManager productManager;

  const LoginPage({
    super.key,
    required this.appState,
    required this.products,
    required this.onAppStateChanged,
    required this.currency,
    required this.productManager,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutExpo,
    ));
    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // ✅ FUNGSI LOGIN DIPERBARUI (Menjadi async)
  void _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final enteredEmail = _email.text;
    final enteredPassword = _password.text;

    // 1. Panggil UserManager untuk memverifikasi kredensial
    User? loggedInUser = (await UserManager()
        .authenticate(enteredEmail, enteredPassword)) as User?;

    if (loggedInUser != null) {
      // Login Berhasil

      // 2. Perbarui AppState dengan data pengguna yang berhasil login
      widget.appState.value.currentUser = loggedInUser as User?;
      widget.onAppStateChanged();

      // 3. Tentukan rute navigasi berdasarkan role
      String route;
      String role = loggedInUser.role;

      if (role == 'admin') {
        route = '/admin';
      } else {
        route = '/home';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login ${role.toUpperCase()} Berhasil!"),
          backgroundColor: Colors.green,
        ),
      );

      // 4. Navigasi ke rute yang sesuai
      if (route == '/home') {
        _openHomePageAsUser();
      } else {
        Navigator.of(context).pushReplacementNamed(route);
      }
    } else {
      // Login Gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Login gagal! Email atau Password salah. Silakan coba lagi atau Daftar."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk Tamu: Langsung ke HomePage
  void _openHomePageAsUser() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomePage(
          appState: widget.appState,
          products: widget.productManager.productsNotifier.value,
          productManager: widget.productManager,
          onAppStateChanged: widget.onAppStateChanged,
          currency: widget.currency,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/leozien.jpeg", fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
            return Container(color: Colors.grey[900]);
          }),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.75),
                  Colors.black.withOpacity(0.35),
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(horizontal: 28),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "MASUK KE AKUN",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _email,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputTheme("Username", Icons.person),
                              validator: (value) =>
                                  value!.isEmpty ? 'Tidak boleh kosong' : null,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _password,
                              obscureText: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: inputTheme("Password", Icons.lock),
                              validator: (value) =>
                                  value!.isEmpty ? 'Tidak boleh kosong' : null,
                            ),
                            const SizedBox(height: 26),
                            // Tombol Login
                            ElevatedButton(
                              style: elevatedStyle(),
                              onPressed: _login,
                              child: const Text(
                                "Masuk",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Tombol Opsi Registrasi - DIPERBAIKI DISINI
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    // ⚠️ PERBAIKAN: Menghapus 'const' dan menambahkan parameter
                                    // yang dibutuhkan oleh RegisterPage.
                                    // Jika RegisterPage Anda butuh parameter lain, tambahkan di sini.
                                    builder: (context) => RegisterPage(
                                      appState: widget.appState,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Belum punya akun? Daftar Sekarang",
                                style: TextStyle(
                                    color: Colors.yellowAccent,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(height: 26),

                            // Tombol Lanjutkan sebagai Tamu
                            ElevatedButton(
                              style: elevatedStyle().copyWith(
                                backgroundColor: MaterialStateProperty.all(
                                    Colors.white.withOpacity(0.15)),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.white),
                              ),
                              onPressed: _openHomePageAsUser,
                              child: const Text(
                                "Lanjutkan sebagai Tamu",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  InputDecoration inputTheme(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white),
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  ButtonStyle elevatedStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
