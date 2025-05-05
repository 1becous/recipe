import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/recipe.dart';
import '../models/user.dart';

class ApiService {
  static const baseUrl = 'https://recipeapp-zljw.onrender.com';

  Future<String?> login(String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}));

    if (res.statusCode == 200) {
      return jsonDecode(res.body)['access_token'];
    }
    return null;
  }

  Future<bool> register(String name, String email, String password) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/register'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "email": email, "password": password}));

    return res.statusCode == 200;
  }

  Future<List<dynamic>> fetchRecipes(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/recipes'),
        headers: {"Authorization": "Bearer $token"});

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
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
  Future<bool> createRecipe(
      String token,
      String title,
      String ingredients,
      String instructions,
      int cookingTime,
      int difficulty) async {
    final res = await http.post(Uri.parse('$baseUrl/recipes/'),
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
        }));

    return res.statusCode == 200;
  }
// Додати коментар до рецепта
  Future<bool> addComment(String token, int recipeId, String content) async {
    final res = await http.post(Uri.parse('$baseUrl/comments/'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"recipe_id": recipeId, "content": content}));

    return res.statusCode == 200;
  }

// Отримати всі коментарі для рецепта
  Future<List<dynamic>> fetchComments(String token, int recipeId) async {
    final res = await http.get(Uri.parse('$baseUrl/comments/recipe/$recipeId'),
        headers: {"Authorization": "Bearer $token"});

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }
    return [];
  }

}
