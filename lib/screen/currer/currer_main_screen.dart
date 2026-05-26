import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/models/order_model.dart';
import 'package:water_go/screen/auth/login_screen.dart';
import 'package:water_go/screen/currer/history/history_screen.dart';
import 'package:water_go/screen/currer/ombor/ombor_screen.dart';
import 'package:water_go/screen/currer/order/home_show.dart';
import 'package:water_go/screen/currer/order/orders_screen.dart';
import 'package:water_go/screen/currer/profile/password_update_screen.dart';
import 'package:water_go/screen/currer/profile/payment_screen.dart';
import 'package:water_go/screen/currer/profile/profile_screen.dart';
import 'package:water_go/service/auth_service.dart';
import 'package:water_go/service/currer_service.dart';
import 'package:water_go/service/snack_service.dart';

class CurrerMainScreen extends StatefulWidget {
  const CurrerMainScreen({super.key});

  @override
  State<CurrerMainScreen> createState() => _CurrerMainScreenState();
}

class _CurrerMainScreenState extends State<CurrerMainScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final _storage = GetStorage();

  String _courierName = "Kuryer";
  String _courierPhone = "";
  String _courierType = "currer";

  late CurrerService _service;
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _drawerAnimController;
  late Animation<double> _drawerFadeAnim;

  @override
  void initState() {
    super.initState();
    _drawerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _drawerFadeAnim = CurvedAnimation(
      parent: _drawerAnimController,
      curve: Curves.easeOut,
    );
    _loadCourierData();
  }

  @override
  void dispose() {
    _drawerAnimController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _loadCourierData() {
    final userString = _storage.read<String>('auth_user');
    final token = _storage.read<String>('auth_token') ?? '';

    _service = CurrerService(token: token);

    if (userString != null && userString.isNotEmpty) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userString);
        setState(() {
          _courierName = userData['name'] ?? "Kuryer Xodim";
          _courierPhone = userData['phone'] ?? "";
          _courierType = userData['type'] ?? "currer";
        });
      } catch (e) {
        debugPrint("Kuryer ma'lumotlarini dekodlashda xatolik: $e");
      }
    }

    _fetchOrders();
  }

  // ── Fetch orders ──────────────────────────────
  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final orders = await _service.getHomeOrders();
      setState(() => _orders = orders);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Internetga ulanishda xatolik");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // ── Accept order ──────────────────────────────
  Future<void> _acceptOrder(OrderModel order) async {
    final confirmed = await _showAcceptDialog(order);
    if (!confirmed) return;

    try {
      await _service.acceptOrder(order.id);
      _fetchOrders();
      SnackService.showSnack(
        context: context,
        message: "Buyurtma #${order.id} qabul qilindi",
        isSuccess: true,
      );
    } on ApiException catch (e) {
      SnackService.showSnack(
        context: context,
        message: e.message,
        isSuccess: false,
      );
    } catch (_) {
      SnackService.showSnack(
        context: context,
        message: "Xatolik yuz berdi",
        isSuccess: false,
      );
    }
  }

  Future<bool> _showAcceptDialog(OrderModel order) async {
    return await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withOpacity(0.45),
          builder: (_) => _AcceptOrderDialog(order: order),
        ) ??
        false;
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (ctx) => _LogoutConfirmDialog(),
    );
    if (confirmed == true) await _performLogout();
  }

  Future<void> _performLogout() async {
    if (_scaffoldKey.currentState?.isDrawerOpen == true) {
      Navigator.of(context).pop();
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF4F7CFF)),
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

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'K';
  }

  String _getRoleLabel(String type) {
    switch (type) {
      case 'currer':
        return 'Kuryer';
      case 'ombor':
        return 'Omborchi';
      default:
        return 'Xodim';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  // ─── AppBar ───────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1A2B6B),
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF4F7CFF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Water Go',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      leading: IconButton(
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
          _drawerAnimController.forward(from: 0);
        },
        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
      ),
      actions: [
        IconButton(
          onPressed: _fetchOrders,
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
        ),
      ],
    );
  }

  // ─── Body ─────────────────────────────────────
  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFF1A2B6B),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.0),
                Text(
                  "Yangi buyurtmalar",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isLoading
                      ? "Yuklanmoqda..."
                      : "${_orders.length} ta buyurtma mavjud",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (!_isLoading && _orders.isNotEmpty)
            Container(
              margin: EdgeInsets.only(top: 16.0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF4F7CFF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_orders.length}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return _buildLoading();
    if (_errorMessage != null) return _buildError();
    if (_orders.isEmpty) return _buildEmpty();
    return _buildOrderList();
  }

  // ─── Loading ──────────────────────────────────
  Widget _buildLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) => _OrderCardSkeleton(),
    );
  }

  // ─── Error ────────────────────────────────────
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFFDC2626),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1A2B6B),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Qayta urinib ko'ring",
              style: TextStyle(color: Color(0xFF8A94B0), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2B6B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                "Yangilash",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty ────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: Color(0xFF4F7CFF),
              size: 46,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Buyurtmalar yo'q",
            style: TextStyle(
              color: Color(0xFF1A2B6B),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Hozircha yangi buyurtmalar mavjud emas",
            style: TextStyle(color: Color(0xFF8A94B0), fontSize: 13),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: _fetchOrders,
            icon: const Icon(
              Icons.refresh_rounded,
              size: 18,
              color: Color(0xFF4F7CFF),
            ),
            label: const Text(
              "Yangilash",
              style: TextStyle(
                color: Color(0xFF4F7CFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Orders ListView ──────────────────────────
  Widget _buildOrderList() {
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: const Color(0xFF4F7CFF),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          print(order.id);
          return _OrderCard(
            order: order,
            index: index,
            onDetail: () async {
              final bool? isRefreshed = await Get.to(
                () => HomeShow(id: order.id),
              );
              if (isRefreshed == true) {
                _fetchOrders();
              }
            },
            onAccept: () => _acceptOrder(order),
          );
        },
      ),
    );
  }

  // ─── Drawer (o'zgarishsiz) ────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: FadeTransition(
        opacity: _drawerFadeAnim,
        child: Column(
          children: [
            _buildDrawerHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _sectionLabel("ASOSIY"),
                    const SizedBox(height: 6),
                    _buildMenuTile(
                      icon: Icons.local_shipping_rounded,
                      title: "Mening buyurtmalarim",
                      subtitle: "Faol yetkazib berishlar",
                      onTap: () => Get.to(() => OrdersScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.history_rounded,
                      title: "Buyurtmalar tarix",
                      subtitle: "Yakunlangan buyurtmalar",
                      onTap: () => Get.to(() => HistoryScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.warehouse_rounded,
                      title: "Omborxona",
                      subtitle: "Mahsulotlar tarixi",
                      onTap: () => Get.to(() => OmborScreen()),
                    ),
                    const SizedBox(height: 16),
                    _sectionLabel("SOZLAMALAR"),
                    const SizedBox(height: 6),
                    _buildMenuTile(
                      icon: Icons.person_rounded,
                      title: "Profilim",
                      subtitle: "Shaxsiy ma'lumotlar",
                      onTap: () => Get.to(() => ProfileScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.payment_rounded,
                      title: "Ish haqi",
                      subtitle: "Ish haqi to'lovlar",
                      onTap: () => Get.to(() => PaymentScreen()),
                    ),
                    _buildMenuTile(
                      icon: Icons.lock_reset_rounded,
                      title: "Parolni yangilash",
                      subtitle: "Shaxsiy parol",
                      onTap: () => Get.to(() => PasswordUpdateScreen()),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildDrawerFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    final initials = _getInitials(_courierName);
    final roleLabel = _getRoleLabel(_courierType);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A2B6B),
        borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF4F7CFF),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _courierName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _courierPhone.isNotEmpty
                          ? _courierPhone
                          : "+998 -- --- -- --",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF4F7CFF).withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4F7CFF).withOpacity(0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF90AEFF),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  roleLabel,
                  style: const TextStyle(
                    color: Color(0xFF90AEFF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 14),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFADB5D0),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badge,
    Color badgeColor = const Color(0xFFFF5C5C),
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          splashColor: const Color(0xFF4F7CFF).withOpacity(0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: const Color(0xFF1A2B6B), size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF1A2B6B),
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF8A94B0),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFBDC5DE),
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerFooter() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          children: [
            const Divider(color: Color(0xFFEEF0F6), thickness: 1),
            const SizedBox(height: 8),
            const Text(
              'Water Go v1.0.0',
              style: TextStyle(color: Color(0xFFBDC5DE), fontSize: 11),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Material(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _showLogoutDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDEDE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.logout_rounded,
                            color: Color(0xFFDC2626),
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Tizimdan chiqish',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Order Card Widget
// ═══════════════════════════════════════════════
class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final int index;
  final VoidCallback onDetail;
  final VoidCallback onAccept;

  const _OrderCard({
    required this.order,
    required this.index,
    required this.onDetail,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2B6B).withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onDetail,
          splashColor: const Color(0xFF4F7CFF).withOpacity(0.06),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Top row: number badge + time ──
                Row(
                  children: [
                    // Order index circle
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFF1A2B6B),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Buyurtma #${order.id}",
                            style: const TextStyle(
                              color: Color(0xFF1A2B6B),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: const Color(0xFF8A94B0),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.createdAt,
                                style: const TextStyle(
                                  color: Color(0xFF8A94B0),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    _StatusBadge(status: order.status),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(color: Color(0xFFF0F2F8), height: 1),
                const SizedBox(height: 14),

                // ── Info rows ──
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  iconColor: const Color(0xFFDC2626),
                  label: "Manzil",
                  value: order.address,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.phone_rounded,
                  iconColor: const Color(0xFF16A34A),
                  label: "Telefon",
                  value: order.phone,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.water_drop_rounded,
                  iconColor: const Color(0xFF4F7CFF),
                  label: "Buyurtma",
                  value: "${order.order} ta",
                ),

                const SizedBox(height: 16),

                // ── Buttons ──
                Row(
                  children: [
                    // Detail button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDetail,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFDDE2F0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          foregroundColor: const Color(0xFF1A2B6B),
                        ),
                        icon: const Icon(Icons.visibility_rounded, size: 16),
                        label: const Text(
                          "Ko'rish",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Accept button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A2B6B),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text(
                          "Qabul qilish",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────
class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case 'new':
        bg = const Color(0xFFEEF2FF);
        fg = const Color(0xFF4F7CFF);
        label = "Yangi";
        icon = Icons.fiber_new_rounded;
        break;
      case 'pending':
        bg = const Color(0xFFFFF7ED);
        fg = const Color(0xFFD97706);
        label = "Jarayonda";
        icon = Icons.pending_rounded;
        break;
      case 'done':
        bg = const Color(0xFFF0FDF4);
        fg = const Color(0xFF16A34A);
        label = "Yakunlandi";
        icon = Icons.check_circle_rounded;
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF64748B);
        label = status;
        icon = Icons.info_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info Row ─────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFFADB5D0),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xFF1A2B6B),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Skeleton loader ──────────────────────────
class _OrderCardSkeleton extends StatefulWidget {
  @override
  State<_OrderCardSkeleton> createState() => _OrderCardSkeletonState();
}

class _OrderCardSkeletonState extends State<_OrderCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(40, 40, radius: 20),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(120, 14),
                    const SizedBox(height: 6),
                    _box(80, 11),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _box(double.infinity, 12),
            const SizedBox(height: 8),
            _box(160, 12),
            const SizedBox(height: 8),
            _box(100, 12),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _box(double.infinity, 40, radius: 12)),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: _box(double.infinity, 40, radius: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _box(double w, double h, {double radius = 8}) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF0F8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  Accept Order Dialog
// ═══════════════════════════════════════════════
class _AcceptOrderDialog extends StatefulWidget {
  final OrderModel order;

  const _AcceptOrderDialog({required this.order});

  @override
  State<_AcceptOrderDialog> createState() => _AcceptOrderDialogState();
}

class _AcceptOrderDialogState extends State<_AcceptOrderDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss(bool result) async {
    await _ctrl.reverse();
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon area
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4F7CFF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.local_shipping_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      const Text(
                        "Buyurtmani qabul qilish",
                        style: TextStyle(
                          color: Color(0xFF1A2B6B),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Buyurtma #${widget.order.id} ni qabul qilmoqchimisiz?\n${widget.order.address}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF8A94B0),
                          fontSize: 13.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _dismiss(false),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Bekor qilish",
                                    style: TextStyle(
                                      color: Color(0xFF1A2B6B),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _dismiss(true),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2B6B),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Qabul qilish",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ═══════════════════════════════════════════════
//  Logout Dialog (o'zgarishsiz)
// ═══════════════════════════════════════════════
class _LogoutConfirmDialog extends StatefulWidget {
  @override
  State<_LogoutConfirmDialog> createState() => _LogoutConfirmDialogState();
}

class _LogoutConfirmDialogState extends State<_LogoutConfirmDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss(bool result) async {
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFE4E4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFDC2626),
                        size: 34,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      const Text(
                        'Tizimdan chiqish',
                        style: TextStyle(
                          color: Color(0xFF1A2B6B),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Siz tizimdan chiqmoqchimisiz?\nBarcha aktiv sessiyalar tugaydi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF8A94B0),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _dismiss(false),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F4FF),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Bekor qilish',
                                    style: TextStyle(
                                      color: Color(0xFF1A2B6B),
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _dismiss(true),
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFDC2626,
                                      ).withOpacity(0.30),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    'Chiqish',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
