import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../services/api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String token;

  RecipeDetailScreen({required this.recipeId, required this.token});

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final api = ApiService();
  final commentCtrl = TextEditingController();
  late Future<Recipe?> recipe;
  late Future<List<Comment>> comments;

  void loadData() {
    recipe = api.fetchRecipeById(widget.token, widget.recipeId);
    comments = api.fetchComments(widget.token, widget.recipeId).then(
            (list) => list.map((json) => Comment.fromJson(json)).toList());
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Деталі рецепта')),
    body: FutureBuilder<Recipe?>(
      future: recipe,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());
        if (!snapshot.hasData)
          return Center(child: Text('Рецепт не знайдено'));

        final recipe = snapshot.data!;
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                children: [
                  Text(recipe.title,
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Інгредієнти:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(recipe.ingredients),
                  SizedBox(height: 10),
                  Text('Приготування:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(recipe.instructions),
                  SizedBox(height: 10),
                  Text('Час приготування: ${recipe.cookingTime} хв'),
                  Text('Складність: ${recipe.difficulty}/5'),
                  Divider(),
                  Text('Коментарі:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  FutureBuilder<List<Comment>>(
                    future: comments,
                    builder: (context, snapComments) {
                      if (snapComments.connectionState == ConnectionState.waiting)
                        return Center(child: CircularProgressIndicator());
                      if (!snapComments.hasData || snapComments.data!.isEmpty)
                        return Text('Коментарі відсутні');

                      return Column(
                        children: snapComments.data!
                            .map((comment) => ListTile(
                          title: Text(comment.user.name,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(comment.content),
                        ))
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentCtrl,
                      decoration: InputDecoration(hintText: 'Додати коментар'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () async {
                      bool success = await api.addComment(
                          widget.token, widget.recipeId, commentCtrl.text);
                      if (success) {
                        commentCtrl.clear();
                        setState(() => loadData());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Помилка при додаванні коментаря')));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );
}
