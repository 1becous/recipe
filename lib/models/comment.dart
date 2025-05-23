
class Comment {
  final int id;
  final String content;
  final int recipeId;
  final int userId;
  final String username;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.recipeId,
    required this.userId,
    required this.username,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      recipeId: json['recipe_id'],
      userId: json['user_id'],
      username: json['username'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'recipe_id': recipeId,
      'user_id': userId,
      'username': username,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
