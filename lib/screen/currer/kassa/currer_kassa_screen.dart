import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class CurrerKassaScreen extends StatefulWidget {
  const CurrerKassaScreen({super.key});

  @override
  State<CurrerKassaScreen> createState() => _CurrerKassaScreenState();
}

class _CurrerKassaScreenState extends State<CurrerKassaScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        title: Text(
          "Kassa",
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
