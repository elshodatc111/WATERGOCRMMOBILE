import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// =============================================
// CONNECTIVITY CONTROLLER
// =============================================
class ConnectivityController extends GetxController {
  final RxBool isConnected = true.obs;
  late StreamSubscription _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInitial();
    _listenChanges();
  }

  // Boshlang'ich tekshirish
  Future<void> _checkInitial() async {
    final result = await Connectivity().checkConnectivity();
    isConnected.value = _isOnline(result);
  }

  // Doimiy kuzatish
  void _listenChanges() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      isConnected.value = _isOnline(result);
    });
  }

  bool _isOnline(List<ConnectivityResult> result) {
    return result.isNotEmpty && !result.contains(ConnectivityResult.none);
  }

  // Qaytadan urinish
  Future<void> retry() async {
    final result = await Connectivity().checkConnectivity();
    isConnected.value = _isOnline(result);
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}

class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const NoInternetScreen({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/no_connection.png',width: 400,),
              const SizedBox(height: 32),
              const Text(
                'Internet aloqasi mavjud emas.\nInternet ulanishni tekshiring',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                  height: 2,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF90CAF9),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Qaytadan urinish',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectivityController>();

    return Obx(() {
      if (!controller.isConnected.value) {
        return NoInternetScreen(
          onRetry: () => controller.retry(),
        );
      }
      return child;
    });
  }
}