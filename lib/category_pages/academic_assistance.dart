import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:treehouse/models/seller_profile.dart';

String? globaluserid;


class AcademicAssistanceSellersPage extends StatefulWidget {
  const AcademicAssistanceSellersPage({Key? key}) : super(key: key);

  @override
  State<AcademicAssistanceSellersPage> createState() => _AcademicAssistanceSellersPageState();
}

class _AcademicAssistanceSellersPageState extends State<AcademicAssistanceSellersPage> {
  late Stream<QuerySnapshot> _sellersStream;

  @override
  void initState() {
    super.initState();
    _sellersStream = FirebaseFirestore.instance
        .collection('sellers')
        .where('category', isEqualTo: 'Academic Assistance') // Updated to Academic Assistance
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Assistance Sellers'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _sellersStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No sellers found in this category.'));
          }

          final sellers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index].data() as Map<String, dynamic>;
              final userId = sellers[index].id;

              return Card(
                margin: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: seller['profilePicture'] != null
                        ? NetworkImage(seller['profilePicture'])
                        : null,
                    child: seller['profilePicture'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    seller['name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(seller['description'] ?? 'No description provided.'),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to seller profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SellerProfilePage(
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
