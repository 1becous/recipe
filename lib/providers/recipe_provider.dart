import 'package:flutter/foundation.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class RecipeProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Recipe> _recipes = [];
  List<Recipe> _savedRecipes = [];
  bool _isLoading = false;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get savedRecipes => _savedRecipes;
  bool get isLoading => _isLoading;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getRecipes();
      _recipes = response.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching recipes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSavedRecipes() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.getSavedRecipes();
      _savedRecipes = response.map((json) => Recipe.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching saved recipes: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createRecipe(Recipe recipe) async {
    try {
      await _apiService.createRecipe(recipe.toJson());
      await fetchRecipes(); // Refresh the recipe list
    } catch (e) {
      print('Error creating recipe: $e');
      rethrow;
    }
  }

  Future<void> saveRecipe(int recipeId) async {
    try {
      await _apiService.saveRecipe(recipeId);
      await fetchSavedRecipes(); // Refresh saved recipes
    } catch (e) {
      print('Error saving recipe: $e');
      rethrow;
    }
  }

  Future<void> removeSavedRecipe(int recipeId) async {
    try {
      await _apiService.removeSavedRecipe(recipeId);
      await fetchSavedRecipes(); // Refresh saved recipes
    } catch (e) {
      print('Error removing saved recipe: $e');
      rethrow;
    }
  }
} 