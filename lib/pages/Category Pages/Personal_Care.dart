import 'package:flutter/material.dart';

class PersonalCarePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Personal Care')),
      body: Center(
        child: Text(
          'Welcome to the Personal Care Page!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
