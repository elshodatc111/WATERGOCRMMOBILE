import 'package:flutter/material.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/currer_chat_model.dart';
class BuildChatBubble extends StatelessWidget {
  final CurrerChatModel chat;
  final bool isMe;
  final String name;
  const BuildChatBubble({super.key, required this.chat, required this.isMe, required this.name});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? ColorConst.blue : ColorConst.bluePale,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chat.message,
              style: TextStyle(color: isMe ? Colors.white : ColorConst.text, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(color: isMe ? Colors.white70 : ColorConst.muted, fontSize: 10),
                ),
                Text(
                  chat.date.length > 10 ? chat.date.substring(0, 16) : chat.date,
                  style: TextStyle(color: isMe ? Colors.white70 : ColorConst.muted, fontSize: 10),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
