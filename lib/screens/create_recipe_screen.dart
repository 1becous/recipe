import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipeapp/screens/home_screen.dart';
import '../models/recipe.dart';
import '../providers/recipe_provider.dart';

class CreateRecipeScreen extends StatefulWidget {
  final Recipe? recipe; // If provided, we're editing an existing recipe

  const CreateRecipeScreen({super.key, this.recipe});

  @override
  State<CreateRecipeScreen> createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  int _cookingTime = 30;
  int _difficulty = 3;

  @override
  void initState() {
    super.initState();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _ingredientsController.text = widget.recipe!.ingredients;
      _instructionsController.text = widget.recipe!.instructions;
      _cookingTime = widget.recipe!.cookingTime;
      _difficulty = widget.recipe!.difficulty;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe == null ? 'Create Recipe' : 'Edit Recipe'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title',
                hintText: 'Enter the name of your recipe',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cooking Time',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _cookingTime.toDouble(),
                            min: 5,
                            max: 180,
                            divisions: 35,
                            label: '$_cookingTime minutes',
                            onChanged: (value) {
                              setState(() {
                                _cookingTime = value.round();
                              });
                            },
                          ),
                        ),
                        Text(
                          '$_cookingTime min',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difficulty Level',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _difficulty
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              _difficulty = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ingredientsController,
              decoration: const InputDecoration(
                labelText: 'Ingredients',
                hintText: 'Enter ingredients (one per line)',
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
                hintText: 'Enter step-by-step instructions',
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(widget.recipe == null ? 'Create Recipe' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final recipe = Recipe(
        id: widget.recipe?.id ?? 0,
        title: _titleController.text,
        ingredients: _ingredientsController.text,
        instructions: _instructionsController.text,
        cookingTime: _cookingTime,
        difficulty: _difficulty, description: '',
      );

      if (widget.recipe == null) {
        context.read<RecipeProvider>().createRecipe(recipe);
      } else {
      }

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    }
  }
}
