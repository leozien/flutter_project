// lib/models/user_model.dart

class User {
  final String email;
  final String password;
  final String role; // 'admin' atau 'user'

  User({
    required this.email,
    required this.password,
    this.role = 'user',
  });

  bool get isAdmin => role == 'admin';
}
