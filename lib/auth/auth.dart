import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/auth/login_or_register.dart';
import 'package:treehouse/pages/home.dart';


class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {

          //when user logged in go to home page
          if (snapshot.hasData) {
            return const HomePage();

          //user is not logged in return to login or register page
          } else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}