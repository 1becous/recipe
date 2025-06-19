// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../services/api_service.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String token;

  const RecipeDetailScreen({super.key, required this.recipeId, required this.token});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final api = ApiService();
  final commentCtrl = TextEditingController();
  late Future<Recipe?> recipe;
  late Future<List<Comment>> comments;
  int? userId;

  void loadData() {
    recipe = api.fetchRecipeById(widget.token, widget.recipeId);
    comments = api.getComments(widget.recipeId).then(
      (list) => list.map((json) => Comment.fromJson(json)).toList());
    // Fetch user id for rating logic
    api.fetchCurrentUser(widget.token).then((user) {
      setState(() {
        userId = user?.id;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      context.read<CommentProvider>().fetchComments(widget.recipeId);
      // Fetch recipe details
    });
  }

  void _saveRecipe() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save recipe')),
      );
    }
  }

  void _shareRecipe(Recipe recipe) {
    final shareText = '''
${recipe.title}

Cooking Time: ${recipe.cookingTime} minutes

Ingredients:
${recipe.ingredients}

Instructions:
${recipe.instructions}
''';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 300,
            pinned: true,
            actions: [
              FutureBuilder<Recipe?>(
                future: recipe,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data?.userId == userId) {
                    return IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRecipeScreen(
                              recipe: snapshot.data!,
                              token: widget.token,
                            ),
                          ),
                        );
                        if (result == true) {
                          // Refresh the recipe data
                          setState(() {
                            loadData();
                          });
                        }
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for recipe image
                  Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 100),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<Recipe?>(
                future: recipe,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return const Center(child: Text('Recipe not found'));
                  }
                  final recipe = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recipe.title,
                                  style: Theme.of(context).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.timer, size: 20),
                                    const SizedBox(width: 4),
                                    Text('${recipe.cookingTime} min'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.favorite_border),
                            onPressed: _saveRecipe,
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {
                              _shareRecipe(recipe);

                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Ingredients',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(recipe.ingredients),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(recipe.instructions),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Author',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            (recipe.username == null || recipe.username!.isEmpty)
                                ? 'Anon'
                                : recipe.username!,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),

                      // Comments section
                      const SizedBox(height: 24),
                      Text(
                        'Comments',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Consumer<CommentProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (provider.comments.isEmpty) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No comments yet'),
                              ),
                            );
                          }

                          return Column(
                            children: provider.comments.map((comment) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            comment.user.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(comment.content),
                                          const SizedBox(height: 4),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  final content = commentCtrl.text.trim();
                  if (content.isEmpty) return;
                  try {
                    Provider.of<CommentProvider>(context, listen: false)
                        .addComment(widget.recipeId, content);
                    commentCtrl.clear();
                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Comment added!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to add comment')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}