class ToyModel {
  final String id;
  final String ownerId;
  final String ownerName;
  final String name;
  final String category;
  final String condition;
  final String shareType;
  final String ageGroup;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  ToyModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.name,
    required this.category,
    required this.condition,
    required this.shareType,
    required this.ageGroup,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory ToyModel.fromJson(Map<String, dynamic> json) {
    return ToyModel(
      id: json['id'],
      ownerId: json['owner_id'],
      ownerName: json['owner_name'] ?? 'Kullanıcı',
      name: json['name'],
      category: json['category'],
      condition: json['condition'],
      shareType: json['share_type'],
      ageGroup: json['age_group'],
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'owner_id': ownerId,
      'owner_name': ownerName,
      'name': name,
      'category': category,
      'condition': condition,
      'share_type': shareType,
      'age_group': ageGroup,
      'description': description,
      'image_url': imageUrl,
    };
  }
}
