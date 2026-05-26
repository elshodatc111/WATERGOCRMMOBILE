class OrderModel {
  final int id;
  final String phone;
  final String address;
  final int order;
  final String status;
  final String createdAt;

  OrderModel({
    required this.id,
    required this.phone,
    required this.address,
    required this.order,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      phone: json['phone'],
      address: json['address'],
      order: json['order'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }
}