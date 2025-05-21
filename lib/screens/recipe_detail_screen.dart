// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../providers/comment_provider.dart';
import '../services/api_service.dart';

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
      final result = await api.saveRecipe(widget.recipeId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Recipe saved!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save recipe')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 300,
            pinned: true,
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
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            child: Text(comment.username[0]),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            comment.username,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(comment.content),
                                      const SizedBox(height: 4),
                                      Text(
                                        comment.createdAt.toString(),
                                        style: Theme.of(context).textTheme.bodySmall,
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
                onPressed: () async {
                  final content = commentCtrl.text.trim();
                  if (content.isEmpty) return;
                  try {
                    await Provider.of<CommentProvider>(context, listen: false)
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