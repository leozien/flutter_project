import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'user_manager.dart';

class ChangePasswordPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;

  const ChangePasswordPage({super.key, required this.appState});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldPassController = TextEditingController(); // Tetap ada untuk UI
  final _newPassController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  void _handleChangePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // FIX: Cukup kirim password baru saja sesuai UserManager Firebase
      final success = await UserManager().changePassword(
        _newPassController.text,
      );

      setState(() => _isLoading = false);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Kata sandi berhasil diubah!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text("Gagal mengubah sandi. Pastikan Anda baru saja login."),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.appState.value.isDarkMode;
    final bgColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Ganti Kata Sandi"),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Amankan akun Anda dengan kata sandi yang kuat.",
                style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(height: 24),

              // Password lama tetap diminta di UI sebagai formalitas/validasi visual
              _buildPasswordField(
                  "Kata Sandi Lama", _oldPassController, isDarkMode),
              const SizedBox(height: 16),
              _buildPasswordField(
                  "Kata Sandi Baru", _newPassController, isDarkMode),
              const SizedBox(height: 16),
              _buildPasswordField(
                  "Konfirmasi Sandi Baru", _confirmPassController, isDarkMode,
                  isConfirm: true),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text("Simpan Perubahan",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      String label, TextEditingController controller, bool isDarkMode,
      {bool isConfirm = false}) {
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white24 : Colors.black12;

    return TextFormField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: isDarkMode ? Colors.white60 : Colors.black54),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textColor),
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: isDarkMode
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey.shade100,
      ),
      validator: (val) {
        if (val == null || val.isEmpty) {
          return "Wajib diisi";
        }
        if (isConfirm && val != _newPassController.text) {
          return "Kata sandi tidak cocok";
        }
        return null;
      },
    );
  }
}
