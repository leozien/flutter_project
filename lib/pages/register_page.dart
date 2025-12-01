// lib/pages/register_page.dart
import 'package:flutter/material.dart';
import '../models/app_state.dart';
import 'user_manager.dart';

class RegisterPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;

  const RegisterPage({
    super.key,
    required this.appState,
  });

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final UserManager _userManager = UserManager();

  // 1. Controller untuk field yang sudah ada
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 2. Controller & Variabel baru
  final _usernameController = TextEditingController(); // Untuk Username
  final _dobController = TextEditingController(); // Untuk Tanggal Lahir (Teks)
  String? _selectedGender; // Untuk Gender (Pilihan)

  // List pilihan Gender
  final List<String> _genderOptions = ['Laki-laki', 'Perempuan'];

  // Fungsi untuk menampilkan Kalender (Date Picker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        // Format tanggal sederhana: DD/MM/YYYY
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text;
      final password = _passwordController.text;

      // Ambil data baru
      final username = _usernameController.text;
      final dob = _dobController.text;
      final gender = _selectedGender;

      // PENTING: Anda harus mengupdate fungsi 'registerUser' di file 'user_manager.dart'
      // agar bisa menerima username, dob, dan gender.
      // Contoh: await _userManager.registerUser(email, password, username, dob, gender);

      // Saat ini saya panggil seperti kode lama agar tidak error di sini,
      // tapi data barunya sudah siap di variabel di atas.
      bool success = await _userManager.registerUser(email, password);

      if (!mounted) return;

      if (success) {
        // Tampilkan info lengkap di console (untuk debugging)
        print("Register Data: $username, $email, $dob, $gender");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email sudah terdaftar.')),
        );
      }
    }
  }

  @override
  void dispose() {
    // Bersihkan controller saat halaman ditutup
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Akun Baru")),
      body: SingleChildScrollView(
        // Tambahkan Scroll agar tidak overflow saat keyboard muncul
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // --- 1. Field Username ---
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Isi username' : null,
                ),
                const SizedBox(height: 16),

                // --- 2. Field Email ---
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v!.isEmpty ? 'Isi email' : null,
                ),
                const SizedBox(height: 16),

                // --- 3. Field Password ---
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Isi password' : null,
                ),
                const SizedBox(height: 16),

                // --- 4. Field Tanggal Lahir (Read Only + DatePicker) ---
                TextFormField(
                  controller: _dobController,
                  readOnly: true, // Tidak bisa diketik manual
                  decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                      hintText: 'DD/MM/YYYY'),
                  onTap: () =>
                      _selectDate(context), // Buka kalender saat diklik
                  validator: (v) => v!.isEmpty ? 'Pilih tanggal lahir' : null,
                ),
                const SizedBox(height: 16),

                // --- 5. Field Gender (Dropdown) ---
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: _genderOptions.map((String gender) {
                    return DropdownMenuItem<String>(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                  validator: (v) => v == null ? 'Pilih gender' : null,
                ),
                const SizedBox(height: 24),

                // --- Tombol Daftar ---
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleRegister,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Daftar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
