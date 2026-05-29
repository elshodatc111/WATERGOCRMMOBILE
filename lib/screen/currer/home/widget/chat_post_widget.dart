import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
class ChatPostWidget extends StatefulWidget {
  final chatController;
  final sendComment;
  final isChatLoading;
  const ChatPostWidget({super.key, required this.chatController, required this.sendComment, required this.isChatLoading});

  @override
  State<ChatPostWidget> createState() => _ChatPostWidgetState();
}

class _ChatPostWidgetState extends State<ChatPostWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 44,
        top: 12,
      ),
      decoration: BoxDecoration(
        color: ColorConst.navy,
        border: Border(top: BorderSide(color: ColorConst.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.chatController,
              enabled: !widget.isChatLoading,
              style: const TextStyle(
                color: ColorConst.text,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: widget.isChatLoading
                    ? "Yuborilmoqda..."
                    : "Izoh qoldiring...",
                hintStyle: const TextStyle(color: ColorConst.muted),
                fillColor: ColorConst.bg,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          GestureDetector(
            onTap: widget.isChatLoading ? null : widget.sendComment,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: widget.isChatLoading
                  ? ColorConst.border
                  : ColorConst.blue,
              child: widget.isChatLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: ColorConst.blue,
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
