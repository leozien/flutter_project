import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/firestore_service.dart'; // Import Service Baru

class ManageProductPage extends StatefulWidget {
  final Product? product; // Jika null = Tambah Baru, Jika ada isi = Edit

  const ManageProductPage({super.key, this.product});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService =
      FirestoreService(); // Panggil Service

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _imageController;
  late TextEditingController _shopUrlController;

  bool _isLoading = false; // Indikator loading

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.desc ?? '');
    _imageController = TextEditingController(
        text: widget.product?.image ?? 'assets/pro1.jpeg');
    _shopUrlController = TextEditingController(
        text: widget.product?.shopUrl ?? 'https://wa.me/6282341361739');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _imageController.dispose();
    _shopUrlController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true); // Mulai loading

      final name = _nameController.text;
      final price = int.tryParse(_priceController.text) ?? 0;
      final desc = _descController.text;
      final image = _imageController.text;
      final shopUrl = _shopUrlController.text;

      try {
        if (widget.product == null) {
          // --- TAMBAH BARU KE FIREBASE ---
          // Kita buat ID unik berdasarkan waktu
          final String newId = DateTime.now().millisecondsSinceEpoch.toString();

          final newProduct = Product(
            id: newId,
            name: name,
            price: price,
            desc: desc,
            image: image,
            rating: 5.0,
            ratingCount: 0,
            shopUrl: shopUrl,
          );

          await _firestoreService.addProduct(newProduct);
        } else {
          // --- UPDATE KE FIREBASE ---
          final updatedProduct = Product(
            id: widget.product!.id, // Pakai ID lama
            name: name,
            price: price,
            desc: desc,
            image: image,
            rating: widget.product!.rating,
            ratingCount: widget.product!.ratingCount,
            shopUrl: shopUrl,
          );

          await _firestoreService.updateProduct(updatedProduct);
        }

        if (!mounted) return;
        Navigator.of(context).pop(); // Kembali
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Data berhasil disimpan ke Server!'),
              backgroundColor: Colors.green),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        backgroundColor: Colors.black, // Tema Monokrom
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_isLoading) const LinearProgressIndicator(),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nama Produk', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Nama harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'Harga (Angka)', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Harga harus diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                    labelText: 'Path Gambar (assets/...)',
                    border: OutlineInputBorder(),
                    helperText:
                        "Gunakan 'assets/namagambar.jpg' karena kita belum setup upload foto."),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _shopUrlController,
                decoration: const InputDecoration(
                    labelText: 'Link WhatsApp / Shop',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveProduct,
                icon: const Icon(Icons.save),
                label: Text(isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH PRODUK"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
