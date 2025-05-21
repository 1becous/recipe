import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/recipe.dart';

class EditRecipeScreen extends StatefulWidget {
  final String token;
  final Recipe recipe;

  const EditRecipeScreen({super.key, required this.token, required this.recipe});

  @override
  // ignore: library_private_types_in_public_api
  _EditRecipeScreenState createState() => _EditRecipeScreenState();
}

class _EditRecipeScreenState extends State<EditRecipeScreen> {
  final titleCtrl = TextEditingController();
  final ingredientsCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();
  final cookingTimeCtrl = TextEditingController();
  late int difficulty;

  final api = ApiService();

  @override
  void initState() {
    super.initState();
    // Pre-fill the form with existing recipe data
    titleCtrl.text = widget.recipe.title;
    ingredientsCtrl.text = widget.recipe.ingredients;
    instructionsCtrl.text = widget.recipe.instructions;
    cookingTimeCtrl.text = widget.recipe.cookingTime.toString();
    difficulty = widget.recipe.difficulty;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Редагувати рецепт')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          TextField(
              controller: titleCtrl,
              decoration: InputDecoration(labelText: 'Назва')),
          TextField(
              controller: ingredientsCtrl,
              decoration: InputDecoration(labelText: 'Інгредієнти')),
          TextField(
              controller: instructionsCtrl,
              decoration: InputDecoration(labelText: 'Інструкція'),
              maxLines: 4),
          TextField(
              controller: cookingTimeCtrl,
              decoration: InputDecoration(labelText: 'Час приготування (хв)'),
              keyboardType: TextInputType.number),
          SizedBox(height: 10),
          Text('Складність: $difficulty'),
          Slider(
            value: difficulty.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: difficulty.toString(),
            onChanged: (val) {
              setState(() {
                difficulty = val.toInt();
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            child: Text('Зберегти зміни'),
            onPressed: () async {
              bool success = await api.editRecipe(
                widget.token,
                widget.recipe.id,
                titleCtrl.text,
                ingredientsCtrl.text,
                instructionsCtrl.text,
                int.tryParse(cookingTimeCtrl.text) ?? 10,
                difficulty,
              );

              if (success) {
                // ignore: use_build_context_synchronously
                Navigator.pop(context, true); // Return true to indicate success
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка оновлення рецепта')),
                );
              }
            },
          )
        ],
      ),
    ),
  );
} 