import 'package:water_go/models/currer/currer_chat_model.dart';
import 'package:water_go/models/currer/home_order_model.dart';

class HomeOrderDetalModel {
  final HomeOrderModel order;
  final List<CurrerChatModel> chats;
  HomeOrderDetalModel({required this.order, required this.chats});
}