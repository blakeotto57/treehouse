import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/reviews_page.dart';
import 'package:treehouse/payment/pay.dart';
import 'package:treehouse/stripe/stripe_service.dart';
import 'package:pay/pay.dart';
import 'package:treehouse/payment/configurations_pay.dart';
import '../pages/chat_page.dart';

class OtherUsersProfilePage extends StatefulWidget {
  final String userId;

  const OtherUsersProfilePage({super.key, required this.userId});

  @override
  State<OtherUsersProfilePage> createState() => _OtherUsersProfilePageState();
}

class _OtherUsersProfilePageState extends State<OtherUsersProfilePage> {
  final sellersCollection = FirebaseFirestore.instance.collection("sellers");
  final usersCollection = FirebaseFirestore.instance.collection("users");
  final currentUser = FirebaseAuth.instance.currentUser; // Add this line

  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();

  final List<PaymentItem> _paymentItems = [
    PaymentItem(
      label: 'Total',
      amount: '99.99',
      status: PaymentItemStatus.final_price,
    )
  ];

  void onApplePayResult(paymentResult) {
    debugPrint('Apple Payment result: $paymentResult');
    // Handle Apple Pay result
  }

  void onGooglePayResult(paymentResult) {
    debugPrint('Google Payment result: $paymentResult');
    // Handle Google Pay result
  }

  Future<String> createOrGetChatRoom(
      String currentUserEmail, String otherUserEmail) async {
    // Sort emails to ensure consistent room ID
    final List<String> emails = [currentUserEmail, otherUserEmail];
    emails.sort();
    final String chatRoomId = emails.join('_');

    // Check if room exists
    final chatRoomRef =
        FirebaseFirestore.instance.collection('chat_rooms').doc(chatRoomId);
    final chatRoom = await chatRoomRef.get();

    // Create room if it doesn't exist
    if (!chatRoom.exists) {
      await chatRoomRef.set({
        'participants': [currentUserEmail, otherUserEmail],
        'created_at': FieldValue.serverTimestamp(),
        'last_message': '',
        'last_message_time': FieldValue.serverTimestamp()
      });
    }

    return chatRoomId;
  }

  @override
  Widget build(BuildContext context) {
    // Add check for current user
    final isOwnProfile = currentUser?.email == widget.userId;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "${widget.userId}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[800],
        elevation: 2,
        actions: [
          // Only show message icon if not viewing own profile
          if (!isOwnProfile)
            IconButton(
              icon: const Icon(
                Icons.message,
                color: Colors.white,
                ),
              onPressed: () async {
                try {
                  final currentUser = FirebaseAuth.instance.currentUser!;
                  final chatRoomId = await createOrGetChatRoom(
                      currentUser.email!, widget.userId);

                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverEmail: widget.userId,
                        receiverID: widget.userId,
                      ),
                    ),
                  );
                } catch (e) {
                  print('Error creating/getting chat room: $e');
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error opening chat')),
                  );
                }
              },
            ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: sellersCollection.doc(widget.userId).snapshots(),
        builder: (context, sellerSnapshot) {
          if (sellerSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sellerSnapshot.hasError) {
            return const Center(child: Text("Error loading data"));
          }

          final sellerData =
              sellerSnapshot.data?.data() as Map<String, dynamic>?;

          return FutureBuilder<DocumentSnapshot>(
            future: usersCollection
                .where("email", isEqualTo: sellerData?['email'])
                .limit(1)
                .get()
                .then((snapshot) => snapshot.docs.isNotEmpty
                    ? snapshot.docs.first
                    : throw Exception('No user found')),
            builder: (context, userSnapshot) {
              String? profileImageUrl;

              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasData && userSnapshot.data != null) {
                final userData =
                    userSnapshot.data!.data() as Map<String, dynamic>;
                profileImageUrl = userData['profileImageUrl'];
              }

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.green[800],
                      backgroundImage: profileImageUrl != null
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null
                          ? const Icon(
                              Icons.person,
                              size: 80,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.userId,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('sellers')
                          .doc(widget.userId)
                          .get(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.amber,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ReviewsPage(sellerId: widget.userId),
                                    ),
                                  );
                                },
                                child: const Text(
                                  "Reviews",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              TextButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    barrierDismissible:
                                        true, // Allow tapping outside to dismiss
                                    builder: (context) {
                                      return SingleChildScrollView(
                                        child: AlertDialog(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text("Payment Details"),
                                              InkWell(
                                                onTap: () =>
                                                    Navigator.pop(context),
                                                child: const Icon(Icons.close,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          content: Container(
                                            height: 200,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextField(
                                                  controller: _amountController,
                                                  decoration:
                                                      const InputDecoration(
                                                    icon: Icon(
                                                        Icons.attach_money),
                                                    labelText: "Amount to Pay",
                                                    labelStyle: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                ),
                                                TextField(
                                                  controller: _reasonController,
                                                  decoration:
                                                      const InputDecoration(
                                                    icon:
                                                        Icon(Icons.description),
                                                    labelText:
                                                        "What's this for?",
                                                    labelStyle: TextStyle(
                                                        color: Colors.grey),
                                                  ),
                                                ),

                                                const SizedBox(height: 20),

                                                // Payment buttons
                                                ApplePayButton(
                                                  paymentConfiguration:
                                                      defaultApplePayConfig,
                                                  paymentItems: _paymentItems,
                                                  type: ApplePayButtonType.buy,
                                                  onPaymentResult:
                                                      onApplePayResult,
                                                  loadingIndicator:
                                                      const Center(
                                                    child:
                                                        CircularProgressIndicator(),
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                Container(
                                                  width: double.infinity,
                                                  height: 50,
                                                  child: GooglePayButton(
                                                    paymentConfiguration:
                                                        defaultGooglePayConfig,
                                                    paymentItems: _paymentItems,
                                                    type:
                                                        GooglePayButtonType.pay,
                                                    onPaymentResult:
                                                        onGooglePayResult,
                                                    loadingIndicator:
                                                        const Center(
                                                      child:
                                                          CircularProgressIndicator(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ).then((_) {
                                    _amountController.clear();
                                    _reasonController.clear();
                                  });
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.all(16),
                                ),
                                child: const Text("Pay"),
                              ),
                            ],
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    StreamBuilder<DocumentSnapshot>(
                      stream: usersCollection.doc(widget.userId).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data != null) {
                          final userData =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          final bio = userData?['bio'] ?? 'No bio available';

                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.2)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bio',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  bio,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: textColor.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
