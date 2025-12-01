import 'package:flutter/material.dart';
import '../models/product.dart';

// --- Produk Awal ---
final List<Product> _initialProducts = [
  // 1. Angela
  Product(
    id: 'angela',
    name: 'ANGELA SANRIO (KOLEKTOR TERHORMAT IV)',
    image: 'assets/angela.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 670000,
    rating: 4.2,
    ratingCount: 16,
    shopUrl: 'https://wa.me/6282341361739?text=ANGELA+SANRIO+MASIH+ADA?',
  ),
  // 2. Lancelot
  Product(
    id: 'lancelot',
    name: 'LANCELOT DAWNING (KOLEKTOR SULTAN)',
    image: 'assets/Lancelot.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 5900000,
    rating: 4.5,
    ratingCount: 24,
    shopUrl: 'https://wa.me/6282341361739?text=Lancelot+Kolsul+MASIH+ADA?',
  ),
  // 3. Selena
  Product(
    id: 'selena',
    name: 'SELENA ZENITH (KOLEKTOR TERNAMA II)',
    image: 'assets/Selena.jpeg',
    desc: '(STOCK ADMIN) AVAILABLE✅.',
    price: 480000,
    rating: 4.0,
    ratingCount: 12,
    shopUrl: 'https://wa.me/6282341361739?text=Selena+Zenith+MASIH+ADA?',
  ),
  // 4. Sasuke
  Product(
    id: 'sasuke',
    name: 'SUYOU SASUKE (KOLEKTOR TERHORMAT I)',
    image: 'assets/sasuke.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 1750000,
    rating: 4.1,
    ratingCount: 10,
    shopUrl: 'https://wa.me/6282341361739?text=Sasuke+Terhormat+MASIH+ADA?',
  ),
  // 5. Fredrin
  Product(
    id: 'fredrin',
    name: 'FREDRIN NEOBEAST (KOLEKTOR JURAGAN III)',
    image: 'assets/fredrin.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 1700000,
    rating: 4.7,
    ratingCount: 30,
    shopUrl: 'https://wa.me/6282341361739?text=Fredrin+NEOBEAST+MASIH+ADA?',
  ),
  // 6. Ling
  Product(
    id: 'ling',
    name: 'LING COLECTOR (KOLEKTOR TERHORMAT II)',
    image: 'assets/ling.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 780000,
    rating: 4.3,
    ratingCount: 18,
    shopUrl: 'https://wa.me/6282341361739?text=Ling+Colector+MASIH+ADA?',
  ),
  // 7. Guinevere
  Product(
    id: 'guinevere',
    name: 'GUINEVERE ASPIRANT (KOLEKTOR TERHORMAT I)',
    image: 'assets/guin.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 150000,
    rating: 3.9,
    ratingCount: 8,
    shopUrl: 'https://wa.me/6282341361739?text=Guin+Aspirant+MASIH+ADA?',
  ),
  // 8. Angela Kishin
  Product(
    id: 'angela kishin',
    name: 'ANGELA KISHIN (KOLEKTOR TERHORMAT III)',
    image: 'assets/ankishin.jpeg',
    desc: '(STOCK ADMIN) AVAILABLE✅.',
    price: 750000,
    rating: 4.6,
    ratingCount: 22,
    shopUrl: 'https://wa.me/6282341361739?text=Angela+Kishin+MASIH+ADA?',
  ),
  // --- PRODUK BARU DITAMBAHKAN ---
  // 9. Gusion
  Product(
    id: 'Yin ShunShin',
    name: 'YIN SHUNSHIN\' (KOLEKTOR TERHORMAT I)',
    image: 'assets/yss.jpeg',
    desc: '(STOCK ADMIN) AVAILABLE✅.',
    price: 880000,
    rating: 4.8,
    ratingCount: 45,
    shopUrl: 'https://wa.me/6282341361739?text=YSS+COL+MASIH+ADA?',
  ),
  // 10. Chou
  Product(
    id: 'amon_soul',
    name: 'AMON SOUL (KOLEKTRO TERHORMAT III)',
    image: 'assets/amon.jpeg',
    desc: '(STOCK ADMIN) AVAILABLE✅.',
    price: 1350000,
    rating: 4.9,
    ratingCount: 60,
    shopUrl: 'https://wa.me/6282341361739?text=amon+soul+MASIH+ADA?',
  ),
  // 11. Fanny
  Product(
    id: 'Zilong cc',
    name: 'ZILONG COLLECTOR (EPIC LIMITED EDITION)',
    image: 'assets/zilong.jpeg',
    desc: '(STOCK ADMIN) SOLDDD❗.',
    price: 850000,
    rating: 4.4,
    ratingCount: 20,
    shopUrl: 'https://wa.me/6282341361739?text=zilong+cc+MASIH+ADA?',
  ),
  // 12. Hayabusa
  Product(
    id: 'Kagura Exo',
    name: 'KAGURA EXORCIST (KOLEKTOR SULTAN)',
    image: 'assets/kagura.jpeg',
    desc: '(STOCK ADMIN) AVAILABLE✅.',
    price: 950000,
    rating: 4.7,
    ratingCount: 35,
    shopUrl: 'https://wa.me/6282341361739?text=Hayabusa+Shura+MASIH+ADA?',
  ),
];

// ------------------------------------------------------------------

class ProductManager {
  // ✅ SINGLETON SETUP
  // Agar data tersinkronisasi di semua halaman (Admin & Home)
  static final ProductManager _instance = ProductManager._internal();

  factory ProductManager() {
    return _instance;
  }

  ProductManager._internal();

  // ✅ ValueNotifier
  final ValueNotifier<List<Product>> _productsNotifier =
      ValueNotifier<List<Product>>(List.from(_initialProducts));

  // Getter PUBLIK
  ValueNotifier<List<Product>> get productsNotifier => _productsNotifier;
  List<Product> get products => _productsNotifier.value;

  // --- FUNGSI ADMIN ---

  // Menambahkan produk baru (Create)
  void addProduct(Product product) {
    _productsNotifier.value = [..._productsNotifier.value, product];
  }

  // Mengedit produk (Update)
  void editProduct(Product newProduct) {
    List<Product> currentList = List.from(_productsNotifier.value);
    final index = currentList.indexWhere((p) => p.id == newProduct.id);

    if (index != -1) {
      currentList[index] = newProduct;
      _productsNotifier.value = currentList;
    }
  }

  // Menghapus produk (Delete)
  void deleteProduct(String id) {
    _productsNotifier.value =
        _productsNotifier.value.where((p) => p.id != id).toList();
  }
}
