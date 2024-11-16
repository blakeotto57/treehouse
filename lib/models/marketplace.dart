import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Marketplace extends StatelessWidget {
  final String dateToday = DateTime.now().toString().split(' ')[0]; // Get current date in YYYY-MM-DD format

  final List<String> categories = ["Electronics", "Furniture", "Clothing", "Toys", "Sports", "Books"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Promotions'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Date header
            Text(
              'Promotions for $dateToday',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for products or sellers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),

            // Featured Sellers (Horizontal Scrollable from Firestore)
            const Text(
              'Featured Sellers',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('sellers').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final sellers = snapshot.data?.docs ?? [];

                  if (sellers.isEmpty) {
                    return const Center(child: Text('No featured sellers available.'));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: sellers.length,
                    itemBuilder: (context, index) {
                      final sellerData = sellers[index].data() as Map<String, dynamic>;
                      final seller = Seller(
                        name: sellerData['name'] ?? 'No Name',
                        goods: sellerData['goods'] ?? 'No Goods',
                        promotionText: sellerData['promotionText'] ?? 'No Promotion',
                        imageUrl: sellerData['imageUrl'] ?? 'https://via.placeholder.com/150',
                      );
                      return PromotionCard(seller: seller);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Placeholder List of Promotions (Vertical Scrollable)
            const Text(
              'Today’s Promotions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            const Center(child: Text('Promotions will be listed here.')), // Replace with actual logic
          ],
        ),
      ),
    );
  }
}

class Seller {
  final String name;
  final String goods;
  final String promotionText;
  final String imageUrl;

  Seller({required this.name, required this.goods, required this.promotionText, required this.imageUrl});
}

class PromotionCard extends StatelessWidget {
  final Seller seller;

  const PromotionCard({required this.seller});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Image for the seller's goods
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                seller.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            // Seller information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  seller.goods,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  seller.promotionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
