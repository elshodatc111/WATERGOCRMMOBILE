class CurrerBalansModel {
  final int full_contaner;
  final int empty_contaner;
  final int cash;
  final int card;
  final int bank;

  CurrerBalansModel({
    required this.full_contaner,
    required this.empty_contaner,
    required this.cash,
    required this.card,
    required this.bank,
  });

  factory CurrerBalansModel.fromJson(Map<String, dynamic> json) {
    return CurrerBalansModel(
      full_contaner: json['full_contaner'],
      empty_contaner: json['empty_contaner'],
      cash: json['cash'],
      card: json['card'],
      bank: json['bank'],
    );
  }
}
