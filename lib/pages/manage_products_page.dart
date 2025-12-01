import 'package:flutter/material.dart';
import '../models/product.dart';
import '../data/dummy_products.dart'; // Pastikan path ini sesuai dengan struktur foldermu

class ManageProductPage extends StatefulWidget {
  final Product? product; // Jika null = Tambah Baru, Jika ada isi = Edit

  const ManageProductPage({super.key, this.product});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controller untuk Text Field
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _descController;
  late TextEditingController _imageController;
  late TextEditingController _shopUrlController;

  @override
  void initState() {
    super.initState();
    // Isi data awal jika sedang Edit
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController =
        TextEditingController(text: widget.product?.price.toString() ?? '');
    _descController = TextEditingController(text: widget.product?.desc ?? '');
    _imageController =
        TextEditingController(text: widget.product?.image ?? 'assets/');
    _shopUrlController = TextEditingController(
        text: widget.product?.shopUrl ?? 'https://wa.me/');
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = int.tryParse(_priceController.text) ?? 0;
      final desc = _descController.text;
      final image = _imageController.text;
      final shopUrl = _shopUrlController.text;

      // Gunakan ProductManager global yang ada di dummy_products.dart
      final manager = ProductManager();

      if (widget.product == null) {
        // --- LOGIKA TAMBAH BARU ---
        final newProduct = Product(
          id: DateTime.now().toString(), // ID unik sederhana
          name: name,
          price: price,
          desc: desc,
          image: image,
          rating: 5.0, // Default rating
          ratingCount: 0,
          shopUrl: shopUrl,
        );
        manager.addProduct(newProduct);
      } else {
        // --- LOGIKA EDIT ---
        final updatedProduct = Product(
          id: widget.product!.id, // ID tidak berubah
          name: name,
          price: price,
          desc: desc,
          image: image,
          rating: widget.product!.rating,
          ratingCount: widget.product!.ratingCount,
          shopUrl: shopUrl,
        );
        manager.editProduct(updatedProduct);
      }

      Navigator.of(context).pop(); // Kembali ke dashboard
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(widget.product == null
                ? 'Produk Ditambah!'
                : 'Produk Diupdate!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Produk" : "Tambah Produk"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (val) => val!.isEmpty ? 'Nama harus diisi' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Harga (Angka)'),
                keyboardType: TextInputType.number,
                validator: (val) => val!.isEmpty ? 'Harga harus diisi' : null,
              ),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(
                    labelText: 'Path Gambar (contoh: assets/foto.jpg)'),
              ),
              TextFormField(
                controller: _shopUrlController,
                decoration:
                    const InputDecoration(labelText: 'Link WhatsApp / Shop'),
              ),
              TextFormField(
                controller: _descController,
                decoration:
                    const InputDecoration(labelText: 'Deskripsi / Stok'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH PRODUK"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
