// lib/pages/user_manager.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_state.dart';
import '../models/user.dart'; // ✅ INI WAJIB ADA agar kelas 'User' dikenali

class UserManager {
  // --- SINGLETON SETUP ---
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  // --- PENYIMPANAN SEMENTARA (RAM) ---
  final List<User> _users = [
    User(email: 'admin', password: '1234', role: 'admin'),
    User(email: 'user', password: '1234', role: 'user'),
  ];

  // Fungsi Login
  Future<User?> authenticate(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final foundUser = _users.firstWhere(
        (user) => user.email == email && user.password == password,
      );

      debugPrint('Login Berhasil: ${foundUser.email} (${foundUser.role})');
      return foundUser;
    } catch (e) {
      debugPrint('Login Gagal: User tidak ditemukan atau password salah.');
      return null;
    }
  }

  // Fungsi Registrasi
  Future<bool> registerUser(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (_users.any((user) => user.email == email)) {
      debugPrint('Registrasi Gagal: Email sudah terdaftar.');
      return false;
    }

    final newUser = User(email: email, password: password, role: 'user');
    _users.add(newUser);

    debugPrint('Registrasi Berhasil (RAM): ${newUser.email}');
    return true;
  }
}
