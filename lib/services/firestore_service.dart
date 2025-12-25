import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order_model.dart';

class FirestoreService {
  // --- KOLEKSI DATABASE ---
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('products');

  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('orders');

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  final CollectionReference _promoCollection =
      FirebaseFirestore.instance.collection('promos');

  // ==================== 1. BAGIAN PRODUK ====================

  // Menambahkan produk baru ke Firestore
  Future<void> addProduct(Product product) async {
    await _productCollection.doc(product.id).set(product.toMap());
  }

  // Mengambil aliran data produk secara real-time
  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Memperbarui data produk secara keseluruhan
  Future<void> updateProduct(Product product) async {
    await _productCollection.doc(product.id).update(product.toMap());
  }

  // Fungsi khusus untuk memperbarui status 'Sold Out' saja secara efisien
  Future<void> updateProductSoldStatus(String id, bool isSold) async {
    await _productCollection.doc(id).update({'isSold': isSold});
  }

  // Menghapus produk dari database
  Future<void> deleteProduct(String id) async {
    await _productCollection.doc(id).delete();
  }

  // ==================== 2. BAGIAN PESANAN (ORDER) ====================

  // Menyimpan pesanan baru
  Future<void> placeOrder(OrderModel order) async {
    await _orderCollection.doc(order.id).set(order.toMap());
  }

  // Ambil semua pesanan untuk Admin (diurutkan berdasarkan waktu terbaru)
  Stream<List<OrderModel>> getAllOrders() {
    return _orderCollection
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Ambil riwayat pesanan milik user tertentu
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _orderCollection
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // Memperbarui status pesanan (misal: 'Pending' ke 'Selesai')
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _orderCollection.doc(orderId).update({'status': newStatus});
  }

  // ==================== 3. BAGIAN USER MANAGEMENT ====================

  // Mendengarkan perubahan data profil user secara real-time
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots();
  }

  // Mendapatkan daftar seluruh pengguna untuk manajemen Admin
  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'uid': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();
    });
  }

  // Memperbarui informasi profil pengguna
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
    String? email,
  }) async {
    await _usersCollection.doc(uid).set({
      if (email != null) 'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ==================== 4. BAGIAN PROMO BANNER ====================

  // Mengambil data banner promo untuk slider di halaman utama
  Stream<List<Map<String, dynamic>>> getPromos() {
    return _promoCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>
        };
      }).toList();
    });
  }

  // Menambahkan banner promo baru
  Future<void> addPromo(String imageUrl, String title) async {
    await _promoCollection.add({
      'imageUrl': imageUrl,
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Menghapus banner promo
  Future<void> deletePromo(String id) async {
    await _promoCollection.doc(id).delete();
  }
}