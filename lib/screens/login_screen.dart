import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final api = ApiService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Вхід')),
    body: Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email')),
          TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: 'Пароль')),
          ElevatedButton(
            child: Text('Увійти'),
            onPressed: () async {
              final response = await api.login(emailCtrl.text, passCtrl.text);
              String? token = response['access_token'];
              if (token != null) {
                // ignore: use_build_context_synchronously
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
              }
            },
          ),
          TextButton(
            child: Text('Ще немає акаунта? Зареєструватись'),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
          )
        ],
      ),
    ),
  );
}
