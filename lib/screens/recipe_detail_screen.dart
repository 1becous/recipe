// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../models/rating.dart';
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
  late Future<List<Rating>> ratings;
  int? userRatingId;
  int? userRatingValue;
  int? userId;

  void loadData() {
    recipe = api.fetchRecipeById(widget.token, widget.recipeId);
    comments = api.getComments(widget.recipeId).then(
      (list) => list.map((json) => Comment.fromJson(json)).toList());
    ratings = api.fetchRecipeRatings(widget.token, widget.recipeId).then(
      (list) => list.map((json) => Rating.fromJson(json)).toList(),
    );
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Recipe Title', // Replace with actual title
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 20),
                                const SizedBox(width: 4),
                                Text('30 min'), // Replace with actual time
                                const SizedBox(width: 16),
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                Text('4.5'), // Replace with actual rating
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          // Save recipe
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
                      child: Column(
                        children: [
                          // Replace with actual ingredients
                          _buildIngredientItem('Ingredient 1', '100g'),
                          _buildIngredientItem('Ingredient 2', '2 tbsp'),
                          _buildIngredientItem('Ingredient 3', '1 cup'),
                        ],
                      ),
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
                      child: Column(
                        children: [
                          // Replace with actual instructions
                          _buildInstructionStep(1, 'First step of the recipe'),
                          _buildInstructionStep(2, 'Second step of the recipe'),
                          _buildInstructionStep(3, 'Third step of the recipe'),
                        ],
                      ),
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
                  // Add comment
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredientItem(String name, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name),
          Text(
            amount,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int number, String instruction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(instruction),
          ),
        ],
      ),
    );
  }
}
