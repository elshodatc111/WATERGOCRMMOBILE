import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class ButtonStatusPeddingWidget extends StatefulWidget {
  final isActionLoading;
  final acceptOrder;
  const ButtonStatusPeddingWidget({super.key, required this.isActionLoading, required this.acceptOrder});

  @override
  State<ButtonStatusPeddingWidget> createState() => _ButtonStatusPeddingWidgetState();
}

class _ButtonStatusPeddingWidgetState extends State<ButtonStatusPeddingWidget> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: widget.isActionLoading ? null : widget.acceptOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConst.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: widget.isActionLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          "Buyurtmani qabul qilish",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
