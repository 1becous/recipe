class Recipe {
  final int id;
  final String title;
  final String ingredients;
  final String instructions;
  final int cookingTime;
  final int difficulty;

  Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['id'],
    title: json['title'],
    ingredients: json['ingredients'],
    instructions: json['instructions'],
    cookingTime: json['cooking_time'],
    difficulty: json['difficulty'],
  );
}
