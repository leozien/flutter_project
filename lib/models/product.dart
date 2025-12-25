// lib/models/product.dart

class Product {
  final String id;
  final String name;
  final int price;
  final String desc;
  final String image; // Gambar utama
  final List<String> images; // 🔥 TAMBAHAN: Untuk menyimpan daftar gambar slide
  final double rating;
  final int ratingCount;
  final String shopUrl;
  final bool isSold;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.image,
    this.images = const [], // Default list kosong jika tidak ada gambar tambahan
    this.rating = 5.0,
    this.ratingCount = 0,
    required this.shopUrl,
    this.isSold = false,
  });

  // Konversi ke Map untuk Firebase Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'desc': desc,
      'image': image,
      'images': images, // Simpan list gambar
      'rating': rating,
      'ratingCount': ratingCount,
      'shopUrl': shopUrl,
      'isSold': isSold,
    };
  }

  // Ambil data dari Firebase Firestore
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price']?.toInt() ?? 0,
      desc: map['desc'] ?? '',
      image: map['image'] ?? '',
      // Pastikan data 'images' dibaca sebagai List<String>
      images: List<String>.from(map['images'] ?? []), 
      rating: (map['rating'] ?? 5.0).toDouble(),
      ratingCount: map['ratingCount']?.toInt() ?? 0,
      shopUrl: map['shopUrl'] ?? '',
      isSold: map['isSold'] ?? false,
    );
  }
}