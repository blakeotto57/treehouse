import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class ReviewsPage extends StatefulWidget {
  final String sellerId;

  const ReviewsPage({super.key, required this.sellerId});

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final currentUserEmail = FirebaseAuth.instance.currentUser?.email ?? '';
  bool hasReviewed = false;

  @override
  void initState() {
    super.initState();
    checkIfUserReviewed();
  }

  Future<void> checkIfUserReviewed() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("sellers")
        .doc(widget.sellerId)
        .collection("reviews")
        .where('reviewerName', isEqualTo: currentUserEmail)
        .get();

    setState(() {
      hasReviewed = snapshot.docs.isNotEmpty;
    });
  }

  void hideFabAfterSubmission() {
    setState(() {
      hasReviewed = true;
    });
  }

  void deleteReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection("sellers")
          .doc(widget.sellerId)
          .collection("reviews")
          .doc(reviewId)
          .delete();

      setState(() {
        hasReviewed = false; // Allow the FAB to reappear
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete review. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("sellers")
              .doc(widget.sellerId)
              .collection("reviews")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('Seller Reviews');
            }

            final reviews = snapshot.data!.docs;

            double totalRating = 0.0;
            int reviewCount = reviews.length;

            for (var review in reviews) {
              totalRating += (review['rating'] ?? 0) as double;
            }

            double averageRating = totalRating / reviewCount;

            return Text(
              '${widget.sellerId}  (Avg: ${averageRating.toStringAsFixed(0)}/5)',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
        backgroundColor: const Color(0xFF305d42),

        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerId)
            .collection("reviews")
            .orderBy('timestamp', descending: true)
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
              final review = reviews[index];
              final reviewData = review.data() as Map<String, dynamic>;
              final reviewId = review.id;
              final reviewerName = reviewData['reviewerName'] ?? 'Anonymous';
              final comment = reviewData['comment'] ?? 'No comment provided.';
              final rating = reviewData['rating'] ?? 0;

              return Card(
                color:  Theme.of(context).colorScheme.primary,
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text(
                    reviewerName.split('@')[0],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(comment),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${rating.toStringAsFixed(0)}/5',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (reviewerName == currentUserEmail)
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Review'),
                                content: const Text(
                                    'Are you sure you want to delete your review?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      deleteReview(reviewId);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: (widget.sellerId == currentUserEmail || hasReviewed)
          ? null // Hide FAB if the current user is viewing their own review page or has already reviewed
          : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ReviewDialog(
                      sellerId: widget.sellerId,
                      onReviewSubmitted: hideFabAfterSubmission,
                    );
                  },
                );
              },
              child: const Icon(Icons.add),
              backgroundColor: const Color(0xFF305d42),
            ),
    );
  }
}

class ReviewDialog extends StatefulWidget {
  final String sellerId;
  final VoidCallback onReviewSubmitted;

  const ReviewDialog({
    super.key,
    required this.sellerId,
    required this.onReviewSubmitted,
  });

  @override
  _ReviewDialogState createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<ReviewDialog> {
  final _commentController = TextEditingController();
  double _rating = 0.0;

  void _submitReview() async {
    if (_commentController.text.isNotEmpty && _rating > 0) {
      String reviewerName = FirebaseAuth.instance.currentUser?.email ?? 'Anonymous';

      try {
        await FirebaseFirestore.instance
            .collection("sellers")
            .doc(widget.sellerId)
            .collection("reviews")
            .add({
          'reviewerName': reviewerName,
          'comment': _commentController.text,
          'rating': _rating,
          'timestamp': FieldValue.serverTimestamp(),
        });

        widget.onReviewSubmitted(); // Notify parent to hide the FAB
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit review. Try again.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and provide a rating')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return AlertDialog(
      title: const Text('Add a Review'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(hintText: 'Your Review'),
              maxLines: null,
              maxLength: 100,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
            ),
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    iconSize: 30,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _submitReview,
              child: Text(
                'Submit Review',
                style: TextStyle(color: textColor),
                
              ),
            ),
          ],
        ),
      ),
    );
  }
}
