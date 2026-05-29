import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/screen/splash_screen.dart';
import 'package:water_go/service/auth_service.dart';
import 'package:water_go/service/snack_service.dart';

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
        SnackService.showSnack(context: context,
            message: 'Xush kelibsiz, ${response.user?.name ?? ''}!',
            isSuccess: true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
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
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Spacer(),
                              _buildHeader(),
                              const SizedBox(height: 40),
                              _buildForm(),
                              const SizedBox(height: 32),
                              _buildLoginButton(),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 20),
                                _buildErrorBanner(),
                              ],
                              const Spacer(),
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: ColorConst.muted.withAlpha(40),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.lock,
            color: ColorConst.navyLight,
            size: 30,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Tizimga Kirish',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorConst.navyLight,fontSize: 30,fontWeight: FontWeight.w800,letterSpacing: -0.5,),
        ),
        const SizedBox(height: 8),
        const Text(
          'Telefon raqam va parolingizni kiriting',
          textAlign: TextAlign.center,
          style: TextStyle(color: ColorConst.navy,fontSize: 15,fontWeight: FontWeight.w400,),
        ),
      ],
    );
  }

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
          color: ColorConst.navy,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*')),
          LengthLimitingTextInputFormatter(13),
        ],
        decoration: _inputDecoration(
          hint: '+998901234567',
          icon: Icons.phone_android_rounded,
        ),
        validator: (val) {
          if (val == null || val
              .trim()
              .isEmpty) {
            return 'Telefon raqamni kiriting';
          }
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
          color: ColorConst.navyLight,
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
              color: ColorConst.navyLight,
              size: 20,
            ),
          ),
        ),
        validator: (val) {
          if (val == null || val.isEmpty) return 'Parolni kiriting';
          if (val.length < 8) return 'Parol kamida 8 ta belgi bo\'lishi kerak';
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
        color: ColorConst.navy,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      prefixIcon: Icon(icon, color: ColorConst.navy, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: ColorConst.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: ColorConst.card,
          width: 1.5,
        ), // Yupqa och kulrang chiziq
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: ColorConst.card, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorConst.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: ColorConst.red, width: 1.8),
      ),
      errorStyle: const TextStyle(
        color: ColorConst.red,
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
            colors: [ColorConst.navy, ColorConst.navyLight],
          )
              : const LinearGradient(
            colors: [ColorConst.navyLight, ColorConst.navy],
            // Premium Indigo Gradient
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          boxShadow: _isLoading
              ? []
              : [
            BoxShadow(
              color: ColorConst.navy.withOpacity(0.2),
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
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              color: ColorConst.bg,
              strokeWidth: 2.5,
            ),
          )
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Kirish',
                style: TextStyle(
                  color: ColorConst.bg,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: ColorConst.bg,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return AnimatedOpacity(
      opacity: _errorMessage != null ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ColorConst.bg, // Och qizil fon
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ColorConst.redPale),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: ColorConst.red,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage ?? '',
                style: const TextStyle(
                  color: ColorConst.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => _errorMessage = null),
              child: const Icon(
                Icons.close_rounded,
                color: ColorConst.red,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
            color:ColorConst.muted,
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
