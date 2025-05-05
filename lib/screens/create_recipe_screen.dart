import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CreateRecipeScreen extends StatefulWidget {
  final String token;
  CreateRecipeScreen({required this.token});

  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final titleCtrl = TextEditingController();
  final ingredientsCtrl = TextEditingController();
  final instructionsCtrl = TextEditingController();
  final cookingTimeCtrl = TextEditingController();
  int difficulty = 1;

  final api = ApiService();

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Новий рецепт')),
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
              decoration:
              InputDecoration(labelText: 'Час приготування (хв)'),
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
            child: Text('Опублікувати рецепт'),
            onPressed: () async {
              bool success = await api.createRecipe(
                widget.token,
                titleCtrl.text,
                ingredientsCtrl.text,
                instructionsCtrl.text,
                int.tryParse(cookingTimeCtrl.text) ?? 10,
                difficulty,
              );

              if (success) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Помилка створення рецепта')),
                );
              }
            },
          )
        ],
      ),
    ),
  );
}
