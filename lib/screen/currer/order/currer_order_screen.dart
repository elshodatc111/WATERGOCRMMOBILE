import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/currer_aktive_model.dart';
import 'package:water_go/screen/currer/order/currer_order_show_page.dart';
import 'package:water_go/screen/currer/order/widget/currer_active_empry_widget.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_active_service.dart';

class CurrerOrderScreen extends StatefulWidget {
  const CurrerOrderScreen({super.key});

  @override
  State<CurrerOrderScreen> createState() => _CurrerOrderScreenState();
}

class _CurrerOrderScreenState extends State<CurrerOrderScreen> {
  final _storage = GetStorage();
  late final CurrerActiveService _service;
  late Future<List<CurrerAktiveModel>> _historyFuture;

  @override
  void initState() {
    super.initState();
    final token = _storage.read('auth_token') ?? '';
    _service = CurrerActiveService(token: token);
    _historyFuture = _service.getAktivOrders();
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _historyFuture = _service.getAktivOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        title: Text(
          "Aktiv buyurtmalar",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: ColorConst.bg,
      body: RefreshIndicator(
        onRefresh: _refreshOrders,
        child: FutureBuilder<List<CurrerAktiveModel>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerLoading();
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
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Xatolik yuz berdi:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorConst.navy,
                        ),
                        onPressed: _refreshOrders,
                        child: const Text(
                          "Qaytadan urinish",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final orders = snapshot.data!;
              if (orders.isEmpty) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_empty,size: 84,color: ColorConst.border,),
                        SizedBox(height: 36,),
                        const Text(
                          "Aktiv buyurtmalar mavjud emas.",
                          style: TextStyle(color: ColorConst.muted, fontSize: 16),
                        ),
                        SizedBox(height: 8.0,),
                        Text("Buyurtmalarni asosiy sahifa orqali qo'shing",
                          style: TextStyle(color: ColorConst.muted, fontSize: 16),)
                      ]
                  ),
                );
              }
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    color: ColorConst.card,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: ColorConst.border, width: 1.2),
                    ),
                    elevation: 2,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        final bool result = await Get.to(
                          () => CurrerOrderShowPage(id: order.id),
                        );
                        if (result == true) {
                          _refreshOrders();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ColorConst.navy.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    "ID: #${order.id}",
                                    style: TextStyle(
                                      color: ColorConst.navy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    "Aktive",
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.redAccent,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    order.address,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 18,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      " Buyurtma vaqti: ${order.createdAt}",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return const Center(child: Text("Aktiv Buyurtmalar mavjud emas."));
          },
        ),
      ),
    );
  }
}
