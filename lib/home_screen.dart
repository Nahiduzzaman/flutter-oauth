// File: lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:oauth_app/auth_service.dart';
import 'package:oauth_app/router.gr.dart';

@RoutePage()
class HomeScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: ElevatedButton(
          child: Text('Logout'),
          onPressed: () async {
            await _authService.clearTokens();
            context.router.push(const LogoutRoute());
            // Navigation to login page will be handled by deep link
          },
        ),
      ),
    );
  }
}
