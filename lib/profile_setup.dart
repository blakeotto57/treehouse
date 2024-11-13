import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  _ProfileSetupPageState createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  


  //list of inputed user variables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();




  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();



      //list of inputed user variables
      await prefs.setString('userName', _nameController.text); //Username is the variable name of whetever the user inputed
      await prefs.setString('password', _passwordController.text); //Username is the variable name of whetever the user inputed




      // Ensure route exists and navigate to home
      if (mounted) { //if username is successful then go to the home page
        Navigator.pushReplacementNamed(context, '/home'); 
      }
    } catch (e) { //if username is not successful then do that
      // Handle potential error
      print("Error saving profile: $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose(); // Dispose controller when done
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hi, Welcome to Treehouse.")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Entering your username
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Please enter your name'),
            ),

            //Entering your password
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Please enter a password'),
              ),
            ),



            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              child: Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}
