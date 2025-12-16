class Product {
  final String id;
  final String name;
  final int price;
  final String desc;
  final String image;
  final double rating;
  final int ratingCount;
  final String shopUrl;
  final bool isSold; // 🔥 Status Baru: Apakah sudah terjual?

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.desc,
    required this.image,
    this.rating = 5.0,
    this.ratingCount = 0,
    required this.shopUrl,
    this.isSold = false, // Default: Belum terjual
  });

  // Kirim data ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'desc': desc,
      'image': image,
      'rating': rating,
      'ratingCount': ratingCount,
      'shopUrl': shopUrl,
      'isSold': isSold, // Simpan status
    };
  }

  // Ambil data dari Firebase
  factory Product.fromMap(Map<String, dynamic> map, String documentId) {
    return Product(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price']?.toInt() ?? 0,
      desc: map['desc'] ?? '',
      image: map['image'] ?? '',
      rating: (map['rating'] ?? 5.0).toDouble(),
      ratingCount: map['ratingCount']?.toInt() ?? 0,
      shopUrl: map['shopUrl'] ?? '',
      isSold: map['isSold'] ?? false, // Baca status
    );
  }
}
