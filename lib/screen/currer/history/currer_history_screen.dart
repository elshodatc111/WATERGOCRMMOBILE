import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class CurrerHistoryScreen extends StatefulWidget {
  const CurrerHistoryScreen({super.key});

  @override
  State<CurrerHistoryScreen> createState() => _CurrerHistoryScreenState();
}

class _CurrerHistoryScreenState extends State<CurrerHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        title: Text(
          "Yakunlangan buyurtmalar",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
