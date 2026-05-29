import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class CurrerOrderScreen extends StatefulWidget {
  const CurrerOrderScreen({super.key});

  @override
  State<CurrerOrderScreen> createState() => _CurrerOrderScreenState();
}

class _CurrerOrderScreenState extends State<CurrerOrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        title: Text(
          "Aktiv buyurtmalar",
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
