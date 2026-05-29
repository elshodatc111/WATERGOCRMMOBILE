import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        centerTitle: true,
        title: Text(
          "Ish haqi to'lovlari",
          style: TextStyle(
            color: ColorConst.bluePale,
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(child: Text("Ish haqi to'lovlari"),),
    );
  }
}
