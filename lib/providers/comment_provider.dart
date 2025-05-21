import 'package:flutter/foundation.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class CommentProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;

  Future<void> fetchComments(int recipeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getComments(recipeId);
      _comments = response.map((json) => Comment.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching comments: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addComment(int recipeId, String content) async {
    try {
      await _apiService.addComment(recipeId, content);
      await fetchComments(recipeId); // Refresh comments
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }
} 