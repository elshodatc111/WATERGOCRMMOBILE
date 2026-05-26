class ChatModel {
  final String message;
  final String user;
  final String date;

  ChatModel({
    required this.message,
    required this.user,
    required this.date,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      message: json['message'],
      user: json['user'],
      date: json['data'],
    );
  }
}