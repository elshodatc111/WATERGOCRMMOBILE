import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class CurrerActiveEmpryWidget extends StatefulWidget {
  const CurrerActiveEmpryWidget({super.key});

  @override
  State<CurrerActiveEmpryWidget> createState() => _CurrerActiveEmpryWidgetState();
}

class _CurrerActiveEmpryWidgetState extends State<CurrerActiveEmpryWidget> {
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
                "Hozircha Aktiv buyurtmalar mavjud emas.",
                style: TextStyle(fontSize: 16, color: ColorConst.text, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
