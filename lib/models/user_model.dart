class UserModel {
  final int id;
  final String name;
  final String phone;
  final String type;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.type,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'type': type,
    };
  }
}

class LoginResponse {
  final bool success;
  final String? token;
  final String? type;
  final UserModel? user;
  final String? message;

  LoginResponse({
    required this.success,
    this.token,
    this.type,
    this.user,
    this.message,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'],
      token: json['token'],
      type: json['type'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      message: json['message'],
    );
  }
}