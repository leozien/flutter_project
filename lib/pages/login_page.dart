import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user.dart';
import '../pages/user_manager.dart';
import '../models/app_state.dart';
import '../models/product.dart';
// import '../pages/home_page.dart'; // ❌ SUDAH DIHAPUS KARENA TIDAK DIPAKAI
import '../pages/register_page.dart';
import '../pages/forgot_password_page.dart';
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

  bool _isPasswordVisible = false;
  bool _rememberMe = false;

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
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo));
    Future.delayed(
        const Duration(milliseconds: 200), () => _controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      widget.appState.value.isDarkMode = !widget.appState.value.isDarkMode;
      widget.onAppStateChanged();
    });
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    final enteredEmail = _email.text.trim(); // Trim spasi agar aman
    final enteredPassword = _password.text;

    // Login ke Firebase
    User? loggedInUser =
        await UserManager().authenticate(enteredEmail, enteredPassword);

    if (!mounted) return;

    if (loggedInUser != null) {
      widget.appState.value.currentUser = loggedInUser;
      widget.onAppStateChanged();

      // 🔥 LOGIKA PEMISAHAN AKUN 🔥
      String role = loggedInUser.role;

      if (role == 'admin') {
        // KASUS 1: ADMIN
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Masuk ke Dashboard Admin..."),
              backgroundColor: Colors.blue),
        );
        // Hapus semua riwayat halaman sebelumnya, kunci Admin di Dashboard
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/admin', (route) => false);
      } else {
        // KASUS 2: USER BIASA
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login Berhasil!"), backgroundColor: Colors.green),
        );
        // Hapus riwayat login, masuk ke Home Page User
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Login gagal! Cek email & password."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openHomePageAsUser() {
    // Tamu dianggap User Biasa -> Masuk Home Page via Route
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = widget.appState.value.isDarkMode;
    final Color bgColorStart = isDarkMode ? Colors.black : Colors.white;
    final Color bgColorEnd =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final Color textColor = isDarkMode ? Colors.white : Colors.black;
    final Color hintColor = isDarkMode ? Colors.white54 : Colors.black54;
    final Color cardColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);
    final Color borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);
    final Color btnBgColor = isDarkMode ? Colors.white : Colors.black;
    final Color btnTextColor = isDarkMode ? Colors.black : Colors.white;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [bgColorStart, bgColorEnd],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: IconButton(
                  icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: textColor),
                  onPressed: _toggleTheme,
                  tooltip: "Ganti Tema",
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  child: Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: borderColor),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("MASUK KE AKUN",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          letterSpacing: 1.5)),
                                  const SizedBox(height: 30),
                                  TextFormField(
                                    controller: _email,
                                    style: TextStyle(color: textColor),
                                    decoration: inputTheme(
                                        "Username / Email",
                                        Icons.person,
                                        textColor,
                                        hintColor,
                                        borderColor),
                                    validator: (value) => value!.isEmpty
                                        ? 'Tidak boleh kosong'
                                        : null,
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: !_isPasswordVisible,
                                    style: TextStyle(color: textColor),
                                    decoration: inputTheme(
                                            "Password",
                                            Icons.lock,
                                            textColor,
                                            hintColor,
                                            borderColor)
                                        .copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: textColor.withValues(
                                                alpha: 0.6)),
                                        onPressed: () => setState(() =>
                                            _isPasswordVisible =
                                                !_isPasswordVisible),
                                      ),
                                    ),
                                    validator: (value) => value!.isEmpty
                                        ? 'Tidak boleh kosong'
                                        : null,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _rememberMe,
                                            activeColor: btnBgColor,
                                            checkColor: btnTextColor,
                                            side: BorderSide(
                                                color: textColor.withValues(
                                                    alpha: 0.5)),
                                            onChanged: (val) => setState(() =>
                                                _rememberMe = val ?? false),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text("Ingat Saya",
                                            style: TextStyle(
                                                color: textColor.withValues(
                                                    alpha: 0.8),
                                                fontSize: 13))
                                      ]),
                                      TextButton(
                                        onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    ForgotPasswordPage(
                                                        appState:
                                                            widget.appState))),
                                        child: Text("Lupa Kata Sandi?",
                                            style: TextStyle(
                                                color: textColor.withValues(
                                                    alpha: 0.8),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600)),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: btnBgColor,
                                      foregroundColor: btnTextColor,
                                      minimumSize:
                                          const Size(double.infinity, 54),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                      elevation: 0,
                                    ),
                                    onPressed: _login,
                                    child: const Text("Masuk",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) => RegisterPage(
                                                appState: widget.appState))),
                                    child: RichText(
                                        text: TextSpan(
                                            text: "Belum punya akun? ",
                                            style: TextStyle(
                                                color: textColor.withValues(
                                                    alpha: 0.7)),
                                            children: [
                                          TextSpan(
                                              text: "Daftar",
                                              style: TextStyle(
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold,
                                                  decoration:
                                                      TextDecoration.underline))
                                        ])),
                                  ),
                                  const SizedBox(height: 10),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: textColor,
                                      minimumSize:
                                          const Size(double.infinity, 54),
                                      side: BorderSide(
                                          color:
                                              textColor.withValues(alpha: 0.3)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14)),
                                    ),
                                    onPressed: _openHomePageAsUser,
                                    child: const Text("Cek Katalog",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  InputDecoration inputTheme(String label, IconData icon, Color textColor,
      Color hintColor, Color borderColor) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: textColor.withValues(alpha: 0.7)),
      labelStyle: TextStyle(color: hintColor),
      filled: true,
      fillColor: textColor.withValues(alpha: 0.03),
      enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(14)),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor, width: 1.5),
          borderRadius: BorderRadius.circular(14)),
      errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(14)),
      focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          borderRadius: BorderRadius.circular(14)),
    );
  }
}
