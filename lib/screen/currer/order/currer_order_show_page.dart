import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/currer_active_detal_model.dart';
import 'package:water_go/screen/currer/order/currer_order_success_screen.dart';
import 'package:water_go/screen/currer/order/order_show_chat_screen.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_active_service.dart';
import 'package:water_go/service/snack_service.dart';

class CurrerOrderShowPage extends StatefulWidget {
  final int id;

  const CurrerOrderShowPage({super.key, required this.id});

  @override
  State<CurrerOrderShowPage> createState() => _CurrerOrderShowPageState();
}

class _CurrerOrderShowPageState extends State<CurrerOrderShowPage> {
  final _storage = GetStorage();
  late final CurrerActiveService _service;
  late Future<CurrerActiveDetalModel> _orderDetailFuture;

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(' ', '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          SnackService.showSnack(
            context: context,
            message: "Qurilmada qo'ng'iroq qilish imkoni mavjud emas",
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackService.showSnack(
          context: context,
          message: "Qo'ng'iroqni amalga oshirib bo'lmadi",
          isSuccess: false,
        );
      }
    }
  }

  bool _isOrderUpdated = false;

  @override
  void initState() {
    super.initState();
    final token = _storage.read('auth_token') ?? '';
    _service = CurrerActiveService(token: token);
    _loadOrderDetail();
  }

  void _loadOrderDetail() {
    setState(() {
      _orderDetailFuture = _service.getOrderDetail(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(result: _isOrderUpdated),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Buyurtma Tafsiloti",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(onPressed: _loadOrderDetail, icon: Icon(Icons.refresh)),
        ],
      ),
      // Qurilmaning o'zidagi "Orqaga" tugmasi bosilganda ham qiymat qaytarish uchun
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          Get.back(result: _isOrderUpdated);
        },
        child: FutureBuilder<CurrerActiveDetalModel>(
          future: _orderDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ShimmerLoading();
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 12),
                      Text('${snapshot.error}', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConst.navy,
                        ),
                        onPressed: _loadOrderDetail,
                        child: const Text(
                          "Qayta urinish",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final order = snapshot.data!.order;
              final List container = snapshot.data!.price
                  .map((e) => e.container)
                  .toList();
              final List water = snapshot.data!.price
                  .map((e) => e.water)
                  .toList();
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Card(
                      color: ColorConst.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: ColorConst.border, width: 1.2),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _infoRow(Icons.tag, "Buyurtma ID", "#${order.id}"),
                            const Divider(),
                            _infoRow(
                              Icons.checklist_rtl,
                              "Buyurtma holati",
                              order.status == 'new'
                                  ? "Yangi"
                                  : order.status == 'pending'
                                  ? "Yetqazilmoqda"
                                  : order.status == 'cancel'
                                  ? "Bekor qilindi"
                                  : "Yakunlandi",
                            ),
                            const Divider(),
                            _infoRow(
                              Icons.location_on,
                              "Manzil",
                              order.address,
                            ),
                            const Divider(),
                            _infoRow(
                              Icons.confirmation_num,
                              "Buyurtma soni",
                              "${order.order} ta",
                            ),
                            const Divider(),
                            _infoRow(Icons.phone, "Telefon", order.phone),
                            const Divider(),
                            _infoRow(
                              Icons.timelapse,
                              "Buyurtma vaqti",
                              order.createdAt,
                            ),
                            const Divider(),
                            _infoRow(
                              Icons.check_circle_outline,
                              order.status == 'pending'
                                  ? "Qabul qilindi"
                                  : "Yetqazildi",
                              order.updatedAt,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    _button(
                      "Buyurtma haqida chat",
                      Icons.message_outlined,
                      Colors.orangeAccent,
                      Colors.white,
                      () => Get.to(() => OrderShowChatScreen(id: order.id)),
                    ),
                    const SizedBox(height: 12.0),
                    _button(
                      "Telefon qilish",
                      Icons.phone_android,
                      Colors.green,
                      Colors.white,
                      () {
                        _makePhoneCall(context, order.phone);
                      },
                    ),
                    const SizedBox(height: 12.0),
                    if (order.status == 'pending')
                      _button(
                        'Buyurtmani yakunlash',
                        Icons.check,
                        ColorConst.blue,
                        Colors.white,
                        () async {
                          final dynamic result = await Get.to(
                            () => CurrerOrderSuccessScreen(
                              id: order.id,
                              containerPrice: int.tryParse(container.first ?? '0') ?? 0,
                              waterPrice: int.tryParse(water.first ?? '0') ?? 0,
                              count: order.order,
                            ),
                          );
                          if (result == true) {
                            _isOrderUpdated = true;
                            _loadOrderDetail();
                          }
                        },
                      ),
                  ],
                ),
              );
            }
            return const Center(child: Text("Ma'lumot topilmadi"));
          },
        ),
      ),
    );
  }

  Widget _button(
    String title,
    IconData icon,
    Color backgroundColor,
    Color textColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.all(Radius.circular(12.0)),
        border: Border.all(color: ColorConst.border, width: 1.2),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor, size: 22),
            const SizedBox(width: 10.0),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: ColorConst.navy, size: 22),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
