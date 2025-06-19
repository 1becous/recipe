

import 'package:recipeapp/models/user.dart';

/// Модель Comment для Flutter-клієнту
class Comment {
  /// Унікальний ідентифікатор коментаря
  final int id;
  /// Текст коментаря
  final String content;
  /// Інформація про автора коментаря
  final User user;

  Comment({
    required this.id,
    required this.content,
    required this.user,
  });

  /// Створює Comment з JSON, який повертає бекенд
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      content: json['content'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Для надсилання нового коментаря на бекенд
  /// Формує лише необходимые поля: content та recipe_id
  Map<String, dynamic> toJson(int recipeId) {
    return {
      'content': content,
      'recipe_id': recipeId,
    };
  }
}