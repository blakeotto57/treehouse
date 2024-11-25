import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/components.dart/text_box.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(
        title: Text("Seller Profile"),
        backgroundColor: Colors.green[200],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 25),

          // Profile picture
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: Align(
              alignment: Alignment.center,
              child: const Icon(
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
            child: 
              Text(
                currentUser.email!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            

          // User details
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: 
                Text(
                  "My Details",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // Username section
          MyTextBox(
            text: "User Bio",
            sectionName: "username",
          )
        ],
      ),
    );
  }
}
