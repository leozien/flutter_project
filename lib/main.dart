import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

// Import halaman dan model Anda
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/admin_page.dart';
import 'pages/user_dashboard.dart';
import 'models/app_state.dart';
import 'data/dummy_products.dart'; // ProductManager

void main() async {
  // 1. Wajib ada untuk inisialisasi sistem Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase dengan Konfigurasi Manual
  //    (Menggunakan data dari config JS yang Anda berikan)
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAluhz9wsS3pJlp2RzzJs3X_7dkb9yZsno",
      appId: "1:750781518226:web:db2be02f64bf4a1b97b14b",
      messagingSenderId: "750781518226",
      projectId: "leozien-market",
      storageBucket: "leozien-market.firebasestorage.app",
    ),
  );

  // 3. Format Tanggal Indonesia
  await initializeDateFormatting('id_ID', null);

  // 4. Kunci Orientasi Potrait (Opsional, biar rapi)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // State Global Aplikasi
  final ValueNotifier<AppState> appState = ValueNotifier(AppState());
  final ProductManager productManager = ProductManager();

  // Mata Uang Rupiah
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leozien Market',
      theme: ThemeData(
        useMaterial3: true,
        // Kita atur font default agar elegan
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),

      // Rute Awal
      home: LoginPage(
        appState: appState,
        products: productManager.productsNotifier.value,
        onAppStateChanged: () => setState(() {}),
        currency: currencyFormat,
        productManager: productManager,
      ),

      // Definisi Rute Halaman
      routes: {
        '/home': (context) => HomePage(
              appState: appState,
              products: productManager.productsNotifier.value,
              onAppStateChanged: () => setState(() {}),
              currency: currencyFormat,
              productManager: productManager,
            ),
        '/admin': (context) => AdminPage(
              appState: appState,
              products: productManager.productsNotifier.value,
              onAppStateChanged: () => setState(() {}),
              currency: currencyFormat,
              productManager: productManager,
            ),
        '/user_dashboard': (context) => UserDashboardPage(
              appState: appState,
              onAppStateChanged: () => setState(() {}),
            ),
      },
    );
  }
}
