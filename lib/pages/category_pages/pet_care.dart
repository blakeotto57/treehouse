import 'package:flutter/material.dart';

class PetCarePage extends StatelessWidget {
  const PetCarePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Care Page'),
      ),
      body: Center(
        child: Text('Welcome to My New Page!'),
      ),
    );
  }
}
