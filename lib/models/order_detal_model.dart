import 'package:water_go/models/chat_model.dart';
import 'package:water_go/models/order_model.dart';

class OrderDetailModel {
  final OrderModel order;
  final List<ChatModel> chats;

  OrderDetailModel({required this.order, required this.chats});
}