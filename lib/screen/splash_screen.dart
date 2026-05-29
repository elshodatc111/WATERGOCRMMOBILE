import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:water_go/screen/admin/admin_main_screen.dart';
import 'package:water_go/screen/auth/login_screen.dart';
import 'package:water_go/screen/currer/currer_main_screen.dart';
import 'package:water_go/screen/ombor/ombor_main_screen.dart';
import 'package:water_go/screen/operator/operator_main_screen.dart';
import 'package:water_go/service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _setupAnimation();
    _startSplash();
  }

  void _setupAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  Future<void> _startSplash() async {
    final results = await Future.wait([
      Future.delayed(const Duration(seconds: 3)),
      _authService.checkAuth(),
    ]);
    final authStatus = results[1] as AuthStatus;
    _navigate(authStatus);
  }

  void _navigate(AuthStatus status) {
    switch (status) {
      case AuthStatus.noToken:
      case AuthStatus.tokenInvalid:
        Get.offAll(()=>LoginScreen());
        break;
      case AuthStatus.currer:
        Get.offAll(()=>CurrerMainScreen());
        break;
      case AuthStatus.ombor:
        Get.offAll(()=>OmborMainScreen());
        break;
      case AuthStatus.operator:
        Get.offAll(()=>OperatorMainScreen());
        break;
      case AuthStatus.admin:
        Get.offAll(()=>AdminMainScreen());
        break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset('assets/images/logo.png', width: 256),
              ),
            );
          },
        ),
      ),
    );
  }
}
