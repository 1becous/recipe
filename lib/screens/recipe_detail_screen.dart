// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/recipe.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import 'edit_recipe_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;
  final String token;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
    required this.token,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final api = ApiService();
  Recipe? recipe;
  List<Comment> comments = [];
  int? currentUserId;
  final TextEditingController _commentCtrl = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => isLoading = true);
    try {
      // 1) Fetch recipe details
      recipe = await api.fetchRecipeById(widget.token, widget.recipeId);

      // 2) Fetch current user
      final user = await api.fetchCurrentUser(widget.token);
      currentUserId = user?.id;

      // 3) Fetch comments (with embedded user)
      comments = await api.getComments(widget.recipeId);
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    try {
      final newComment = await api.addComment(widget.recipeId, text);
      setState(() {
        comments.insert(0, newComment);
        _commentCtrl.clear();
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Comment added!')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to add comment: $e')));
    }
  }

  void _saveRecipe() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Recipe saved!')));
  }

  void _shareRecipe(Recipe recipe) {
    final shareText = '''\${recipe.title}

Cooking Time: \${recipe.cookingTime} minutes

Ingredients:
\${recipe.ingredients}

Instructions:
\${recipe.instructions}
''';
    Share.share(shareText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : recipe == null
          ? const Center(child: Text('Recipe not found'))
          : CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 300,
            pinned: true,
            actions: [
              if (recipe!.userId == currentUserId) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditRecipeScreen(
                          recipe: recipe!,
                          token: widget.token,
                        ),
                      ),
                    );
                    if (result == true) _loadAllData();
                  },
                ),
              ],
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.restaurant, size: 100),
                  ),
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
                              recipe!.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer, size: 20),
                                const SizedBox(width: 4),
                                Text('${recipe!.cookingTime} min'),
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
                        onPressed: () => _shareRecipe(recipe!),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Ingredients',
                      style:
                      Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(recipe!.ingredients),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Instructions',
                      style:
                      Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(recipe!.instructions),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text('Comments',
                      style:
                      Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  if (comments.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text('No comments yet'),
                      ),
                    )
                  else
                    ...comments.map((c) => Card(
                      margin:
                      const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.user.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(c.content),
                          ],
                        ),
                      ),
                    )),
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
                  controller: _commentCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
