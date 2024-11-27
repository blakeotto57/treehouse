import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/auth/auth.dart';
import 'package:treehouse/components.dart/text_box.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  // User
  final currentUser = FirebaseAuth.instance.currentUser!;

  //all users
  final usersCollection = FirebaseFirestore.instance.collection("users");



  // Edit field for username
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          "Edit $field" ,
          style: const TextStyle(
            color: Colors.white,
            ),
          ),
          content: TextField(
            autofocus: true,
            style: TextStyle(
              color: Colors.white),
              decoration: InputDecoration(
                hintText: "Enter new $field",
                hintStyle: TextStyle(color: Colors.grey),   
            ),
            onChanged: (value) {
              newValue = value;
            },
          ),
          actions: [

          //cancel button for edit field
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(
              "Cancel", 
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),


          //save button
          TextButton(
            onPressed: () => Navigator.of(context).pop(newValue), 
            child: Text(
              "Save", 
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    ); 

    //update edits of profile in Firebase
    if (newValue.trim().length > 0) {
      await usersCollection.doc(currentUser.uid).update({field: newValue});
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: const Text("Seller Profile"),
        backgroundColor: Colors.green[200],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(currentUser.uid)
            .snapshots(),

        builder: (context, snapshot) {
          
          // Get user data
          if (snapshot.hasData && snapshot.data?.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 25),

                // Profile picture
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      size: 72,
                    ),
                  ),
                ),

                // Space between
                const SizedBox(height: 50),

                // User email
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    currentUser.email!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),

                // User details header
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "My Details",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Username section
                MyTextBox(
                  text: userData['username'],
                  sectionName: "Username", //text in textfield
                  onPressed: () => editField("username"),
                ),

                // Bio section
                MyTextBox(
                  text: userData['bio'],
                  sectionName: "Bio", //text in textfield
                  onPressed: () => editField("bio"),
                ),

                // Space between
                const SizedBox(height: 25),


      
              ],
            );

            
          } else if (snapshot.hasError) {
            return AuthPage();
            
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
