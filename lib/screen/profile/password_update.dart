import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/service/auth_service.dart';
import 'package:water_go/service/snack_service.dart';

class PasswordUpdate extends StatefulWidget {
  const PasswordUpdate({super.key});

  @override
  State<PasswordUpdate> createState() => _PasswordUpdateState();
}

class _PasswordUpdateState extends State<PasswordUpdate> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  // Parollarni ko'rsatish/yashirish holatlari
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  // Parolni yangilash so'rovini yuborish
  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate() || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      await _authService.passwordUpdate(
        _currentPasswordController.text.trim(),
        _newPasswordController.text.trim(),
        _confirmPasswordController.text.trim(),
      );

      if (mounted) {
        SnackService.showSnack(
          context: context,
          message: "Parolingiz muvaffaqiyatli yangilandi",
          isSuccess: true,
        );
      }

      // Muvaffaqiyatli yakunlangach, sahifani yopish
      Get.back();
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
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
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
        iconTheme: IconThemeData(color: ColorConst.bluePale),
        title: Text(
          "Parolni yangilash",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Ekran bo'sh joyi bosilganda klaviaturani yopadi
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  "Xavfsizlikni ta'minlash uchun parolingizni muntazam yangilab turing.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 30),

                // 1. Amaldagi parol
                _buildLabel("Amaldagi parol"),
                TextFormField(
                  controller: _currentPasswordController,
                  obscureText: _obscureCurrent,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    hint: "Eski parolingizni kiriting",
                    isObscured: _obscureCurrent,
                    onToggle: () => setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Amaldagi parol kiritilishi majburiy";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 2. Yangi parol
                _buildLabel("Yangi parol"),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscureNew,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    hint: "Yangi parol o'ylab toping",
                    isObscured: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Yangi parol kiritilishi majburiy";
                    }
                    if (value.trim().length < 6) {
                      return "Parol kamida 6 ta belgidan iborat bo'lishi kerak";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 3. Yangi parolni tasdiqlash
                _buildLabel("Yangi parolni tasdiqlash"),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirm,
                  enabled: !_isLoading,
                  decoration: _buildInputDecoration(
                    hint: "Yangi parolni qayta kiriting",
                    isObscured: _obscureConfirm,
                    onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Parolni tasdiqlash majburiy";
                    }
                    if (value.trim() != _newPasswordController.text.trim()) {
                      return "Yangi parollar bir-biriga mos kelmadi";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),

                // 4. Yangilash tugmasi
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: ColorConst.navy.withOpacity(0.9),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required bool isObscured,
    required VoidCallback onToggle,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      fillColor: ColorConst.card,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorConst.border, width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: ColorConst.navy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey[500],
          size: 20,
        ),
        onPressed: onToggle,
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: _isLoading ? Colors.grey[400] : ColorConst.navy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextButton(
        onPressed: _isLoading ? null : _updatePassword,
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
          "Parolni yangilash",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}