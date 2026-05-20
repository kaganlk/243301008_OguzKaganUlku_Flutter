class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String toyId;
  final String text;
  final DateTime createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.toyId,
    required this.text,
    required this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      toyId: json['toy_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
