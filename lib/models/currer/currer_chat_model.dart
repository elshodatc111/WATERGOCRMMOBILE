class CurrerChatModel {
  final String message;
  final String user;
  final String date;

  CurrerChatModel({
    required this.message,
    required this.user,
    required this.date,
  });

  factory CurrerChatModel.fromJson(Map<String, dynamic> json) {
    return CurrerChatModel(
      message: json['message'],
      user: json['user'],
      date: json['data'],
    );
  }
}