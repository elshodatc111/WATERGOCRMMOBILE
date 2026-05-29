import 'package:water_go/models/currer/currer_active_price_model.dart';
import 'package:water_go/models/currer/currer_aktive_model.dart';
import 'package:water_go/models/currer/currer_chat_model.dart';

class CurrerActiveDetalModel {
  final CurrerAktiveModel order;
  final List<CurrerChatModel> chats;
  final List<CurrerActivePriceModel> price;
  CurrerActiveDetalModel({required this.order, required this.chats, required this.price});
}