import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class CurrerActiveCircleWidget extends StatefulWidget {
  const CurrerActiveCircleWidget({super.key});

  @override
  State<CurrerActiveCircleWidget> createState() => _CurrerActiveCircleWidgetState();
}

class _CurrerActiveCircleWidgetState extends State<CurrerActiveCircleWidget> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorConst.navy),
      ),
    );
  }
}
