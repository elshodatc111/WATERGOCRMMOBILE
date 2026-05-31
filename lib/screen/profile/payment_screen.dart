import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/ish_haqi_model.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/auth_service.dart';
import 'package:water_go/service/snack_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final AuthService _authService = AuthService();
  List<IshHaqiModel>? _payments;
  bool _isLoading = true;
  String? _errorMessage;
  @override
  void initState() {
    super.initState();
    _fetchPaymentData();
  }
  Future<void> _fetchPaymentData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _authService.getPayment();
      if (mounted) {
        if (data != null) {
          setState(() {
            _payments = data;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = "Ish haqi ma'lumotlari topilmadi yoki xato yuklandi.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Xatolik yuz berdi: $e";
          _isLoading = false;
        });
        SnackService.showSnack(
          context: context,
          message: e.toString(),
          isSuccess: false,
        );
      }
    }
  }

  int _calculateTotalSalary() {
    if (_payments == null) return 0;
    return _payments!.fold(0, (sum, item) => sum + item.amount);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: ColorConst.bluePale),
        title: Text(
          "Ish haqi to'lovlari",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _fetchPaymentData,
            icon: Icon(Icons.refresh, color: ColorConst.bluePale),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const ShimmerLoading();
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.black),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _fetchPaymentData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConst.navy,
                  foregroundColor: ColorConst.bluePale,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.refresh),
                label: const Text("Qayta urinish"),
              ),
            ],
          ),
        ),
      );
    }

    if (_payments == null || _payments!.isEmpty) {
      return const Center(child: Text("Ma'lumot mavjud emas"));
    }

    return RefreshIndicator(
      onRefresh: _fetchPaymentData,
      color: ColorConst.navy,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        itemCount: _payments!.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTotalSalaryCard(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: ColorConst.navy,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "To'lovlar tarixi",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: ColorConst.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }
          final item = _payments![index - 1];
          return _buildPaymentHistoryRow(item);
        },
      ),
    );
  }

  Widget _buildTotalSalaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: ColorConst.navy,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: ColorConst.navy.withOpacity(0.3),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Jami berilgan ish haqi",
            style: TextStyle(
              color: ColorConst.bluePale.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${_calculateTotalSalary()} UZS",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Divider(color: Colors.white24, height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniCardInfo("To'lovlar soni", "${_payments!.length} marta"),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildMiniCardInfo("Valyuta", "UZS"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniCardInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: ColorConst.bluePale.withOpacity(0.6), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentHistoryRow(IshHaqiModel item) {
    return Card(
      color: ColorConst.card,
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: ColorConst.border, width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green.withOpacity(0.1),
              child: Icon(item.type == 'cash'?Icons.money:item.type=='card'?Icons.payment:Icons.food_bank, color: Colors.green),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.description.isEmpty ? "Izoh qoldirilmagan" : item.description,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Turi: ${item.type=='cash'?"Naqt":item.type=='card'?"Karta":"Bank"} | Sana: ${item.date}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              "+${item.amount} UZS",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}