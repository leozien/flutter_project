import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ManagePromosPage extends StatefulWidget {
  const ManagePromosPage({super.key});

  @override
  State<ManagePromosPage> createState() => _ManagePromosPageState();
}

class _ManagePromosPageState extends State<ManagePromosPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Fungsi untuk menampilkan Dialog (Tambah jika docId null, Edit jika docId ada)
  void _showPromoForm({String? docId, String? currentTitle, String? currentUrl}) {
    final isEdit = docId != null;

    // Jika edit, isi field dengan data lama
    _titleController.text = currentTitle ?? "";
    _urlController.text = currentUrl ?? "assets/";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? "Edit Banner Promo" : "Tambah Promo Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: "Judul Promo",
                hintText: "Contoh: Diskon Akhir Tahun",
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: "Path Gambar (assets/...)",
                hintText: "Contoh: assets/promo1.jpg",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _titleController.clear();
              _urlController.clear();
              Navigator.pop(context);
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_urlController.text.isNotEmpty) {
                // Jika sedang edit, hapus ID lama terlebih dahulu sebelum menambah yang baru
                // Karena addPromo di FirestoreService biasanya menggunakan auto-generated ID
                if (isEdit) {
                  await _firestoreService.deletePromo(docId);
                }

                await _firestoreService.addPromo(
                  _urlController.text,
                  _titleController.text,
                );

                _urlController.clear();
                _titleController.clear();
                if (mounted) Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? "Banner diperbarui!" : "Banner ditambahkan!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(isEdit ? "Simpan Perubahan" : "Simpan"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Banner Promo"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.getPromos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "Belum ada banner promo.\nKlik tombol + untuk menambah.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final promos = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: promos.length,
            itemBuilder: (context, index) {
              final promo = promos[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      promo['imageUrl'],
                      width: 80,
                      height: 50,
                      fit: BoxFit.cover,
                      // Jika gambar tidak ditemukan di assets, tampilkan icon placeholder
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 80,
                        height: 50,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                  title: Text(
                    promo['title'] ?? "Tanpa Judul",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    promo['imageUrl'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol Edit
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showPromoForm(
                          docId: promo['id'],
                          currentTitle: promo['title'],
                          currentUrl: promo['imageUrl'],
                        ),
                      ),
                      // Tombol Hapus
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _firestoreService.deletePromo(promo['id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPromoForm(),
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}