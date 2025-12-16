import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk ambil User ID
import 'package:cloud_firestore/cloud_firestore.dart'; // Untuk Data
import '../services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  final VoidCallback? onSaved;
  const EditProfilePage({super.key, this.onSaved});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  String _selectedAvatarUrl =
      "https://api.dicebear.com/7.x/avataaars/png?seed=Felix"; // Default
  bool _isLoading = false;

  // Daftar Pilihan Avatar Keren (DiceBear API)
  final List<String> _avatarOptions = [
    "https://api.dicebear.com/7.x/avataaars/png?seed=Felix",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Aneka",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Zoe",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Jack",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Bella",
    "https://api.dicebear.com/7.x/avataaars/png?seed=Coco",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Gizmo",
    "https://api.dicebear.com/7.x/adventurer/png?seed=Nala",
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _loadUserData();
  }

  void _loadUserData() async {
    if (currentUser == null) return;

    // Ambil data dari Firestore
    var doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (doc.exists && mounted) {
      var data = doc.data() as Map<String, dynamic>;
      setState(() {
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _selectedAvatarUrl = data['photoUrl'] ?? _selectedAvatarUrl;
      });
    } else {
      // Jika belum ada data, isi default dari Auth
      _nameController.text = currentUser!.displayName ?? "Member Baru";
      _phoneController.text = "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await _firestoreService.updateUserProfile(
        uid: currentUser!.uid,
        email: currentUser!.email,
        name: _nameController.text,
        phone: _phoneController.text,
        photoUrl: _selectedAvatarUrl,
      );

      if (widget.onSaved != null) widget.onSaved!();

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Profil berhasil diperbarui!"),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  // --- MODAL PILIH AVATAR ---
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Pilih Avatar Anda",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: _avatarOptions.length,
                  itemBuilder: (ctx, index) {
                    final url = _avatarOptions[index];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedAvatarUrl = url);
                        Navigator.pop(ctx);
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(url),
                        backgroundColor: Colors.grey[800],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Hapus variabel unused 'bgColor'
    const textColor = Colors.white;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profil", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black.withValues(alpha: 0.5),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF121212)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // --- AVATAR SELECTOR ---
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 55,
                                backgroundColor: Colors.white12,
                                backgroundImage:
                                    NetworkImage(_selectedAvatarUrl),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showAvatarPicker,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(
                                      color: Colors.blueAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text("Ketuk ikon pensil untuk ganti foto",
                              style: TextStyle(
                                  color: Colors.white54, fontSize: 12)),

                          const SizedBox(height: 30),

                          // Input Nama
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(color: textColor),
                            decoration:
                                _inputDecor("Nama Lengkap", Icons.person),
                            validator: (v) =>
                                v!.isEmpty ? "Nama wajib diisi" : null,
                          ),
                          const SizedBox(height: 20),

                          // Input HP
                          TextFormField(
                            controller: _phoneController,
                            style: const TextStyle(color: textColor),
                            keyboardType: TextInputType.phone,
                            decoration:
                                _inputDecor("Nomor WhatsApp", Icons.phone),
                          ),

                          const SizedBox(height: 10),
                          // Email Read Only
                          TextFormField(
                            initialValue: currentUser?.email,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white54),
                            decoration:
                                _inputDecor("Email", Icons.email).copyWith(
                              fillColor: Colors.black.withValues(alpha: 0.3),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Tombol Simpan
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Text("SIMPAN PERUBAHAN",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
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

  InputDecoration _inputDecor(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white70),
      labelStyle: const TextStyle(color: Colors.white60),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
