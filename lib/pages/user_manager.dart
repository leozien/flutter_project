import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../models/user.dart'
    as model; // Alias agar tidak bentrok dengan User Firebase

class UserManager {
  // Singleton
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  // Instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- 1. LOGIN (AUTHENTICATE) ---
  Future<model.User?> authenticate(String email, String password) async {
    try {
      // Mencoba login ke Server Google
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika berhasil, kita buat object User lokal
      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        debugPrint("Login Berhasil: ${firebaseUser.email}");

        // LOGIKA ADMIN SEMENTARA:
        // Jika email mengandung "admin", kita anggap dia admin.
        // Nanti bisa diganti dengan cek database Firestore.
        String role = email.contains("admin") ? 'admin' : 'user';

        return model.User(
          email: firebaseUser.email ?? email,
          password: "", // Tidak perlu simpan password di lokal demi keamanan
          role: role,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Gagal: ${e.message}");
      // Anda bisa handle error spesifik di sini (misal: user-not-found)
    } catch (e) {
      debugPrint("Error Lain: $e");
    }
    return null;
  }

  // --- 2. REGISTER (DAFTAR BARU) ---
  Future<bool> registerUser(String email, String password) async {
    try {
      // Membuat akun baru di Server Google
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint("Registrasi Berhasil di Firebase: $email");
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Registrasi Gagal: ${e.code} - ${e.message}");
      // Contoh error: 'email-already-in-use', 'weak-password'
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- 3. RESET PASSWORD (LUPA SANDI) ---
  Future<bool> resetPassword(String email) async {
    try {
      // Mengirim email reset password asli ke inbox user
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint("Email reset dikirim ke: $email");
      return true;
    } catch (e) {
      debugPrint("Gagal kirim reset email: $e");
      return false;
    }
  }

  // --- 4. GANTI PASSWORD (SAAT LOGIN) ---
  Future<bool> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Gagal ganti password: $e");
      return false;
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Cek apakah ada user yang sedang login (Sesi Aktif)
  model.User? getCurrentUser() {
    final user = _auth.currentUser;
    if (user != null) {
      String role = (user.email != null && user.email!.contains("admin"))
          ? 'admin'
          : 'user';
      return model.User(email: user.email!, password: "", role: role);
    }
    return null;
  }
}
