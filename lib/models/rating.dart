class Rating {
  final int id;
  final double value;
  final int recipeId;
  final int userId;
  final String username;
  final DateTime createdAt;

  Rating({
    required this.id,
    required this.value,
    required this.recipeId,
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      id: json['id'],
      value: json['value'].toDouble(),
      recipeId: json['recipe_id'],
      userId: json['user_id'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'value': value,
      'recipe_id': recipeId,
      'user_id': userId,
      'username': username,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 