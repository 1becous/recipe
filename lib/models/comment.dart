import 'user.dart';

class Comment {
  final int id;
  final String content;
  final User user;

  Comment({required this.id, required this.content, required this.user});

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    content: json['content'],
    user: User.fromJson(json['user']),
  );
}
