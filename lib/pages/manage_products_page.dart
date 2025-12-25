import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product.dart';
import '../services/firestore_service.dart';

class ManageProductPage extends StatefulWidget {
  const ManageProductPage({super.key});

  @override
  State<ManageProductPage> createState() => _ManageProductPageState();
}

class _ManageProductPageState extends State<ManageProductPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final NumberFormat currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  // Fungsi untuk menampilkan Bottom Sheet (Formulir Tambah/Edit)
  void _showProductForm([Product? product]) {
    final isEdit = product != null;
    
    // Controller untuk field input
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final descController = TextEditingController(text: product?.desc ?? '');
    
    // MODIFIKASI: Menggabungkan list gambar menjadi string yang dipisahkan koma untuk diedit
    final imagesController = TextEditingController(
      text: (product?.images != null && product!.images.isNotEmpty) 
          ? product.images.join(', ') 
          : (product?.image ?? 'assets/pro1.jpeg')
    );
    
    final shopUrlController = TextEditingController(text: product?.shopUrl ?? 'https://wa.me/6282341361739');

    // Variabel lokal untuk status isSold
    bool localIsSold = product?.isSold ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEdit ? "Edit Produk" : "Tambah Produk Baru",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nama Produk")),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: "Harga"), keyboardType: TextInputType.number),
                
                // MODIFIKASI: Input untuk banyak gambar
                TextField(
                  controller: imagesController, 
                  decoration: const InputDecoration(
                    labelText: "Daftar Gambar (Pisahkan dengan koma)",
                    hintText: "assets/img1.jpg, assets/img2.jpg"
                  )
                ),
                
                TextField(controller: shopUrlController, decoration: const InputDecoration(labelText: "Link WhatsApp/Toko")),
                TextField(controller: descController, decoration: const InputDecoration(labelText: "Deskripsi"), maxLines: 2),
                
                const SizedBox(height: 10),
                
                SwitchListTile(
                  title: const Text("Tandai Sebagai Terjual (Sold Out)"),
                  subtitle: Text(localIsSold ? "Status: TERJUAL" : "Status: TERSEDIA"),
                  value: localIsSold,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    setModalState(() {
                      localIsSold = value;
                    });
                  },
                ),
                
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      // MODIFIKASI: Mengubah string input kembali menjadi List<String>
                      List<String> imagesList = imagesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      final newProduct = Product(
                        id: isEdit ? product.id : DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        price: int.tryParse(priceController.text) ?? 0,
                        desc: descController.text,
                        // Gambar utama diambil dari index pertama list
                        image: imagesList.isNotEmpty ? imagesList[0] : 'assets/pro1.jpeg',
                        images: imagesList, // Menyimpan list lengkap untuk slider
                        rating: product?.rating ?? 5.0,
                        ratingCount: product?.ratingCount ?? 0,
                        shopUrl: shopUrlController.text,
                        isSold: localIsSold,
                      );

                      if (isEdit) {
                        await _firestoreService.updateProduct(newProduct);
                      } else {
                        await _firestoreService.addProduct(newProduct);
                      }
                      
                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? 'Produk diperbarui!' : 'Produk ditambahkan!'), 
                            backgroundColor: Colors.green
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? "SIMPAN PERUBAHAN" : "TAMBAH PRODUK"),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Produk?"),
        content: Text("Yakin ingin menghapus ${product.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestoreService.deleteProduct(product.id);
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Produk"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Product>>(
        stream: _firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada produk. Klik + untuk menambah."));
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                child: ListTile(
                  leading: Stack(
                    children: [
                      Image.asset(
                        product.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
                      ),
                      if (product.isSold)
                        Container(
                          width: 50,
                          height: 50,
                          color: Colors.black45,
                          child: const Icon(Icons.check_circle, color: Colors.red, size: 20),
                        ),
                    ],
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))
                      ),
                      if (product.isSold)
                        const Badge(
                          label: Text("SOLD"),
                          backgroundColor: Colors.red,
                        ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currency.format(product.price), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Text("${product.images.length} Gambar Tersedia", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductForm(product),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(product),
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
        onPressed: () => _showProductForm(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}