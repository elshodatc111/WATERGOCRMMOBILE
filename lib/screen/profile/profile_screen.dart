import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/screen/profile/password_update.dart';
import 'package:water_go/screen/profile/payment_screen.dart';
import 'package:water_go/screen/splash_screen.dart';
import 'package:water_go/service/auth_service.dart';
import 'package:water_go/service/snack_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final userStr = GetStorage().read<String>('auth_user');
  late Map<String, dynamic> user = jsonDecode(userStr!);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        title: Text(
          "Profil",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Center(
              child: CircleAvatar(
                maxRadius: 60.0,
                minRadius: 60.0,
                backgroundColor: ColorConst.blue,
                child: Image.asset('assets/images/avatar.png',width: 100,),
              ),
            ),
            SizedBox(height: 12.0),
            Text(
              user['name'],
              style: TextStyle(
                color: ColorConst.text,
                fontWeight: FontWeight.w600,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(user['phone'], style: TextStyle(color: ColorConst.text)),
            Spacer(),
            buildButton(
              onTap: () {
                Get.to(() => PaymentScreen());
              },
              icon: Icons.payment,
              text: "Ish haqi to'lovlari",
              status: true,
            ),
            SizedBox(height: 16.0),
            buildButton(
              onTap: () {
                Get.to(() => PasswordUpdate());
              },
              icon: Icons.password_outlined,
              text: "Parolni yangliash",
              status: true,
            ),
            SizedBox(height: 16.0),
            buildButton(
              onTap: () {
                Get.dialog(
                  Dialog(
                    backgroundColor: ColorConst.card,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 28.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16.0),
                            decoration: const BoxDecoration(
                              color: ColorConst.redPale,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: ColorConst.red,
                              size: 32.0,
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          const Text(
                            "Tizimdan chiqish",
                            style: TextStyle(
                              color: ColorConst.text,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10.0),
                          const Text(
                            "Haqiqatdan ham profilingizdan chiqmoqchimisiz? Kelgusi buyurtmalarni ko'rish uchun qayta tizimga kirishingiz kerak bo'ladi.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: ColorConst.muted,
                              fontSize: 14.0,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 28.0),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 46.0,
                                  child: OutlinedButton(
                                    onPressed: () => Get.back(),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: ColorConst.border,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Yo'q",
                                      style: TextStyle(
                                        color: ColorConst.text,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: SizedBox(
                                  height: 46.0,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Get.dialog(
                                        const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  ColorConst.blue,
                                                ),
                                          ),
                                        ),
                                        barrierDismissible: false,
                                      );
                                      try {
                                        await AuthService().logout();
                                      } catch (e) {
                                        print(e);
                                      } finally {
                                        Get.back();
                                        Get.offAll(() => const SplashScreen());
                                        SnackService.showSnack(
                                          context: context,
                                          message:
                                              "Tizimdan mofaqiyatli chiqildi",
                                          isSuccess: true,
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ColorConst.red,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12.0,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Chiqish",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  barrierDismissible:
                      true, // Tashqariga bosganda ham dialog yopilishi uchun
                );
              },
              icon: Icons.logout,
              text: "Chiqish",
              status: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildButton({
    required VoidCallback onTap,
    required IconData icon,
    required String text,
    required bool status,
  }) {
    final Color backgroundColor = status ? ColorConst.blue : ColorConst.red;
    final Color foregroundColor = status
        ? ColorConst.bluePale
        : ColorConst.redPale;
    return SizedBox(
      height: 52.0,
      width: double.infinity,
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: foregroundColor, size: 20.0),
        label: Text(
          text,
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }
}
