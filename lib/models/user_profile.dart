import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'package:treehouse/models/seller_setup.dart'; // Import SellerSetupPage

class SellerProfilePage extends StatelessWidget {
  final String sellerId;
  final String currentUserId;

  const SellerProfilePage({
    required this.sellerId,
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Profile'),
        actions: sellerId == currentUserId
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () async {
                    try {
                      final chatRoomId = await _getOrCreateChatRoom();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            currentUserId: currentUserId, 
                            chatRoomId: chatRoomId, 
                            recipientId: sellerId,
                          ),
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  },
                ),
              ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('sellers').doc(sellerId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Seller profile not found.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SellerSetupPage(),
                        ),
                      );
                    },
                    child: const Text('Become a Seller'),
                  ),
                ],
              ),
            );
          }

          final sellerData = snapshot.data!.data() as Map<String, dynamic>?;

          if (sellerData == null) {
            return const Center(child: Text('No seller data available.'));
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: sellerData['profilePicture'] != null
                        ? NetworkImage(sellerData['profilePicture'])
                        : null,
                    child: sellerData['profilePicture'] == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  sellerData['name'] ?? 'No Name Provided',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text('About the Seller:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(sellerData['description'] ?? 'No Description Provided', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 16),
                const Text('Past Work:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                sellerData['workImages'] != null && (sellerData['workImages'] as List).isNotEmpty
                    ? Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (sellerData['workImages'] as List)
                            .map((imageUrl) => ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(imageUrl, width: 100, height: 100, fit: BoxFit.cover),
                                ))
                            .toList(),
                      )
                    : const Text('No images uploaded yet.'),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<String> _getOrCreateChatRoom() async {
    final chatRoomCollection = FirebaseFirestore.instance.collection('chats');

    final existingChat = await chatRoomCollection
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in existingChat.docs) {
      final participants = doc.data()['participants'] as List;
      if (participants.contains(sellerId)) {
        return doc.id; // Return existing chat room ID
      }
    }

    final sellerSnapshot = await FirebaseFirestore.instance.collection('sellers').doc(sellerId).get();
    final customerSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserId).get();

    final sellerName = sellerSnapshot.exists && sellerSnapshot.data() != null ? sellerSnapshot.data()!['name'] ?? sellerId : sellerId;
    final customerName = customerSnapshot.exists && customerSnapshot.data() != null ? customerSnapshot.data()!['name'] ?? currentUserId : currentUserId;

    final newChat = await chatRoomCollection.add({
      'participants': [currentUserId, sellerId],
      'participantNames': {
        currentUserId: customerName,
        sellerId: sellerName,
      },
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }
}
