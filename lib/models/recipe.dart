class Recipe {
  final int id;
  final String title;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int difficulty;
  final int? userId;
  final String? username;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
    this.userId,
    this.username, required String description,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'],
      title: json['title'],
      ingredients: json['ingredients'],
      instructions: json['instructions'],
      cookingTime: json['cooking_time'],
      difficulty: json['difficulty'],
      userId: json['user_id'],
      username: json['username'],
      description: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'ingredients': ingredients,
      'instructions': instructions,
      'cooking_time': cookingTime,
      'difficulty': difficulty,
      'user_id': userId,
      'username': username,
    };
  }
}
