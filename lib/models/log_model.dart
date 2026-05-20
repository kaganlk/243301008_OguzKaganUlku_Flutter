class LogModel {
  final String id;
  final String userId;
  final String action;
  final String detail;
  final DateTime createdAt;

  LogModel({
    required this.id,
    required this.userId,
    required this.action,
    required this.detail,
    required this.createdAt,
  });

  factory LogModel.fromJson(Map<String, dynamic> json) {
    return LogModel(
      id: json['id'],
      userId: json['user_id'],
      action: json['action'],
      detail: json['detail'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
