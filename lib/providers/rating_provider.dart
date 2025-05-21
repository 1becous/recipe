import 'package:flutter/foundation.dart';
import '../models/rating.dart';
import '../services/api_service.dart';

class RatingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Rating> _ratings = [];
  bool _isLoading = false;

  List<Rating> get ratings => _ratings;
  bool get isLoading => _isLoading;

  double get averageRating {
    if (_ratings.isEmpty) return 0;
    final sum = _ratings.fold(0.0, (sum, rating) => sum + rating.value);
    return sum / _ratings.length;
  }

  Future<void> rateRecipe(int recipeId, double rating) async {
    try {
      await _apiService.rateRecipe(recipeId, rating);
      // You might want to refresh the recipe's ratings here
    } catch (e) {
      print('Error rating recipe: $e');
      rethrow;
    }
  }
} 