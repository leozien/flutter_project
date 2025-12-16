class OrderModel {
  final String id;
  final String userId; // Siapa yang beli
  final String userName; // Nama pembeli (email)
  final String productName;
  final int price;
  final String status; // 'Pending', 'Proses', 'Selesai', 'Batal'
  final DateTime timestamp; // Kapan beli

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.productName,
    required this.price,
    required this.status,
    required this.timestamp,
  });

  // Kirim data ke Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'productName': productName,
      'price': price,
      'status': status,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  // Ambil data dari Firebase
  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    return OrderModel(
      id: docId,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Tamu',
      productName: map['productName'] ?? '',
      price: map['price']?.toInt() ?? 0,
      status: map['status'] ?? 'Pending',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }
}
