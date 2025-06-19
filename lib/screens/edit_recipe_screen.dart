import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../services/api_service.dart';

class EditRecipeScreen extends StatefulWidget {
  final Recipe recipe;
  final String token;

  const EditRecipeScreen({
    super.key,
    required this.recipe,
    required this.token,
  });

  @override
  State<EditRecipeScreen> createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _cookingTimeController = TextEditingController();
  int _difficulty = 1;
  final api = ApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing recipe data
    _titleController.text = widget.recipe.title;
    _ingredientsController.text = widget.recipe.ingredients;
    _instructionsController.text = widget.recipe.instructions;
    _cookingTimeController.text = widget.recipe.cookingTime.toString();
    _difficulty = widget.recipe.difficulty;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _cookingTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedRecipe = Recipe(
        id: widget.recipe.id,
        title: _titleController.text,
        ingredients: _ingredientsController.text,
        instructions: _instructionsController.text,
        cookingTime: int.parse(_cookingTimeController.text),
        difficulty: _difficulty,
        userId: widget.recipe.userId,
        username: widget.recipe.username, description: '',
      );

      await api.editRecipe(
        widget.token,
        updatedRecipe.id,
        updatedRecipe.title,
        updatedRecipe.ingredients,
        updatedRecipe.instructions,
        updatedRecipe.cookingTime,
        updatedRecipe.difficulty,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate successful update
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update recipe')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Recipe'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveRecipe,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ingredientsController,
                decoration: const InputDecoration(
                  labelText: 'Ingredients',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter ingredients';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter instructions';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cookingTimeController,
                decoration: const InputDecoration(
                  labelText: 'Cooking Time (minutes)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cooking time';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Easy')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('Hard')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _difficulty = value;
                    });
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