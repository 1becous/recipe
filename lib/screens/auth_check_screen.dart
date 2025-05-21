import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class AuthCheckScreen extends StatelessWidget {
  const AuthCheckScreen({super.key});

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == true) {
          return FutureBuilder<String?>(
            future: SharedPreferences.getInstance().then((prefs) => prefs.getString('token')),
            builder: (context, tokenSnapshot) {
              if (!tokenSnapshot.hasData) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return HomeScreen(token: tokenSnapshot.data!);
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
} 