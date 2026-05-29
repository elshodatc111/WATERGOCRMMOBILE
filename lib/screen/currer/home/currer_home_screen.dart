import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/home_order_model.dart';
import 'package:water_go/screen/currer/home/currer_home_show.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_home_service.dart';

class CurrerHomeScreen extends StatefulWidget {
  const CurrerHomeScreen({super.key});

  @override
  State<CurrerHomeScreen> createState() => _CurrerHomeScreenState();
}

class _CurrerHomeScreenState extends State<CurrerHomeScreen> {
  final GetStorage _storage = GetStorage();
  CurrerHomeService? _service;
  List<HomeOrderModel> _orders = [];
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
    _service = CurrerHomeService(token: token);
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    if (_service == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final orders = await _service!.getHomeOrders();
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
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Yangi buyurtmalar",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
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
              "Yangi buyurtmalar mavjud emas",
              style: TextStyle(color: ColorConst.muted, fontSize: 16),
            ),
            SizedBox(height: 20,),
            Container(
              width: 200,
              decoration: BoxDecoration(
                color: ColorConst.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () => _initServiceAndFetch(),
                child: Text("Yangilash",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16.0),),
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
      child: ListView.builder(
        itemCount: _orders.length,
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Card(
            color: ColorConst.card,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: ColorConst.border),
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 0,
              ),
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: ColorConst.bluePale,
                child: Text(
                  "${order.order}",
                  style: const TextStyle(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorConst.text,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.timelapse,
                        size: 14.0,
                        color: ColorConst.muted,
                      ),
                      SizedBox(width: 2.0),
                      Text(
                        order.createdAt,
                        style: const TextStyle(
                          color: ColorConst.muted,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16.0,
                      color: ColorConst.muted,
                    ),
                    SizedBox(width: 2.0),
                    Text(
                      order.address,
                      style: const TextStyle(
                        color: ColorConst.muted,
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 14.0,
                color: ColorConst.muted,
              ),
              onTap: () async {
                await Get.to(() => CurrerHomeShow(id: order.id));
                _fetchOrders();
              },
            ),
          );
        },
      ),
    );
  }
}
