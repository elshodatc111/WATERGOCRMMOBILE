class CurrerActivePriceModel {
  final String container;
  final String water;

  CurrerActivePriceModel({
    required this.container,
    required this.water,
  });

  factory CurrerActivePriceModel.fromJson(Map<String, dynamic> json) {
    return CurrerActivePriceModel(
      container: json['container'],
      water: json['water'],
    );
  }
}