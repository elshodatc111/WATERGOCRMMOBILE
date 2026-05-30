import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/service/currer/currer_active_service.dart';
import 'package:water_go/service/snack_service.dart';

class CurrerOrderSuccessScreen extends StatefulWidget {
  final int id;
  final int containerPrice;
  final int waterPrice;
  final int count;
  const CurrerOrderSuccessScreen({super.key, required this.id, required this.containerPrice, required this.waterPrice,required this.count});

  @override
  State<CurrerOrderSuccessScreen> createState() =>
      _CurrerOrderSuccessScreenState();
}

class _CurrerOrderSuccessScreenState extends State<CurrerOrderSuccessScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = GetStorage();
  late final CurrerActiveService _service;

  final TextEditingController _cashController = TextEditingController(
    text: '0',
  );
  final TextEditingController _cardController = TextEditingController(
    text: '0',
  );
  final TextEditingController _bankController = TextEditingController(
    text: '0',
  );
  late final TextEditingController _fullContainerController = TextEditingController(
    text: widget.count.toString(),
  );
  final TextEditingController _emptyContainerController = TextEditingController(
    text: '0',
  );
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final token = _storage.read('auth_token') ?? '';
    _service = CurrerActiveService(token: token);
  }

  @override
  void dispose() {
    _cashController.dispose();
    _cardController.dispose();
    _bankController.dispose();
    _fullContainerController.dispose();
    _emptyContainerController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final int cash = int.tryParse(_cashController.text) ?? 0;
    final int card = int.tryParse(_cardController.text) ?? 0;
    final int bank = int.tryParse(_bankController.text) ?? 0;
    final int fullContainer = int.tryParse(_fullContainerController.text) ?? 0;
    final int emptyContainer = int.tryParse(_emptyContainerController.text) ?? 0;
    final int totalPaid = cash + card + bank;
    final int expectedPrice = (fullContainer * (widget.containerPrice + widget.waterPrice)) - (emptyContainer * widget.containerPrice);
    if (totalPaid != expectedPrice) {
      SnackService.showSnack(
        context: context,
        message:
            "Kiritilgan summa: $totalPaid UZS.\nKutilayotgan summa: $expectedPrice UZS.\nIltimos, qayta tekshiring.",
        isSuccess: false,
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _service.acceptOrder(
        widget.id,
        cash,
        card,
        bank,
        fullContainer,
        emptyContainer,
      );
      setState(() => _isLoading = false);
      SnackService.showSnack(
        context: context,
        message:
        "Buyurtma muvaffaqiyatli yakunlandi",
        isSuccess: true,
      );
      Get.back(result: true);
    } catch (e) {
      setState(() => _isLoading = false);
      SnackService.showSnack(
        context: context,
        message:
        "Xatolik yuz berdi ${e.toString()}",
        isSuccess: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Buyurtmani Yakunlash",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle("Sotilgan maxsulotlar"),
                    Card(
                      color: ColorConst.card,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: ColorConst.border,width: 1.5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _fullContainerController,
                              label: "Tayyor maxsulot",
                              icon: Icons.local_drink,
                            ),
                            const Divider(height: 20),
                            _buildInputField(
                              controller: _emptyContainerController,
                              label: "Qaytarib olingan bo'sh idish",
                              icon: Icons.hourglass_empty,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _sectionTitle("Kassaga olingan to'lov"),
                    Card(
                      color: ColorConst.card,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: ColorConst.border,width: 1.5)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInputField(
                              controller: _cashController,
                              label: "Naqd pul (so'm)",
                              icon: Icons.money,
                            ),
                            const Divider(height: 20),
                            _buildInputField(
                              controller: _cardController,
                              label: "Plastik karta (so'm)",
                              icon: Icons.credit_card,
                            ),
                            const Divider(height: 20),
                            _buildInputField(
                              controller: _bankController,
                              label: "Bank o'tkazmasi (so'm)",
                              icon: Icons.account_balance,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _submitOrder,
                        child: const Text(
                          "Buyurtmani yakunlash",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: ColorConst.navy,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ColorConst.navy),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 10,
        ),
      ),
      onTap: () {
        if (controller.text == '0') {
          controller.clear();
        }
      },
      onChanged: (value) {
        if (value.length > 1 && value.startsWith('0')) {
          final cleanValue = int.parse(value).toString();
          controller.value = TextEditingValue(
            text: cleanValue,
            selection: TextSelection.collapsed(offset: cleanValue.length),
          );
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Maydonni to'ldiring (kamida 0 yozing)";
        }
        if (int.tryParse(value) == null) {
          return "Faqat to'g'ri son kiriting";
        }
        return null;
      },
    );
  }
}
