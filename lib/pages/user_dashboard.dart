import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// Import Model, Data & Service
import '../models/app_state.dart';
import '../models/order_model.dart';
import '../data/dummy_products.dart';
import '../pages/detail_dialog.dart';
import '../pages/edit_profile_page.dart';
import '../pages/change_password_page.dart';
import '../pages/login_page.dart';
import '../pages/user_manager.dart';
import '../services/firestore_service.dart';

class UserDashboardPage extends StatefulWidget {
  final ValueNotifier<AppState> appState;
  final VoidCallback onAppStateChanged;

  const UserDashboardPage({
    super.key,
    required this.appState,
    required this.onAppStateChanged,
  });

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirestoreService _firestoreService = FirestoreService();

  final NumberFormat currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- LOGOUT FUNCTION ---
  void _logout() async {
    await UserManager().logout();
    widget.appState.value.currentUser = null;
    widget.onAppStateChanged();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          appState: widget.appState,
          products: [],
          onAppStateChanged: widget.onAppStateChanged,
          currency: currency,
          productManager: ProductManager(),
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _launchWhatsApp(String message) async {
    const number = "6282341361739";
    final Uri url =
        Uri.parse("https://wa.me/$number?text=${Uri.encodeComponent(message)}");

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Gagal membuka WhatsApp")));
        }
      }
    } catch (e) {
      debugPrint("Error WA: $e");
    }
  }

  // 🔥 FITUR BARU: POPUP VOUCHER SAYA
  void _showMyVouchers() {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.appState.value.isDarkMode
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        final textColor =
            widget.appState.value.isDarkMode ? Colors.white : Colors.black;
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Voucher Saya",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              const SizedBox(height: 16),
              _buildVoucherCard("DISKON50", "Diskon 50% All Item", textColor),
              const SizedBox(height: 10),
              _buildVoucherCard(
                  "LEOZIENNEW", "Potongan 10rb Pengguna Baru", textColor),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoucherCard(String code, String desc, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(10),
        color: Colors.blueAccent.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 12, color: textColor.withValues(alpha: 0.7))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text("Kode disalin! Gunakan saat checkout.")));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(horizontal: 10)),
            child: const Text("Pakai",
                style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Kebijakan Privasi"),
        content: const SingleChildScrollView(
          child: Text(
            "1. Data Anda aman tersimpan di server kami.\n"
            "2. Riwayat transaksi bersifat rahasia.\n"
            "3. Kami tidak membagikan data ke pihak ketiga.",
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("Tutup"))
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Proses':
        return Colors.blue;
      case 'Batal':
        return Colors.red;
      case 'Pending':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.appState.value.currentUser;
    final isDarkMode = widget.appState.value.isDarkMode;

    final bgColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.grey[100];
    final cardColor = isDarkMode ? const Color(0xFF2C2C2C) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Member Area"),
        backgroundColor: Colors.blueAccent.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.yellowAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "Profil"),
            Tab(icon: Icon(Icons.history), text: "Riwayat"),
            Tab(icon: Icon(Icons.favorite), text: "Wishlist"),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Keluar",
          )
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProfileTab(user?.email ?? "Tamu", cardColor, textColor),
          _buildHistoryTab(user?.email, cardColor, textColor),
          _buildWishlistTab(cardColor, textColor),
        ],
      ),
    );
  }

  // ================= TAB 1: PROFIL =================
  Widget _buildProfileTab(String email, Color cardColor, Color textColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 45, color: Colors.blueAccent),
                ),
                const SizedBox(height: 12),
                Text(
                  email,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // 🔥 FITUR BARU: PROGRESS BAR LOYALITAS
                Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Mythic Member",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12)),
                        Text("350 / 500 Poin",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 0.7, // 70% Progress (Simulasi)
                      backgroundColor: Colors.white24,
                      color: Colors.yellowAccent,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    const SizedBox(height: 4),
                    const Text("150 Poin lagi menuju Glory!",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontStyle: FontStyle.italic)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // STATISTIK SINGKAT
          Row(
            children: [
              Expanded(
                  child: _buildStatCard("Total Order", "3", Colors.orange,
                      Icons.shopping_bag, cardColor, textColor)),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildStatCard(
                      "Wishlist",
                      "${widget.appState.value.wishlist.length}",
                      Colors.red,
                      Icons.favorite,
                      cardColor,
                      textColor)),
            ],
          ),
          const SizedBox(height: 20),

          // MENU AKSI
          _buildActionTile(
            Icons.confirmation_number, // Ikon Voucher
            "Voucher Saya",
            cardColor,
            textColor,
            _showMyVouchers, // 🔥 Buka Popup Voucher
          ),
          _buildActionTile(
            Icons.settings,
            "Edit Profil",
            cardColor,
            textColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                    onSaved: widget.onAppStateChanged,
                  ),
                ),
              );
            },
          ),
          _buildActionTile(
            Icons.lock_reset,
            "Ganti Kata Sandi",
            cardColor,
            textColor,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChangePasswordPage(
                    appState: widget.appState,
                  ),
                ),
              );
            },
          ),
          _buildActionTile(
            Icons.help_center,
            "Pusat Bantuan (CS)",
            cardColor,
            textColor,
            () => _launchWhatsApp("Halo CS, saya butuh bantuan."),
          ),
          _buildActionTile(
            Icons.privacy_tip,
            "Kebijakan Privasi",
            cardColor,
            textColor,
            _showPrivacyPolicy,
          ),
        ],
      ),
    );
  }

  // ================= TAB 2: RIWAYAT REAL-TIME =================
  Widget _buildHistoryTab(String? userEmail, Color cardColor, Color textColor) {
    if (userEmail == null) {
      return const Center(child: Text("Silakan login untuk melihat riwayat."));
    }

    return StreamBuilder<List<OrderModel>>(
      stream: _firestoreService.getUserOrders(userEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text("Belum ada riwayat pesanan.",
                    style: TextStyle(color: textColor)),
              ],
            ),
          );
        }

        final orders = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final dateStr =
                DateFormat('dd MMM yyyy, HH:mm').format(order.timestamp);

            return Card(
              color: cardColor,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_bag,
                              color: Colors.blueAccent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order.productName,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: textColor),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(dateStr,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text(currency.format(order.price),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status)
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _getStatusColor(order.status)),
                              ),
                              child: Text(order.status,
                                  style: TextStyle(
                                      color: _getStatusColor(order.status),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // 🔥 TOMBOL AKSI JIKA STATUS PENDING
                    if (order.status == 'Pending') ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            _launchWhatsApp(
                                "Halo Admin, saya mau konfirmasi pembayaran untuk Order ID: ${order.id}");
                          },
                          icon: const Icon(Icons.payment, size: 18),
                          label: const Text("Konfirmasi Pembayaran (WA)"),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.green),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ================= TAB 3: WISHLIST =================
  Widget _buildWishlistTab(Color cardColor, Color textColor) {
    final wishlistIds = widget.appState.value.wishlist;

    return StreamBuilder<List<dynamic>>(
      stream: _firestoreService.getProducts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final allProducts = snapshot.data as List<dynamic>;
        final wishlistedProducts =
            allProducts.where((p) => wishlistIds.contains(p.id)).toList();

        if (wishlistedProducts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 60, color: Colors.grey[400]),
                const SizedBox(height: 10),
                Text("Wishlist Kosong",
                    style: TextStyle(color: textColor, fontSize: 16)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: wishlistedProducts.length,
          itemBuilder: (context, index) {
            final product = wishlistedProducts[index];
            return Card(
              color: cardColor,
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(10),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(product.image,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) =>
                          Container(color: Colors.grey, width: 60, height: 60)),
                ),
                title: Text(product.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: textColor)),
                subtitle: Text(currency.format(product.price),
                    style: const TextStyle(color: Colors.green)),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      widget.appState.value.wishlist.remove(product.id);
                      widget.onAppStateChanged();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Dihapus dari wishlist")));
                  },
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => DetailDialog(
                      product: product,
                      appState: widget.appState,
                      onAppStateChanged: widget.onAppStateChanged,
                      currency: currency,
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildStatCard(String title, String value, Color color, IconData icon,
      Color bg, Color text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: text)),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String title, Color bg, Color text,
      VoidCallback onTapAction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title,
            style: TextStyle(fontWeight: FontWeight.w500, color: text)),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTapAction,
      ),
    );
  }
}
