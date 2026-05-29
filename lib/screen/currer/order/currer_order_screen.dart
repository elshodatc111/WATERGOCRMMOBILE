import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/currer_aktive_model.dart';
import 'package:water_go/screen/currer/order/currer_order_show_screen.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_active_service.dart';

class CurrerOrderScreen extends StatefulWidget {
  const CurrerOrderScreen({super.key});

  @override
  State<CurrerOrderScreen> createState() => _CurrerOrderScreenState();
}

class _CurrerOrderScreenState extends State<CurrerOrderScreen> {
  final GetStorage _storage = GetStorage();
  CurrerActiveService? _service;
  List<CurrerAktiveModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initServiceAndFetch();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }

  void _initServiceAndFetch() {
    final token = _storage.read<String>('auth_token') ?? '';
    _service = CurrerActiveService(token: token);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (_service == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final orders = await _service!.getAktivOrders();
      setState(() => _orders = orders);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Internetga ulanishda xatolik yuz berdi");
    } finally {
      setState(() => _isLoading = false);
    }
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
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      backgroundColor: ColorConst.bg,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ShimmerLoading();
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: ColorConst.red, fontSize: 16),
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Aktiv buyurtmalar mavjud emas",
              style: TextStyle(color: ColorConst.muted, fontSize: 16),
            ),
            SizedBox(height: 20),
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: ColorConst.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () => _initServiceAndFetch(),
                child: Text(
                  "Yangilash",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchOrders,
      color: ColorConst.blue,
      backgroundColor: ColorConst.bluePale,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: _orders.length,
          itemBuilder: (ctx, index) {
            final order = _orders[index];
            return Container(
              width: double.infinity,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: ColorConst.card, borderRadius: BorderRadius.circular(16),border: Border.all(color: ColorConst.border)),
              child: ListTile(
                onTap: () async {
                  await Get.to(() => CurrerOrderShowScreen(id: order.id));
                  _fetchOrders();
                },
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor: ColorConst.bluePale,
                  child: Text(
                    "${order.order}",
                    style: TextStyle(
                      color: ColorConst.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Buyurtma #${order.id}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: ColorConst.text,
                        fontSize: 14,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.phone, size: 14.0, color: ColorConst.muted),
                        Text(
                          order.phone,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: ColorConst.text,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 14.0,
                  color: ColorConst.muted,
                ),
                subtitle: Column(
                  children: [
                    SizedBox(height: 4.0,),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16.0,
                          color: ColorConst.muted,
                        ),
                        SizedBox(width: 2.0),
                        Text(
                          order.address,
                          style: TextStyle(
                            color: ColorConst.muted,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.timelapse,
                              size: 16.0,
                              color: ColorConst.muted,
                            ),
                            SizedBox(width: 2.0),
                            Text(
                              order.createdAt,
                              style: TextStyle(
                                color: ColorConst.muted,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.timelapse,
                              size: 16.0,
                              color: ColorConst.muted,
                            ),
                            SizedBox(width: 2.0),
                            Text(
                              order.updatedAt,
                              style: TextStyle(
                                color: ColorConst.muted,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
