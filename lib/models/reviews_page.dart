import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewsPage extends StatefulWidget {
  final String username;

  const ReviewsPage({super.key, required this.username});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  bool hasReviewed = false;
  String? sellerEmail;

  @override
  void initState() {
    super.initState();
    fetchSellerEmail();
  }

  Future<void> fetchSellerEmail() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: widget.username)
        .limit(1)
        .get();
    if (userSnapshot.docs.isNotEmpty) {
      setState(() {
        sellerEmail = userSnapshot.docs.first['email'];
      });
      checkIfUserReviewed();
    }
  }

  Future<void> checkIfUserReviewed() async {
    if (sellerEmail == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(sellerEmail)
        .collection('reviews')
        .where('reviewer', isEqualTo: currentUserEmail)
        .get();
    setState(() {
      hasReviewed = snapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (sellerEmail == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username}\'s Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(sellerEmail)
            .collection('reviews')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No reviews yet.'));
          }
          final reviews = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index].data() as Map<String, dynamic>;
              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(review['reviewer'] ?? 'Anonymous'),
                subtitle: Text(review['text'] ?? ''),
                trailing: review['rating'] != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          review['rating'],
                          (i) => const Icon(Icons.star, color: Colors.amber, size: 18),
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
      floatingActionButton: !hasReviewed && currentUserEmail != sellerEmail
          ? FloatingActionButton(
              onPressed: () {
                // Show add review dialog or page
              },
              child: const Icon(Icons.add),
              tooltip: 'Add Review',
            )
          : null,
    );
  }
}
