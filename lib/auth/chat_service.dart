import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:treehouse/models/message.dart';


class ChatService {
  //get instance of firestore and auth
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;


  //get user stream
  //map is the field in fire store like 
  // email: botto@ucsc.edu, name: "blake"
  Stream<List<Map<String,dynamic>>> getUsersStream() {
    return _fireStore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {

        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();

    });
  }


    // Fetch users in chat rooms with the current user
    Future<List<Map<String, dynamic>>> getUsersInChatRooms() async {
      final String currentUserEmail = _firebaseAuth.currentUser!.email!;

      // Query chat rooms where the current user is a participant
      final chatRoomsQuery = await _fireStore
          .collection("chat_rooms")
          .where("participants", arrayContains: currentUserEmail)
          .get();

      // Extract the other participants' emails
      final otherEmails = chatRoomsQuery.docs.expand((doc) {
        final participants = List<String>.from(doc["participants"] ?? []);
        return participants.where((id) => id != currentUserEmail);
      }).toSet();

      // Fetch user data for these emails
      final userData = await Future.wait(otherEmails.map((email) async {
        final userQuery = await _fireStore
            .collection("users")
            .where("email", isEqualTo: email)
            .get();
        return userQuery.docs.first.data();
      }));

      return userData;
    }

  // In chat_service.dart
  Stream<List<Map<String, dynamic>>> getAcceptedUsersInChatRooms() async* {
    final String currentUserEmail = _firebaseAuth.currentUser!.email!;
    
    // Get accepted users
    final acceptedUsersStream = _fireStore
        .collection('accepted_chats')
        .doc(currentUserEmail)
        .collection('users')
        .snapshots();

    await for (final snapshot in acceptedUsersStream) {
      final acceptedEmails = snapshot.docs.map((doc) => doc['email'] as String).toSet();
      
      if (acceptedEmails.isEmpty) {
        yield [];
        continue;
      }

      // Get user data for accepted emails
      final userDocs = await Future.wait(
        acceptedEmails.map((email) => _fireStore
            .collection('users')
            .where('email', isEqualTo: email)
            .get()
            .then((snap) => snap.docs.first.data())),
      );

      yield userDocs;
    }
  }

  // Get accepted chat users
  Stream<List<Map<String, dynamic>>> getAcceptedChatsStream() async* {
  final currentUserEmail = FirebaseAuth.instance.currentUser!.email!;
  final chatsStream = FirebaseFirestore.instance.collection('chats').snapshots();

  await for (final snapshot in chatsStream) {
    final List<Map<String, dynamic>> results = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final participants = doc.id.split('_');
      final otherUserEmail = participants.firstWhere(
        (email) => email != currentUserEmail,
        orElse: () => 'Unknown',
      );

      // Skip if this chat doesn't involve current user
      if (!participants.contains(currentUserEmail)) continue;

      // Fetch the other user's info from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(otherUserEmail)
          .get();

      final userData = userDoc.data() ?? {};

      results.add({
        'email': otherUserEmail,
        'username': userData['username'] ?? otherUserEmail,
        'profileImageUrl': userData['profileImageUrl'],
        'lastMessage': data['lastMessage'] ?? {},
      });
    }

    yield results;
  }
}



  //send messages
  Future<void> sendMessage(String receiverID, String message, {String? imageUrl}) async {
    final currentUserEmail = _firebaseAuth.currentUser!.email!;
    final timestamp = Timestamp.now();

    // First ensure users are in each other's accepted chats
    await FirebaseFirestore.instance.batch()
      ..set(
        _fireStore
          .collection('accepted_chats')
          .doc(currentUserEmail)
          .collection('users')
          .doc(receiverID),
        {'email': receiverID, 'timestamp': timestamp}
      )
      ..set(
        _fireStore
          .collection('accepted_chats')
          .doc(receiverID)
          .collection('users')
          .doc(currentUserEmail),
        {'email': currentUserEmail, 'timestamp': timestamp}
      )
      ..commit();

    // Create message
    Message newMessage = Message(
      senderID: currentUserEmail,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      imageUrl: imageUrl, // Add this field to your Message model
    );

    // Construct chat room ID
    List<String> ids = [currentUserEmail, receiverID];
    ids.sort();
    String chatRoomID = ids.join("_");

    // Add message to chat room
    await _fireStore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .add(newMessage.toMap());
  }


  //get message
  Stream<QuerySnapshot> getMessages(String senderId, otherUserId) {
    //construct a chatroom ID for both users
    List<String> ids = [senderId, otherUserId];
    ids.sort();
    String chatRoomID = ids.join("_");

    return _fireStore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .orderBy("timestamp", descending: false)
      .snapshots();
  }

  // Send a message request (if not accepted yet)
  Future<void> sendMessageRequest(String receiverEmail, String message, {String? imageUrl}) async {
    final currentUserEmail = _firebaseAuth.currentUser!.email!;
    final timestamp = Timestamp.now();
    Message newMessage = Message(
      senderID: currentUserEmail,
      senderEmail: currentUserEmail,
      receiverID: receiverEmail,
      message: message,
      timestamp: timestamp,
      imageUrl: imageUrl,
    );
    await _fireStore
      .collection('message_requests')
      .doc(receiverEmail)
      .collection('users')
      .doc(currentUserEmail)
      .collection('messages')
      .add(newMessage.toMap());
  }

  // Stream all message requests for the current user
  Stream<List<Map<String, dynamic>>> getMessageRequestsStream() {
    final currentUserEmail = _firebaseAuth.currentUser!.email!;
    return _fireStore
      .collection('message_requests')
      .doc(currentUserEmail)
      .collection('users')
      .snapshots()
      .asyncMap((usersSnapshot) async {
        List<Map<String, dynamic>> requests = [];
        for (var userDoc in usersSnapshot.docs) {
          final senderEmail = userDoc.id;
          final messagesSnapshot = await _fireStore
            .collection('message_requests')
            .doc(currentUserEmail)
            .collection('users')
            .doc(senderEmail)
            .collection('messages')
            .orderBy('timestamp', descending: false)
            .get();
          final userInfoSnap = await _fireStore
            .collection('users')
            .where('email', isEqualTo: senderEmail)
            .get();
          final userInfo = userInfoSnap.docs.isNotEmpty ? userInfoSnap.docs.first.data() : {"email": senderEmail};
          requests.add({
            'email': senderEmail,
            'userInfo': userInfo,
            'messages': messagesSnapshot.docs.map((m) => m.data()).toList(),
          });
        }
        return requests;
      });
  }

  // Accept a message request: move messages to chat and add to accepted_chats
  Future<void> acceptMessageRequest(String senderEmail) async {
    final currentUserEmail = _firebaseAuth.currentUser!.email!;
    final batch = _fireStore.batch();
    final chatId = [currentUserEmail, senderEmail]..sort();
    final chatIdStr = chatId.join('_');
    final messagesRef = _fireStore
      .collection('message_requests')
      .doc(currentUserEmail)
      .collection('users')
      .doc(senderEmail)
      .collection('messages');
    final messagesSnapshot = await messagesRef.get();
    // Move each message to chats
    for (var doc in messagesSnapshot.docs) {
      batch.set(
        _fireStore.collection('chats').doc(chatIdStr).collection('messages').doc(),
        doc.data(),
      );
    }
    // Add both users to accepted_chats
    batch.set(
      _fireStore.collection('accepted_chats').doc(currentUserEmail).collection('users').doc(senderEmail),
      {'email': senderEmail, 'timestamp': Timestamp.now()},
    );
    batch.set(
      _fireStore.collection('accepted_chats').doc(senderEmail).collection('users').doc(currentUserEmail),
      {'email': currentUserEmail, 'timestamp': Timestamp.now()},
    );
    // Delete the message request
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_fireStore.collection('message_requests').doc(currentUserEmail).collection('users').doc(senderEmail));
    await batch.commit();
  }

  // Reject a message request: remove all pending messages and the user
  Future<void> rejectMessageRequest(String senderEmail) async {
    final currentUserEmail = _firebaseAuth.currentUser!.email!;
    final batch = _fireStore.batch();
    final messagesRef = _fireStore
      .collection('message_requests')
      .doc(currentUserEmail)
      .collection('users')
      .doc(senderEmail)
      .collection('messages');
    final messagesSnapshot = await messagesRef.get();
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_fireStore.collection('message_requests').doc(currentUserEmail).collection('users').doc(senderEmail));
    await batch.commit();
  }
}