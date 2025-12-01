import 'dart:ui';
import 'package:flutter/material.dart';
import 'profile_page.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback? onSaved;
  const EditProfilePage({super.key, this.onSaved});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nama;
  late TextEditingController _email;
  late TextEditingController _hp;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: globalName);
    _email = TextEditingController(text: globalEmail);
    _hp = TextEditingController(text: globalHP);
  }

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _hp.dispose();
    super.dispose();
  }

  ButtonStyle buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.white.withOpacity(0.85),
      foregroundColor: Colors.black87,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  InputDecoration inputTheme(String label, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.18),
      prefixIcon: Icon(icon, color: Colors.white),
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(.30)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: Colors.black.withOpacity(.25),
        elevation: 0,
      ),
      body: Stack(
        children: [
          // background image
          Positioned.fill(
            child: Image.asset("assets/leozien.jpeg", fit: BoxFit.cover),
          ),

          Container(color: Colors.black.withOpacity(0.45)),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(.3)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 45,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person,
                                color: Colors.black, size: 55),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nama,
                            style: const TextStyle(color: Colors.white),
                            decoration: inputTheme("Nama", Icons.person),
                            validator: (v) =>
                                v!.isEmpty ? "Nama wajib diisi" : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _email,
                            style: const TextStyle(color: Colors.white),
                            decoration: inputTheme("Email", Icons.email),
                            validator: (v) =>
                                v!.isEmpty ? "Email wajib diisi" : null,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _hp,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.phone,
                            decoration: inputTheme("Nomor HP", Icons.phone),
                            validator: (v) =>
                                v!.isEmpty ? "Nomor HP wajib diisi" : null,
                          ),
                          const SizedBox(height: 25),
                          ElevatedButton(
                            style: buttonStyle(),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                globalName = _nama.text;
                                globalEmail = _email.text;
                                globalHP = _hp.text;
                                widget.onSaved?.call();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text("Profil berhasil diperbarui!")),
                                );

                                Navigator.pop(context);
                              }
                            },
                            child: const Text("Simpan",
                                style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Batal",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          )
                        ],
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
}
