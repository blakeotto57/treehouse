import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsPage extends StatelessWidget {
  final String sellerId;

  const ReviewsPage({super.key, required this.sellerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Reviews'),
        backgroundColor: Colors.green[300],
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .where('sellerId', isEqualTo: sellerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No reviews available for this seller.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    review['reviewerName'] ?? 'Anonymous',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(review['comment'] ?? 'No comment provided.'),
                  trailing: Text(
                    '${review['rating'] ?? 0}/5',
                    style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
