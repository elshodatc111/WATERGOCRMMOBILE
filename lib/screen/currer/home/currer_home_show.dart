import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:water_go/const/color_const.dart';
import 'package:water_go/models/currer/home_order_detal_model.dart';
import 'package:water_go/screen/currer/home/widget/build_chat_bubble.dart';
import 'package:water_go/screen/currer/home/widget/button_status_pedding_widget.dart';
import 'package:water_go/screen/currer/home/widget/chat_post_widget.dart';
import 'package:water_go/screen/currer/widget/shimmer_loading.dart';
import 'package:water_go/service/currer/currer_home_service.dart';
import 'package:water_go/service/snack_service.dart';
import 'package:url_launcher/url_launcher.dart';

class CurrerHomeShow extends StatefulWidget {
  final int id;

  const CurrerHomeShow({super.key, required this.id});

  @override
  State<CurrerHomeShow> createState() => _CurrerHomeShowState();
}

class _CurrerHomeShowState extends State<CurrerHomeShow> {
  final GetStorage _storage = GetStorage();
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  CurrerHomeService? _service;
  HomeOrderDetalModel? _detailData;

  bool _isLoading = false;
  bool _isActionLoading = false;
  bool _isChatLoading = false;
  String? _errorMessage;
  String _currentUserId = "";

  @override
  void initState() {
    super.initState();
    final token = _storage.read<String>('auth_token') ?? '';
    _service = CurrerHomeService(token: token);
    _loadCurrentUserId();
    _fetchOrderDetail();
  }



  @override
  void dispose() {
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCurrentUserId() {
    final userString = _storage.read<String>('auth_user');
    if (userString != null && userString.isNotEmpty) {
      try {
        final Map<String, dynamic> userData = jsonDecode(userString);
        setState(() {
          _currentUserId = userData['name']?.toString() ?? "";
        });
      } catch (e) {
        debugPrint("Foydalanuvchi ID sini o'qishda xatolik: $e");
      }
    }
  }

  Future<void> _makePhoneCall(BuildContext context, String phoneNumber) async {
    final String cleanPhone = phoneNumber.replaceAll(' ', '');
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        if (context.mounted) {
          SnackService.showSnack(
            context: context,
            message: "Qurilmada qo'ng'iroq qilish imkoni mavjud emas",
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        SnackService.showSnack(
          context: context,
          message: "Qo'ng'iroqni amalga oshirib bo'lmadi",
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _fetchOrderDetail() async {
    if (_service == null) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final data = await _service!.getOrderDetail(widget.id);
      setState(() {
        _detailData = data;
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() => _errorMessage = "Ma'lumotlarni yuklashda xatolik");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptOrder() async {
    if (_service == null || _detailData == null) return;
    setState(() => _isActionLoading = true);
    try {
      await _service!.acceptOrder(widget.id);
      SnackService.showSnack(
        context: context,
        message: "Buyurtma muvaffaqiyatli qabul qilindi!",
        isSuccess: true,
      );
      Get.back(result: true);
    } on ApiException catch (e) {
      SnackService.showSnack(
        context: context,
        message: e.message,
        isSuccess: false,
      );
    } catch (_) {
      SnackService.showSnack(
        context: context,
        message: "Kutilmagan xatolik",
        isSuccess: false,
      );
    } finally {
      setState(() => _isActionLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || _service == null || _isChatLoading) return;
    setState(() => _isChatLoading = true);
    _chatController.clear();
    try {
      final newChat = await _service!.sendChatMessage(
        orderId: widget.id,
        message: text,
      );
      setState(() {
        _detailData?.chats.add(newChat);
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      SnackService.showSnack(
        context: context,
        message: e.message,
        isSuccess: false,
      );
      _chatController.text = text;
    } catch (_) {
      SnackService.showSnack(
        context: context,
        message: "Xabar yuborilmadi",
        isSuccess: false,
      );
      _chatController.text = text;
    } finally {
      setState(() => _isChatLoading = false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
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
      backgroundColor: ColorConst.bg,
      appBar: AppBar(
        backgroundColor: ColorConst.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: ColorConst.bluePale,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Buyurtma #${widget.id}",
          style: const TextStyle(
            color: ColorConst.bluePale,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _detailData == null) return const ShimmerLoading();
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: ColorConst.red, fontSize: 16),
        ),
      );
    }
    if (_detailData == null) {
      return const Center(
        child: Text(
          "Ma'lumot topilmadi",
          style: TextStyle(color: ColorConst.muted),
        ),
      );
    }
    final order = _detailData!.order;
    return RefreshIndicator(
      onRefresh: _fetchOrderDetail,
      color: ColorConst.blue,
      backgroundColor: ColorConst.card,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: ColorConst.card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ColorConst.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.location_on_outlined,
                          "Manzil",
                          order.address,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          Icons.phone_android_rounded,
                          "Telefon",
                          order.phone
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            Icons.numbers,
                            "Buyurtma soni",
                            "${order.order}"
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                            Icons.timelapse,
                            "Buyurtma vaqti",
                            "${order.createdAt}"
                        ),
                        const SizedBox(height: 20),
                        ButtonStatusPeddingWidget(isActionLoading: _isActionLoading,acceptOrder: _acceptOrder,),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: ColorConst.bluePale, // Och ko'k fon
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextButton(
                            onPressed: () => _makePhoneCall(context, order.phone), // Bu yerga real telefon raqami keladi
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12), // Tugma ichki masofasi
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12), // Bosgandagi effekt chegarasi uchun
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.phone_android_rounded,
                                  color: ColorConst.blue, // To'q ko'k ikona
                                  size: 18,
                                ),
                                SizedBox(width: 8.0),
                                Text(
                                  "Telefon qilish",
                                  style: TextStyle(
                                    color: ColorConst.blue, // Matn rangi ham ikona bilan bir xil ko'k bo'ladi
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: ColorConst.muted,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "Buyurtma haqida",
                          style: TextStyle(
                            color: ColorConst.muted,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Card(
                    color: Colors.white,
                    margin: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: _detailData!.chats.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                "Hozircha izohlar yo'q",
                                style: TextStyle(color: ColorConst.muted),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: _detailData!.chats.length,
                            itemBuilder: (context, index) {
                              final chat = _detailData!.chats[index];
                              final bool isMe =
                                  chat.user == _currentUserId ||
                                  chat.user.isEmpty;
                              return BuildChatBubble(
                                chat: chat,
                                isMe: isMe,
                                name: chat.user,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
          ChatPostWidget(chatController: _chatController,isChatLoading: _isChatLoading,sendComment: _sendComment,),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: ColorConst.muted),
            const SizedBox(width: 8),
            Text(
              "$label: ",
              style: const TextStyle(
                color: ColorConst.muted,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            color: ColorConst.text,
            fontWeight: FontWeight.w600,
            fontSize: 16.0
          ),
        )
      ],
    );
  }
}
