class Product {
  final String id;
  final String name;
  final String image;
  final String desc; // Kita pastikan pakai 'desc'
  final int price;
  final String shopUrl;
  double rating;
  int ratingCount;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.desc, // Constructor minta 'desc'
    required this.price,
    required this.shopUrl,
    this.rating = 4.0,
    this.ratingCount = 1,
  });
}
