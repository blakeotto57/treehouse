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
          style: TextStyle(color: textColor),
        ),
        centerTitle: true,
        backgroundColor: Colors.green[300],
        elevation: 2,
        actions: [
          // Only show message icon if not viewing own profile
          if (!isOwnProfile)
            IconButton(
              icon: const Icon(Icons.message),
              onPressed: () async {
                try {
                  final currentUserEmail = FirebaseAuth.instance.currentUser?.email;
                  if (currentUserEmail == null) return;

                  // Create pending message request
                  await FirebaseFirestore.instance
                      .collection('pending_messages')
                      .doc(widget.userId) // Receiver's email
                      .collection('requests')
                      .doc(currentUserEmail) // Sender's email as document ID
                      .set({
                    'senderEmail': currentUserEmail,
                    'message': 'Hi! I would like to chat with you.',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message request sent!')),
                  );

                } catch (e) {
                  print('Error sending message request: $e');
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
                      backgroundColor: Colors.green[300],
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
                      stream: FirebaseFirestore.instance
                          .collection('sellers')
                          .doc(widget.userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        return Center( // Wrap entire content
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (snapshot.hasData && snapshot.data!.exists)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Previous Work",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        sellerData?['workImages'] != null
                                            ? SizedBox(
                                                height: 150,
                                                child: ListView.builder(
                                                  scrollDirection: Axis.horizontal,
                                                  itemCount: (sellerData?['workImages']
                                                          as List)
                                                      .length,
                                                  itemBuilder: (context, index) {
                                                    return Container(
                                                      margin: const EdgeInsets.only(
                                                          right: 10),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(8),
                                                        child: Image.network(
                                                          sellerData?['workImages']
                                                              [index],
                                                          height: 150,
                                                          width: 150,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              )
                                            : const Text(
                                                "No previous work available.",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54),
                                              ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
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
