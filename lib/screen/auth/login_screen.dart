import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:water_go/screen/splash_screen.dart';
import 'package:water_go/service/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _authService.login(
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      if (response.success) {
        _showSuccess('Xush kelibsiz, ${response.user?.name ?? ''}!');
        Get.offAll(() => const SplashScreen());
      } else {
        setState(() {
          _errorMessage = response.message ?? 'Noma\'lum xatolik';
        });
      }
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Kutilmagan xatolik yuz berdi';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Yumshoq oq fon (Light Slate)
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        // Status bardagi ikonkalarni qoraytiramiz
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Ekran markazida turishi uchun constraints orqali minimal balandlik beramiz
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 30,
                      ),
                      child: FadeTransition(
                        opacity: _fadeAnim,
                        child: SlideTransition(
                          position: _slideAnim,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Vertikal markazlash
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(), // Moslashuvchan yuqori bo'shliq
                              _buildHeader(),
                              const SizedBox(height: 40),
                              _buildForm(),
                              const SizedBox(height: 32),
                              _buildLoginButton(),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 20),
                                _buildErrorBanner(),
                              ],
                              const Spacer(), // Moslashuvchan pastki bo'shliq
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── Header ───
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            // Light neomorphic effekt
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock, // Water GO uchun mosroq ikonka qo'yildi
            color: Color(0xFF6366F1),
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tizimga Kirish',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF1E293B), // To'q matn rangi
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Telefon raqam va parolingizni kiriting',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFF64748B), // Kulrang sub-matn
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // ─── Form ───
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPhoneField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return _FieldWrapper(
      label: 'Telefon raqam',
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        // Faqat "+" va raqamlarni kiritishga ruxsat beramiz va max 13 ta belgi
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*')),
          LengthLimitingTextInputFormatter(13),
        ],
        decoration: _inputDecoration(
          hint: '+998901234567',
          icon: Icons.phone_android_rounded,
        ),
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'Telefon raqamni kiriting';
          }
          // RegEx: bitta + va ketidan roppa-rosa 12 ta raqam (jami 13 belgi)
          final phoneRegex = RegExp(r'^\+[0-9]{12}$');
          if (!phoneRegex.hasMatch(val.trim())) {
            return 'Format noto\'g\'ri (Masalan: +998901234567)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return _FieldWrapper(
      label: 'Parol',
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: _inputDecoration(
          hint: '••••••••',
          icon: Icons.key_rounded,
          suffix: GestureDetector(
            onTap: () => setState(() => _obscurePassword = !_obscurePassword),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: const Color(0xFF94A3B8),
              size: 20,
            ),
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Parolni kiriting';
          if (val.length < 6) return 'Parol kamida 6 ta belgi bo\'lishi kerak';
          return null;
        },
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6366F1), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      // Oq fonda chiroyli ko'rinishi uchun oq inputlar
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE2E8F0),
          width: 1.5,
        ), // Yupqa och kulrang chiziq
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFEF4444),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  // ─── Login Button ───
  Widget _buildLoginButton() {
    return SizedBox(
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: _isLoading
              ? const LinearGradient(
                  colors: [Color(0xFF818CF8), Color(0xFF818CF8)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                  // Premium Indigo Gradient
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kirish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ─── Error Banner ───
  Widget _buildErrorBanner() {
    return AnimatedOpacity(
      opacity: _errorMessage != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2), // Och qizil fon
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(
                  color: Color(0xFF991B1B),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _errorMessage = null),
              child: const Icon(
                Icons.close_rounded,
                color: Color(0xFFDC2626),
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Field Wrapper Widget
// ─────────────────────────────────────────
class _FieldWrapper extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldWrapper({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF475569), // To'q kulrang label (Light modega mos)
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
