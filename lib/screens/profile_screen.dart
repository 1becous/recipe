import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class ProfileScreen extends StatelessWidget {
  final String token;
  final api = ApiService();

  ProfileScreen({required this.token});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Мій профіль')),
    body: FutureBuilder<User?>(
      future: api.fetchCurrentUser(token),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

        if (!snapshot.hasData)
          return Center(child: Text('Помилка завантаження профілю'));

        final user = snapshot.data!;
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ім\'я:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user.name, style: TextStyle(fontSize: 20)),
              SizedBox(height: 15),
              Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(user.email, style: TextStyle(fontSize: 18)),
            ],
          ),
        );
      },
    ),
  );
}
