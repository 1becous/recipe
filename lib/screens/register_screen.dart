import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class RegisterScreen extends StatelessWidget {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final api = ApiService();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Реєстрація')),
    body: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Ім\'я')),
          TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Пароль')),
          ElevatedButton(
            child: Text('Зареєструватись'),
            onPressed: () async {
              final response = await api.register(nameCtrl.text, emailCtrl.text, passCtrl.text);
              bool success = response['success'] == true || response['status'] == 'ok';
              if (success) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
              }
            },
          ),
        ],
      ),
    ),
  );
}
