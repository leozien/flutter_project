import 'product.dart';
import 'user.dart'; // Pastikan file user.dart ada di folder models. Jika merah, hapus baris ini.

// 1. Class CartItem HARUS ada di sini agar detail_dialog mengenali tipe datanya
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class AppState {
  // Hapus kata 'final' agar variabel bisa diubah langsung oleh halaman lain jika perlu
  bool isDarkMode;
  List<CartItem> cart;
  Set<String> wishlist;
  User? currentUser; // Jika User merah, ganti jadi 'dynamic currentUser;' sementara

  AppState({
    this.isDarkMode = false,
    this.cart = const [], 
    this.wishlist = const {},
    this.currentUser,
  });

  bool get isLoggedIn => currentUser != null;
  
  // Cek null safety untuk isAdmin
  bool get isAdmin {
    if (currentUser == null) return false;
    // Asumsi di dalam User ada properti isAdmin. Jika error, ubah jadi return false;
    try {
      return currentUser!.isAdmin; 
    } catch (e) {
      return false;
    }
  }

  // Method copyWith PENTING untuk detail_dialog.dart
  AppState copyWith({
    bool? isDarkMode,
    List<CartItem>? cart,
    Set<String>? wishlist,
    User? currentUser,
  }) {
    return AppState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      cart: cart ?? this.cart,
      wishlist: wishlist ?? this.wishlist,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}