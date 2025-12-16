import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'user_manager.dart';

class ForgotPasswordPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;

  const ForgotPasswordPage({super.key, required this.appState});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  // Note: We don't need _newPassController for Firebase reset password flow

  bool _isLoading = false;

  void _handleReset() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // FIX: Only send email to resetPassword
      // Firebase will send a link to this email for the user to reset their password externally
      bool success = await UserManager().resetPassword(
        _emailController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Email Terkirim"),
            content: const Text(
                "Silakan cek inbox email Anda (termasuk folder spam) dan klik link untuk mereset kata sandi."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx); // Close Dialog
                  Navigator.pop(context); // Back to Login
                },
                child: const Text("Kembali ke Login"),
              )
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                "Gagal mengirim email reset. Pastikan email benar/terdaftar."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.appState.value.isDarkMode;
    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final inputFill = isDarkMode
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade100;
    final borderColor = isDarkMode ? Colors.white24 : Colors.black12;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Lupa Kata Sandi"),
        backgroundColor: bgColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Atur Ulang Kata Sandi",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Masukkan email akun Anda. Kami akan mengirimkan link untuk mereset kata sandi.",
                style: TextStyle(
                    color: isDarkMode ? Colors.white60 : Colors.black54),
              ),
              const SizedBox(height: 30),

              // Input Email
              TextFormField(
                controller: _emailController,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  labelText: "Email Terdaftar",
                  labelStyle: TextStyle(
                      color: isDarkMode ? Colors.white60 : Colors.black54),
                  prefixIcon: Icon(Icons.email, color: textColor),
                  filled: true,
                  fillColor: inputFill,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: textColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (v) => v!.isEmpty ? "Email wajib diisi" : null,
              ),

              const SizedBox(height: 30),

              // Tombol Reset
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleReset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Kirim Link Reset",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
