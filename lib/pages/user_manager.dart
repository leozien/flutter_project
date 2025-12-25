import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart'; // Tambahkan ini
import '../models/user.dart' as model;

class UserManager {
  static final UserManager _instance = UserManager._internal();
  factory UserManager() => _instance;
  UserManager._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Instance Firestore

  // --- 1. LOGIN (AUTHENTICATE) ---
  Future<model.User?> authenticate(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser != null) {
        // Ambil data role dari Firestore, bukan dari teks email
        DocumentSnapshot userDoc = 
            await _firestore.collection('users').doc(firebaseUser.uid).get();
        
        // Ambil role dari Firestore (default ke 'user' jika data tidak ada)
        String role = 'user';
        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          role = data['role'] ?? 'user';
        }

        debugPrint("Login Berhasil: ${firebaseUser.email} dengan role: $role");

        return model.User(
          email: firebaseUser.email ?? email,
          password: "", 
          role: role,
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Login Gagal: ${e.message}");
    } catch (e) {
      debugPrint("Error Lain: $e");
    }
    return null;
  }

  // --- 2. REGISTER (DAFTAR BARU) ---
  // Modifikasi untuk menerima data profil tambahan
  Future<bool> registerUser(String email, String password, {String? username, String? dob, String? gender}) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user?.uid;
      if (uid != null) {
        // Simpan data ke Firestore dengan role default 'user'
        // Status Admin hanya bisa diubah manual lewat Firebase Console
        await _firestore.collection('users').doc(uid).set({
          'email': email,
          'username': username ?? '',
          'dob': dob ?? '',
          'gender': gender ?? '',
          'role': 'user', // Selalu 'user' saat pertama kali daftar
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      debugPrint("Registrasi Berhasil di Firebase & Firestore: $email");
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Registrasi Gagal: ${e.code} - ${e.message}");
      return false;
    } catch (e) {
      debugPrint("Error Registrasi: $e");
      return false;
    }
  }

  // --- 3. RESET PASSWORD ---
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- 4. GANTI PASSWORD ---
  Future<bool> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Cek sesi aktif dan ambil role terbaru dari Firestore
  Future<model.User?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(user.uid).get();
      
      String role = 'user';
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        role = data['role'] ?? 'user';
      }
      
      return model.User(email: user.email!, password: "", role: role);
    }
    return null;
  }
}