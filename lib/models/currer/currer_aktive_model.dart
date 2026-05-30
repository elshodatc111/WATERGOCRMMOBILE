class CurrerAktiveModel {
  final int id;
  final String phone;
  final String address;
  final int order;
  final String status;
  final String createdAt;
  final String updatedAt;

  CurrerAktiveModel({
    required this.id,
    required this.phone,
    required this.address,
    required this.order,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CurrerAktiveModel.fromJson(Map<String, dynamic> json) {
    return CurrerAktiveModel(
      id: json['id'],
      phone: json['phone'],
      address: json['address'],
      order: json['order'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}
