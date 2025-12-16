import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order_model.dart';

class FirestoreService {
  // --- KOLEKSI DATABASE ---
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('products');

  final CollectionReference _orderCollection =
      FirebaseFirestore.instance.collection('orders');

  // ✅ Tambahkan Referensi Koleksi Users
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // ==================== BAGIAN PRODUK ====================

  Future<void> addProduct(Product product) async {
    await _productCollection.doc(product.id).set(product.toMap());
  }

  Stream<List<Product>> getProducts() {
    return _productCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateProduct(Product product) async {
    await _productCollection.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _productCollection.doc(id).delete();
  }

  // ==================== BAGIAN PESANAN (ORDER) ====================

  Future<void> placeOrder(OrderModel order) async {
    await _orderCollection.doc(order.id).set(order.toMap());
  }

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

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await _orderCollection.doc(orderId).update({'status': newStatus});
  }

  // ==================== BAGIAN USER PROFILE (PENTING UNTUK EDIT PROFIL) ====================

  // 1. Ambil Data User (Real-time)
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _usersCollection.doc(uid).snapshots();
  }

  // 2. Simpan/Update Data User (Fungsi yang sebelumnya error/hilang)
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String photoUrl,
    String? email,
  }) async {
    // Gunakan set dengan merge: true agar data tidak tertimpa total (misal email tetap ada)
    await _usersCollection.doc(uid).set({
      if (email != null) 'email': email,
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
