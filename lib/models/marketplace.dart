import 'package:flutter/material.dart';

class Marketplace extends StatelessWidget {
  final String dateToday = DateTime.now().toString().split(' ')[0]; // Get current date in YYYY-MM-DD format

  final List<Seller> sellers = [
    Seller(name: "John", goods: "Personal Care", promotionText: "Selling croissants today", imageUrl: "https://via.placeholder.com/150"),
    Seller(name: "Sahittya", goods: "Cock Care", promotionText: "Free cock care at 4pm!", imageUrl: "https://via.placeholder.com/150"),
    Seller(name: "Mateo", goods: "fortnie", promotionText: "Selling battlepass at McHenry from 8am-3pm", imageUrl: "https://via.placeholder.com/150"),
  ];

  final List<String> categories = ["Electronics", "Furniture", "Clothing", "Toys", "Sports", "Books"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore Promotions'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Date header
            Text(
              'Promotions for $dateToday',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 20),

            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for products or sellers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            SizedBox(height: 20),
            // Featured Sellers (Horizontal Scrollable)
            Text(
              'Featured Sellers',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sellers.length,
                itemBuilder: (context, index) {
                  return PromotionCard(seller: sellers[index]);
                },
              ),
            ),
            SizedBox(height: 20),

            // List of Promotions (Vertical Scrollable)
            Text(
              'Today’s Promotions',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: sellers.length,
              itemBuilder: (context, index) {
                return PromotionCard(seller: sellers[index]);
              },
            ),
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
      margin: EdgeInsets.only(right: 16),
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
            SizedBox(width: 16),
            // Seller information
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seller.name,
                  style: TextStyle(
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
                SizedBox(height: 8),
                Text(
                  seller.promotionText,
                  style: TextStyle(
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
