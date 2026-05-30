import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class CurrerOrderEndWidget extends StatefulWidget {
  const CurrerOrderEndWidget({super.key});

  @override
  State<CurrerOrderEndWidget> createState() => _CurrerOrderEndWidgetState();
}

class _CurrerOrderEndWidgetState extends State<CurrerOrderEndWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Center(
          child: Column(
            children: [
              Icon(Icons.assignment_turned_in_outlined, size: 70, color: ColorConst.navy),
              SizedBox(height: 12),
              Text(
                "Hozircha Yakunlangan buyurtmalar mavjud emas.",
                style: TextStyle(fontSize: 16, color: ColorConst.text, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
