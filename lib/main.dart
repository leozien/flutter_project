// lib/main.dart
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Import Model
import 'models/app_state.dart';
import 'models/product.dart';
import 'data/dummy_products.dart';

// Import Halaman
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_page.dart';
import 'pages/register_page.dart'; // <--- TAMBAHAN: Import Register
import 'pages/user_dashboard.dart'; // <--- TAMBAHAN: Import User Dashboard

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inisialisasi format tanggal/mata uang Indonesia
  await initializeDateFormatting('id_ID', null);
  runApp(const LeozienMarketApp());
}

class LeozienMarketApp extends StatefulWidget {
  const LeozienMarketApp({super.key});

  @override
  State<LeozienMarketApp> createState() => _LeozienMarketAppState();
}

class _LeozienMarketAppState extends State<LeozienMarketApp> {
  // 1. Inisialisasi State Aplikasi (Login, DarkMode, Cart, User)
  final ValueNotifier<AppState> appState = ValueNotifier(AppState());

  // 2. Inisialisasi ProductManager (Data Produk)
  final ProductManager productManager = ProductManager();

  // 3. Formatter Mata Uang (Rupiah)
  final NumberFormat currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  // FUNGSI PEMBANTU: Memicu rebuild UI saat state berubah
  void _onAppStateChanged() {
    // Gunakan copyWith() untuk memicu notifikasi perubahan nilai pada ValueNotifier
    appState.value = appState.value.copyWith();
  }

  @override
  Widget build(BuildContext context) {
    // Builder 1: Mendengarkan AppState (untuk Tema & Auth)
    return ValueListenableBuilder<AppState>(
      valueListenable: appState,
      builder: (context, state, _) {
        return MaterialApp(
          title: 'LEOZIEN MARKET',
          debugShowCheckedModeBanner: false,

          // --- KONFIGURASI TEMA ---
          themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData.light().copyWith(
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Colors.black),
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          darkTheme: ThemeData.dark(),

          // --- HALAMAN UTAMA (HOME) ---
          // Logika: Jika Login -> Home, Jika Belum -> Login
          home: ValueListenableBuilder<List<Product>>(
            valueListenable: productManager.productsNotifier,
            builder: (context, products, child) {
              if (state.isLoggedIn) {
                return HomePage(
                  appState: appState,
                  products: products,
                  productManager: productManager,
                  onAppStateChanged: _onAppStateChanged,
                  currency: currency,
                );
              } else {
                return LoginPage(
                  appState: appState,
                  products: products, // Opsional jika Login butuh data produk
                  productManager: productManager,
                  onAppStateChanged: _onAppStateChanged,
                  currency: currency,
                );
              }
            },
          ),

          // --- DEFINISI RUTE (ROUTES) ---
          // Di sinilah kita memperbaiki error "Could not find generator..."
          routes: {
            // 1. Rute Register
            "/register": (context) => RegisterPage(
                  appState: appState,
                ),

            // 2. Rute Dashboard User (Solusi Error Anda)
            "/user_dashboard": (context) => UserDashboardPage(
                  appState: appState,
                  onAppStateChanged: _onAppStateChanged,
                ),

            // 3. Rute Admin
            "/admin": (context) {
              return ValueListenableBuilder<List<Product>>(
                valueListenable: productManager.productsNotifier,
                builder: (context, products, child) {
                  return AdminPage(
                    appState: appState,
                    products: products,
                    productManager: productManager,
                    onAppStateChanged: _onAppStateChanged,
                    currency: currency,
                  );
                },
              );
            },
          },
        );
      },
    );
  }
}
