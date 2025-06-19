import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class CommentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;

  /// Завантажує список коментарів і зберігає їх у _comments
  Future<void> fetchComments(int recipeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _comments = await _apiService.getComments(recipeId);
    } catch (e) {
      debugPrint('Error fetching comments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Додає новий коментар і оновлює локальний список
  Future<void> addComment(int recipeId, String content) async {
    try {
      final newComment = await _apiService.addComment(recipeId, content);
      _comments.insert(0, newComment);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }
}
