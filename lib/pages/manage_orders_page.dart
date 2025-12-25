// lib/pages/manage_orders_page.dart
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/order_model.dart';

class ManageOrdersPage extends StatelessWidget {
  const ManageOrdersPage({super.key}); // Tambahkan key agar tidak error lint

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Kelola Pesanan")),
      body: StreamBuilder<List<OrderModel>>(
        stream: firestoreService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada pesanan masuk."));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text("Order ID: ${order.id}"),
                subtitle: Text("Status: ${order.status}"),
                trailing: DropdownButton<String>(
                  value: order.status,
                  items: ['Pending', 'Dikirim', 'Selesai', 'Dibatalkan']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      firestoreService.updateOrderStatus(order.id, val);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}