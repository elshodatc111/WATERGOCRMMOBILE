import 'package:water_go/models/currer/currer_balans_history_model.dart';
import 'package:water_go/models/currer/currer_balans_model.dart';

class CurrerBalansDetalModel {
  final CurrerBalansModel balans;
  final List<CurrerBalansHistoryModel> history;

  CurrerBalansDetalModel({required this.balans, required this.history});
}
