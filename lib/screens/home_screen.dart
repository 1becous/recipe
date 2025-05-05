import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/recipe.dart';
import 'saved_recipes_screen.dart';
import 'recipe_detail_screen.dart';
import 'profile_screen.dart';
import 'create_recipe_screen.dart';

class HomeScreen extends StatefulWidget {
  final String token;
  HomeScreen({required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final api = ApiService();
  late Future<List<Recipe>> recipes;

  @override
  void initState() {
    super.initState();
    recipes = fetchRecipes();
  }

  Future<List<Recipe>> fetchRecipes() {
    return api
        .fetchRecipes(widget.token)
        .then((list) => list.map((json) => Recipe.fromJson(json)).toList());
  }

  Future<void> refreshRecipes() async {
    setState(() {
      recipes = fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Рецепти'),
      actions: [
        IconButton(
          icon: Icon(Icons.person),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ProfileScreen(token: widget.token))),
        ),
        IconButton(
          icon: Icon(Icons.bookmark),
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SavedRecipesScreen())),
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: refreshRecipes,
      child: FutureBuilder<List<Recipe>>(
        future: recipes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return ListView(
              children: [Center(child: Text('Рецепти відсутні'))],
            );
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (_, index) {
              final recipe = snapshot.data![index];
              return ListTile(
                title: Text(recipe.title),
                subtitle: Text('Час: ${recipe.cookingTime} хв'),
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => RecipeDetailScreen(
                            recipeId: recipe.id, token: widget.token))),
              );
            },
          );
        },
      ),
    ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add),
      onPressed: () async {
        await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CreateRecipeScreen(token: widget.token)));
        refreshRecipes(); // Оновлюємо після повернення
      },
    ),
  );
}
