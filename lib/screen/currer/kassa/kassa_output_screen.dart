import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/service/currer/currer_kassa_service.dart';
import 'package:water_go/service/snack_service.dart';

class KassaOutputScreen extends StatefulWidget {
  final int cash;
  final int card;
  final int bank;
  final int full_contaner;
  final int empty_contaner;

  const KassaOutputScreen({
    super.key,
    required this.cash,
    required this.card,
    required this.bank,
    required this.full_contaner,
    required this.empty_contaner,
  });

  @override
  State<KassaOutputScreen> createState() => _KassaOutputScreenState();
}

class _KassaOutputScreenState extends State<KassaOutputScreen> {
  final GetStorage _storage = GetStorage();
  late final CurrerKassaService _service;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _countController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Chiqim turlari ro'yxati
  final Map<String, String> _types = {
    'inp_cash': "Naqd summa",
    'inp_card': "Karta summa",
    'inp_bank': "Bank summa",
    'inp_full_contaner': "Tayyor mahsulot",
    'inp_empty_contaner': "Bo'sh idish",
  };

  String? _selectedType;
  bool _isLoading = false;
  bool _isButtonActive = false;

  @override
  void initState() {
    super.initState();
    _service = CurrerKassaService(token: _storage.read('auth_token') ?? '');

    // Qiymatlar o'zgarganda tugma holatini tekshirish
    _countController.addListener(_validateForm);
    _descController.addListener(_validateForm);
  }

  // Tanlangan turga qarab kurerda mavjud bo'lgan maksimal cheklovni aniqlash
  int _getMaxLimit() {
    if (_selectedType == null) return 0;
    switch (_selectedType) {
      case 'inp_cash':
        return widget.cash;
      case 'inp_card':
        return widget.card;
      case 'inp_bank':
        return widget.bank;
      case 'inp_full_contaner':
        return widget.full_contaner;
      case 'inp_empty_contaner':
        return widget.empty_contaner;
      default:
        return 0;
    }
  }

  // Tugma aktivligini tekshirish mantiqi
  void _validateForm() {
    final String countText = _countController.text.trim();
    final String descText = _descController.text.trim();

    if (_selectedType == null || countText.isEmpty || descText.isEmpty) {
      setState(() => _isButtonActive = false);
      return;
    }

    final int? count = int.tryParse(countText);
    if (count == null || count <= 0) {
      setState(() => _isButtonActive = false);
      return;
    }

    // Kiritilgan miqdor kurer balansidagi limitdan kichik yoki teng bo'lishi kerak
    final int maxLimit = _getMaxLimit();
    setState(() {
      _isButtonActive = count <= maxLimit;
    });
  }

  // Servis orqali chiqim so'rovini yuborish
  Future<void> _submitOutput() async {
    if (!_formKey.currentState!.validate() || !_isButtonActive || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final String finalType = _selectedType!;
      final int finalCount = int.parse(_countController.text.trim());
      final String finalDesc = _descController.text.trim();

      await _service.omborgaChiqim(finalType, finalCount, finalDesc);

      if (mounted) {
        SnackService.showSnack(
          context: context,
          message: "Chiqim muvaffaqiyatli amalga oshirildi",
          isSuccess: true,
        );
      }

      // Muvaffaqiyatli yakunlangach, oldingi sahifani yangilash uchun true qaytarib yopiladi
      Get.back(result: true);
    } catch (e) {
      if (mounted) {
        SnackService.showSnack(
          context: context,
          message: e.toString(),
          isSuccess: false,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _countController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        elevation: 0,
        title: Text(
          "Kassadan chiqim",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Joriy balans ma'lumotnomasi (kurer adashib ketmasligi uchun)
              if (_selectedType != null) _buildLimitBadge(),

              const SizedBox(height: 16),

              // 1. Chiqim turini tanlash (Dropdown)
              const Text(
                "Chiqim turi",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedType,
                hint: const Text("Chiqim turini tanlang"),
                decoration: InputDecoration(
                  fillColor: ColorConst.card,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConst.border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConst.navy, width: 1.5),
                  ),
                ),
                items: _types.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                    _countController.clear(); // Tur o'zgarganda eski miqdorni tozalaydi
                  });
                  _validateForm();
                },
              ),

              const SizedBox(height: 20),

              // 2. Miqdor kiritish maydoni (Faqat Int raqamlar)
              const Text(
                "Miqdori",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countController,
                keyboardType: TextInputType.number,
                enabled: _selectedType != null,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Faqat musbat butun sonlar
                decoration: InputDecoration(
                  hintText: _selectedType == null ? "Avval chiqim turini tanlang" : "Chiqim miqdorini kiriting",
                  fillColor: ColorConst.card,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConst.border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConst.navy, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Miqdor kiritish majburiy";
                  }
                  final int? entered = int.tryParse(value);
                  if (entered == null || entered <= 0) {
                    return "To'g'ri miqdor kiriting";
                  }
                  if (entered > _getMaxLimit()) {
                    return "Balansda mablag' yetarli emas (Maks: ${_getMaxLimit()})";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // 3. Chiqim haqida ma'lumot (Izoh) kiritish maydoni
              const Text(
                "Chiqim haqida batafsil izoh",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Ushbu chiqim sababini yoki tafsilotini yozing...",
                  fillColor: ColorConst.card,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConst.border, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: ColorConst.navy, width: 1.5),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Chiqim haqida izoh kiritish majburiy";
                  }
                  if (value.trim().length < 5) {
                    return "Izoh biroz batafsilroq bo'lishi kerak";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // 4. Chiqim qilish tugmasi (Loading va Aktivlik holatiga ega)
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Tanlangan tur bo'yicha joriy limitni ko'rsatib turuvchi widget
  Widget _buildLimitBadge() {
    final int limit = _getMaxLimit();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConst.navy.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorConst.navy.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: ColorConst.navy, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Sizda joriy maksimal limit: $limit ${_selectedType!.contains('contaner') ? 'ta' : 'UZS'}",
              style: TextStyle(
                color: ColorConst.navy,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dinamik tugma strukturasi
  Widget _buildSubmitButton() {
    final bool isActionable = _isButtonActive && !_isLoading;

    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: isActionable ? ColorConst.navy : Colors.grey[400],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: isActionable ? _submitOutput : null,
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : Text(
          "Chiqim qilish",
          style: TextStyle(
            color: isActionable ? ColorConst.bluePale : Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}