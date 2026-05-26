import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/screen/auth/login_screen.dart';
import 'package:water_go/service/auth_service.dart';

class CurrerMainScreen extends StatefulWidget {
  const CurrerMainScreen({super.key});
  @override
  State<CurrerMainScreen> createState() => _CurrerMainScreenState();
}

class _CurrerMainScreenState extends State<CurrerMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = GetStorage();
  String _courierName = "Kuryer";
  String _courierPhone = "";

  @override
  void initState() {
    super.initState();
    _loadCourierData();
  }

  void _loadCourierData() {
    final userString = _storage.read<String>('user');
    if (userString != null && userString.isNotEmpty) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userString);
        print(userData);
        setState(() {
          _courierName = userData['name'] ?? "Kuryer Xodim";
          _courierPhone = userData['phone'] ?? "";
        });
      } catch (e) {
        debugPrint("Kuryer ma'lumotlarini dekodlashda xatolik: $e");
        setState(() {
          _courierName = "Kuryer";
          _courierPhone = "";
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6366F1),
        ),
      ),
    );
    try {
      await AuthService().logout();
    } catch (e) {
      debugPrint("Logout error: $e");
    } finally {
      if (mounted) Navigator.of(context).pop();
      Get.offAll(() => const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC), // Loyihaga mos yumshoq oq fon
      appBar: AppBar(
        backgroundColor: const Color(0xFF6366F1),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Water Go',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22.0,
            letterSpacing: 0.5,
          ),
        ),
        // Chap tomondagi menyu tugmasi drawer-ni ochadi
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          )
        ],
      ),

      // ─── Yon Menyu (Drawer) ───
      drawer: Drawer(
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _buildMenuTile(
                      icon: Icons.local_shipping_rounded,
                      title: "Faol buyurtmalar",
                      badge: "3", // Kuryer ko'rib turishi uchun yangi buyurtmalar soni
                      onTap: () {},
                    ),
                    _buildMenuTile(
                      icon: Icons.history_toggle_off_rounded,
                      title: "Tarix (Yopilganlar)",
                      onTap: () {},
                    ),
                    _buildMenuTile(
                      icon: Icons.payments_rounded,
                      title: "Mening hisobim",
                      onTap: () {},
                    ),
                    _buildMenuTile(
                      icon: Icons.map_rounded,
                      title: "Xarita va Hududlar",
                      onTap: () {},
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: Color(0xFFE2E8F0), thickness: 1),
                    ),
                    _buildMenuTile(
                      icon: Icons.settings_outlined,
                      title: "Sozlamalar",
                      onTap: () {},
                    ),
                    _buildMenuTile(
                      icon: Icons.support_agent_rounded,
                      title: "Qo'llab-quvvatlash",
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            _buildLogoutButton(),
          ],
        ),
      ),
      body: const Center(
        child: Text(
          'Asosiy ekran mazmuni (Buyurtmalar ro\'yxati va h.k.)',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
        ),
      ),
    );
  }

  // ─── Drawer Header (Profil qismi) ───
  Widget _buildDrawerHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 24, left: 24, right: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF6366F1),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              SizedBox(width: 12,),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _courierName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _courierPhone.isNotEmpty ? _courierPhone : "+998 90 123 45 67",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              )
            ],
          ),

        ],
      ),
    );
  }

  // ─── Menu Elementlari uchun Universal Widget ───
  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        dense: true,
        horizontalTitleGap: 12,
        leading: Icon(icon, color: const Color(0xFF475569), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: badge != null
            ? Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444), // Qizil xabarnoma belgisi
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            badge,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        )
            : const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        visualDensity: const VisualDensity(vertical: -1),
      ),
    );
  }

  // ─── Chiqish Tugmasi (Pastki qism) ───
  Widget _buildLogoutButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2), // Och qizil fon
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                SizedBox(width: 10),
                Text(
                  'Tizimdan chiqish',
                  style: TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}