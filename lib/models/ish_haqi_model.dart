class IshHaqiModel {
  final int id;
  final int amount;
  final String type;
  final String description;
  final String date;

  IshHaqiModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.date,
  });

  factory IshHaqiModel.fromJson(Map<String, dynamic> json) {
    return IshHaqiModel(
      id: json['id'] ?? 0,
      amount: json['amount'] ?? 0,
      type: json['type']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
    );
  }
}