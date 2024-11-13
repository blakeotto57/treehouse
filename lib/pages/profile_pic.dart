import 'package:flutter/material.dart';

class ProfilePicPage extends StatelessWidget {
  const ProfilePicPage({super.key});

  void _selectFromLibrary() {
    // Placeholder action for selecting an image from the library
    print('Select from Library tapped!');
  }

  void _useDefaultColors() {
    // Placeholder action for using default colors as the profile picture
    print('Use Default Colors tapped!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile Picture Options',
          style: TextStyle(
            color: Colors.yellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _selectFromLibrary,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Updated from primary to backgroundColor
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Select from Library'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _useDefaultColors,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Updated from primary to backgroundColor
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Use Default Colors as Profile Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
