import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class ManageUsersPage extends StatelessWidget {
  const ManageUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("Daftar Pengguna")),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: firestoreService.getAllUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.person, color: Colors.green),
                ),
                title: Text(user['username'] ?? user['name'] ?? 'No Name'),
                subtitle: Text("${user['email']}\nRole: ${user['role']}"),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}