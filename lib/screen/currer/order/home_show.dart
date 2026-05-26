import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:water_go/models/chat_model.dart';
import 'package:water_go/models/order_detal_model.dart';
import 'package:water_go/service/currer_service.dart';
import 'package:water_go/service/snack_service.dart';

class HomeShow extends StatefulWidget {
  final int id;

  const HomeShow({super.key, required this.id});

  @override
  State<HomeShow> createState() => _HomeShowState();
}

class _HomeShowState extends State<HomeShow> {
  late CurrerService _service;
  OrderDetailModel? _orderDetail;
  final List<ChatModel> _chats = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isSending = false;
  bool _isAccepting = false;
  String? _errorMessage;
  final _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    _loadCourierData();
  }

  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    _service.dispose();
    super.dispose();
  }

  void _loadCourierData() {
    final token = _storage.read<String>('auth_token') ?? '';
    _service = CurrerService(token: token);
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _service.getOrderDetail(widget.id);
      setState(() {
        _orderDetail = detail;
        _chats.clear();
        _chats.addAll(detail.chats);
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = "Internetga ulanishda xatolik yuz berdi");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  Future<void> _makePhoneCall(String phoneNumber) async {
    // Probeller va ortiqcha belgilarni tozalaymiz
    final cleanPhone = phoneNumber.replaceAll(' ', '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        SnackService.showSnack(
          context: context,
          message: "Ushbu qurilmada qo'ng'iroq qilish imkoniyati mavjud emas",
          isSuccess: false,
        );
      }
    } catch (e) {
      SnackService.showSnack(
        context: context,
        message: "Qo'ng'iroq qilishda xatolik yuz berdi",
        isSuccess: false,
      );
    }
  }
  // Buyurtmani qabul qilish
  Future<void> _acceptOrder() async {
    setState(() => _isAccepting = true);
    try {
      await _service.acceptOrder(widget.id);
      SnackService.showSnack(
        context: context,
        message: "Buyurtma muvaffaqiyatli qabul qilindi.",
        isSuccess: true,
      );
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Get.back(result: true);
      }
    } on ApiException catch (e) {
      SnackService.showSnack(
        context: context,
        message: e.message,
        isSuccess: true,
      );
    } catch (e) {
      SnackService.showSnack(
        context: context,
        message: "Xatolik yuz berdi. Qaytadan urinib ko'ring",
        isSuccess: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final newChat = await _service.sendChatMessage(
        orderId: widget.id,
        message: text,
      );
      setState(() {
        _chats.add(newChat);
        _chatController.clear();
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      SnackService.showSnack(
        context: context,
        message: e.message,
        isSuccess: false,
      );
    } catch (e) {
      SnackService.showSnack(
        context: context,
        message: "Xabar yuborilmadi",
        isSuccess: false,
      );
    } finally {
      setState(() => _isSending = false);
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2B6B),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Buyurtma Tafsiloti",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchOrderDetail,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A2B6B)),
            )
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _fetchOrderDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A2B6B),
                      ),
                      child: const Text(
                        "Qayta urinish",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : _orderDetail == null
          ? const Center(child: Text("Buyurtma topilmadi"))
          : Column(
              children: [
                _buildOrderCard(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      topLeft: Radius.circular(12.0),
                    ),
                    border: Border.all(color: Color(0xFF1A2B6B), width: 1.5),
                  ),
                  child: Text(
                    "Mijoz bilan chat (${_chats.length})",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2B6B),
                      fontSize: 18.0,
                    ),
                  ),
                ),
                Expanded(child: _buildChatList()),
                _buildMessageInput(),
              ],
            ),
    );
  }

  // Buyurtma kartasi UI elementlari
  Widget _buildOrderCard() {
    final orderd = _orderDetail!.order;
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Buyurtma #${widget.id}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A2B6B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Yangi",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            // Izoh: OrderModel ichidagi manzillar yoki boshqa maydonlarni o'zingizga moslab oling
            _buildInfoRow(Icons.location_on_rounded, "Manzil", orderd.address),
            _buildInfoRow(Icons.phone_android_rounded, "Telefon raqam", orderd.phone),
            _buildInfoRow(Icons.shopping_bag_rounded, "Buyurtma soni", "${orderd.order}"),
            _buildInfoRow(Icons.access_time_filled_rounded, "Buyurtma vaqti", orderd.createdAt),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isAccepting ? null : _acceptOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A2B6B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isAccepting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle, color: Colors.white),
                label: const Text(
                  "Buyurtmani qabul qilish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: ()=>_makePhoneCall(orderd.phone.replaceAll(" ","")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: _isAccepting
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.call, color: Colors.white),
                label: const Text(
                  "Qo'ng'iroq qilish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                "$title: ",
                style: const TextStyle(fontWeight: FontWeight.w600,fontSize: 16.0),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(color: Colors.grey[800],fontSize: 16.0),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // Chat Ro'yxati UI
  Widget _buildChatList() {
    if (_chats.isEmpty) {
      return Center(
        child: Text(
          "Yozishmalar mavjud emas",
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(color: Colors.white),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(12),
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          String userString = GetStorage().read('auth_user');
          final Map<String, dynamic> userData = jsonDecode(userString);
          final chat = _chats[index];
          final isMe = chat.user == userData['name'];
          return Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: Get.width * 0.7,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                  bottomRight: isMe ? Radius.zero : const Radius.circular(12),
                ),
                border: Border.all(
                  color: isMe ? Color(0xFF1A2B6B) : Colors.black54,
                  width: 1.5,
                ),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.message,
                    style: TextStyle(
                      color: isMe ? Color(0xFF1A2B6B) : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        chat.user,
                        style: TextStyle(
                          color: isMe ? Color(0xFF1A2B6B) : Colors.black45,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        chat.date,
                        style: TextStyle(
                          color: isMe ? Color(0xFF1A2B6B) : Colors.black45,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Pastki Xabar yuborish input paneli
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Color(0xFF1A2B6B),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _chatController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: "Xabar yozing...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Colors.grey[100],
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSending
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _isSending ? null : _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
