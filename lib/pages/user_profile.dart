import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool isEditing = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  Color profilePictureColor = Colors.black; // Default color for profile picture

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the widget is initialized
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('userName') ?? 'John Doe';
      bioController.text = prefs.getString('userBio') ?? 'A UCSC student passionate about sharing skills!';
      // Load saved color for profile picture
      String? colorString = prefs.getString('profilePictureColor');
      if (colorString != null) {
        profilePictureColor = Color(int.parse(colorString));
      }
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', nameController.text);
    await prefs.setString('userBio', bioController.text);
    await prefs.setString('profilePictureColor', profilePictureColor.value.toString());
  }

  void _changeProfilePictureColor() {
    // Show a dialog to let the user pick a color
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose a Color'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                ColorOption(Colors.black, onSelect: _updateProfilePictureColor),
                ColorOption(Colors.red, onSelect: _updateProfilePictureColor),
                ColorOption(Colors.blue, onSelect: _updateProfilePictureColor),
                ColorOption(Colors.green, onSelect: _updateProfilePictureColor),
                ColorOption(Colors.yellow, onSelect: _updateProfilePictureColor),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateProfilePictureColor(Color color) {
    setState(() {
      profilePictureColor = color;
      _saveUserData(); // Save the selected color
    });
    Navigator.pop(context); // Close the color picker dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Profile",
          style: TextStyle(
            color: Color.fromARGB(255, 174, 90, 65),
            fontSize: 30,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black,
              )
            ],
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 106, 145, 87),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Picture Section
            Center(
              child: GestureDetector(
                onTap: _changeProfilePictureColor,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: profilePictureColor,
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Name and Bio
            isEditing
                ? TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    autofocus: true,
                  )
                : Center(
                    child: Text(
                      nameController.text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            const SizedBox(height: 8),
            isEditing
                ? TextFormField(
                    controller: bioController,
                    decoration: InputDecoration(labelText: 'Bio'),
                    maxLines: 3,
                  )
                : Center(
                    child: Text(
                      bioController.text,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
            const SizedBox(height: 24),

            // Edit Profile Button
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  if (isEditing) {
                    _saveUserData(); // Save data when exiting editing mode
                  }
                  isEditing = !isEditing;
                });
              },
              icon: Icon(isEditing ? Icons.save : Icons.edit),
              label: Text(isEditing ? 'Save Changes' : 'Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
              ),
            ),
            if (isEditing)
              TextButton(
                onPressed: () {
                  setState(() {
                    isEditing = false; // Exit editing mode without saving changes
                  });
                },
                child: Text('Cancel'),
              ),
          ],
        ),
      ),
    );
  }
}

class ColorOption extends StatelessWidget {
  final Color color;
  final Function(Color) onSelect;

  ColorOption(this.color, {required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onSelect(color),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black, width: 1),
        ),
      ),
    );
  }
}