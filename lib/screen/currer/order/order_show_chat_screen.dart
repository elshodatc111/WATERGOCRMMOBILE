import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/currer_chat_model.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_active_service.dart';

class OrderShowChatScreen extends StatefulWidget {
  final int id;

  const OrderShowChatScreen({super.key, required this.id});

  @override
  State<OrderShowChatScreen> createState() => _OrderShowChatScreenState();
}

class _OrderShowChatScreenState extends State<OrderShowChatScreen> {
  final _storage = GetStorage();
  late final CurrerActiveService _service;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<CurrerChatModel> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    final token = _storage.read('auth_token') ?? '';
    _service = CurrerActiveService(token: token);
    _fetchChatHistory();
  }

  Future<void> _fetchChatHistory() async {
    try {
      final detail = await _service.getOrderDetail(widget.id);
      setState(() {
        _messages = detail.chats;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() {
      _isSending = true;
    });
    try {
      final newChat = await _service.sendChatMessage(
        orderId: widget.id,
        message: text,
      );
      setState(() {
        _messages.add(newChat);
        _messageController.clear();
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Xabar yuborishda xatolik: $e")));
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Buyurtma Chati #${widget.id}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchChatHistory();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildChatContent()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    if (_isLoading) {
      return ShimmerLoading();
    }
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 40),
              const SizedBox(height: 8),
              Text(_errorMessage, textAlign: TextAlign.center),
              TextButton(
                onPressed: _fetchChatHistory,
                child: const Text("Qayta urinish"),
              ),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          "Hozircha xabarlar yo'q.\nMijozga xabar yuborishingiz mumkin.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final chat = _messages[index];
        final String user = _storage.read('auth_user');
        final person = jsonDecode(user);
        final String name = person['name'];
        final isMe = chat.user == name;
        return _buildChatBubble(chat, isMe, name);
      },
    );
  }

  Widget _buildChatBubble(CurrerChatModel chat, bool isMe, String name) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? ColorConst.navy : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          border: isMe
              ? null
              : Border.all(color: Colors.grey.shade300, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              chat.message,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: isMe ? Colors.white60 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
                Text(
                  chat.date,
                  style: TextStyle(
                    color: isMe ? Colors.white60 : Colors.grey,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.only(
        top: 8.0,
        bottom: 30.0,
        left: 16.0,
        right: 16.0,
      ),
      color: ColorConst.navy,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Xabar yozing...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isSending ? null : _sendMessage,
              child: CircleAvatar(
                radius: 22,
                backgroundColor: ColorConst.navy,
                child: _isSending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
