import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recipe.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000'; // Change this to your API URL
  
  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      body: {
        'username': email,
        'password': password,
      },
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> register(String email, String password, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      body: {
        'email': email,
        'password': password,
        'username': username,
      },
    );
    return json.decode(response.body);
  }

  // Recipes endpoints
  Future<List<dynamic>> getRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getRecipe(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> recipe) async {
    final response = await http.post(
      Uri.parse('$baseUrl/recipes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(recipe),
    );
    return json.decode(response.body);
  }

  // Saved Recipes endpoints
  Future<List<dynamic>> getSavedRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/saved-recipes'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> saveRecipe(int recipeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/saved-recipes'),
      body: {'recipe_id': recipeId.toString()},
    );
    return json.decode(response.body);
  }

  // Ratings endpoints
  Future<Map<String, dynamic>> rateRecipe(int recipeId, double rating) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ratings'),
      body: {
        'recipe_id': recipeId.toString(),
        'rating': rating.toString(),
      },
    );
    return json.decode(response.body);
  }

  // Comments endpoints
  Future<List<dynamic>> getComments(int recipeId) async {
    final response = await http.get(Uri.parse('$baseUrl/comments/$recipeId'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> addComment(int recipeId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      body: {
        'recipe_id': recipeId.toString(),
        'content': content,
      },
    );
    return json.decode(response.body);
  }

  // отримати поточного користувача
  Future<User?> fetchCurrentUser(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/users/me'),
        headers: {"Authorization": "Bearer $token"});

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  // отримати один рецепт
  Future<Recipe?> fetchRecipeById(String token, int id) async {
    final res = await http.get(Uri.parse('$baseUrl/recipes/$id'),
        headers: {"Authorization": "Bearer $token"});

    if (res.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  // Delete a recipe by ID
  Future<bool> deleteRecipe(String token, int recipeId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/recipes/$recipeId'),
      headers: {"Authorization": "Bearer $token"},
    );

    return res.statusCode == 200;
  }

  // Edit an existing recipe
  Future<bool> editRecipe(
    String token,
    int recipeId,
    String title,
    String ingredients,
    String instructions,
    int cookingTime,
    int difficulty,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/recipes/$recipeId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "title": title,
        "ingredients": ingredients,
        "instructions": instructions,
        "cooking_time": cookingTime,
        "difficulty": difficulty,
      }),
    );

    return res.statusCode == 200;
  }

  // Get all ratings for a recipe
  Future<List<dynamic>> fetchRecipeRatings(String token, int recipeId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/ratings/recipe/$recipeId'),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // Get all ratings by a user
  Future<List<dynamic>> fetchUserRatings(String token, int userId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/ratings/user/$userId'),
      headers: {"Authorization": "Bearer $token"},
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

  // Delete a rating by ID
  Future<bool> deleteRating(String token, int ratingId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/ratings/$ratingId'),
      headers: {"Authorization": "Bearer $token"},
    );
    return res.statusCode == 200;
  }
}
