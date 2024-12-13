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
            .collection("sellers") // Access the sellers collection
            .doc(sellerId) // Access the specific seller document
            .collection("reviews") // Access the reviews subcollection for this seller
            .orderBy('timestamp', descending: true) // Order by timestamp
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
              final reviewData = reviews[index].data() as Map<String, dynamic>;
              final reviewerName = reviewData['reviewerName'] ?? 'Anonymous';
              final comment = reviewData['comment'] ?? 'No comment provided.';
              final rating = reviewData['rating'] ?? 0;

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    reviewerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(comment),
                  trailing: Text(
                    '$rating/5',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Show a dialog to add a review
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return ReviewDialog(sellerId: sellerId);
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.green[300],
      ),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final String sellerId;

  const ReviewDialog({super.key, required this.sellerId});

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _reviewerNameController = TextEditingController();
  final _commentController = TextEditingController();
  double _rating = 0.0;

  void _submitReview() async {
    if (_reviewerNameController.text.isNotEmpty && _commentController.text.isNotEmpty && _rating > 0) {
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerId) // Access the specific seller
          .collection("reviews") // Access the reviews subcollection for this seller
          .add({
        'reviewerName': _reviewerNameController.text,
        'comment': _commentController.text,
        'rating': _rating,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Close the dialog
    } else {
      // Show a message if the review is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and provide a rating')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a Review'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _reviewerNameController,
              decoration: const InputDecoration(labelText: 'Your Name'),
            ),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Your Comment'),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _submitReview,
              child: const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }
}
