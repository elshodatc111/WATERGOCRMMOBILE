class CurrerBalansHistoryModel {
  final int id;
  final String type;
  final int count;
  final String description;
  final int status;
  final String omborchi;
  final String created_at;
  final String updated_at;

  CurrerBalansHistoryModel({
    required this.id,
    required this.type,
    required this.count,
    required this.description,
    required this.status,
    required this.omborchi,
    required this.created_at,
    required this.updated_at,
  });

  factory CurrerBalansHistoryModel.fromJson(Map<String, dynamic> json) {
    return CurrerBalansHistoryModel(
      id: json['id'],
      type: json['type'],
      count: json['count'],
      description: json['description'],
      status: json['status'],
      omborchi: json['omborchi'],
      created_at: json['created_at'],
      updated_at: json['updated_at'],
    );
  }
}
