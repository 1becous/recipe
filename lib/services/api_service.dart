import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/comment.dart';
import '../models/recipe.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl = 'https://diplom-recipe-app-0efe2d79f24e.herokuapp.com'; // Change this to your API URL
  
  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
          'email': email,
          'password': password,
        }),
    );
    final data = json.decode(response.body);
    final token = data['access_token'];
    await SharedPreferences.getInstance().then((prefs) {
      prefs.setString('token', token);
    });
    return data;
  }

  Future<Map<String, dynamic>> register(String email, String password, String username) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': username,
      }),
    );
    return json.decode(response.body);
  }

  // Recipes endpoints
  Future<List<dynamic>> getRecipes() async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> getRecipe(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/recipes/$id'));
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> createRecipe(Map<String, dynamic> recipe) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('$baseUrl/recipes/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',  // ← Ось це головне
      },
      body: json.encode(recipe),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create recipe: ${response.statusCode}\n${response.body}');
    }
  }

  // Saved Recipes endpoints
  Future<List<dynamic>> getSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('$baseUrl/saved-recipes'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> saveRecipe(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.post(
      Uri.parse('$baseUrl/saved-recipes/$recipeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return json.decode(response.body);
  }

  Future<bool> removeSavedRecipe(int recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final response = await http.delete(
      Uri.parse('$baseUrl/saved-recipes/$recipeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response.statusCode == 204;
  }

  // Comments endpoints
  Future<List<Comment>> getComments(int recipeId) async {
    final url = Uri.parse('$baseUrl/comments/recipe/$recipeId');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data
            .map((e) => Comment.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    throw Exception(
        'Unexpected response ${response.statusCode}: ${response.body}');
  }


  Future<Comment> addComment(int recipeId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final url = Uri.parse('$baseUrl/comments/');

    final payload = {
      'content': content,
      'recipe_id': recipeId,
    };

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return Comment.fromJson(map);
    }

    throw Exception(
        'Failed to post comment ${response.statusCode}: ${response.body}');
  }
  // отримати поточного користувача
  Future<User?> fetchCurrentUser(String token) async {
    final res = await http.get(Uri.parse('$baseUrl/users/me/'),
        headers: {"Authorization": "Bearer $token"});

    if (res.statusCode == 200) {
      return User.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  // отримати один рецепт
  Future<Recipe?> fetchRecipeById(String token, int id) async {
    final res = await http.get(Uri.parse('$baseUrl/recipes/$id/'),
        headers: {"Authorization": "Bearer $token"});

    if (res.statusCode == 200) {
      return Recipe.fromJson(jsonDecode(res.body));
    }
    return null;
  }

  // Delete a recipe by ID
  Future<bool> deleteRecipe(String token, int recipeId) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/recipes/$recipeId/'),
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
      Uri.parse('$baseUrl/recipes/$recipeId/'),
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
}