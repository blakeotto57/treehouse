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


  //send messages
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _firebaseAuth.currentUser!.uid!;
    final String currentUserEmail = _firebaseAuth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();


    // create a new message
    Message newMessage = Message(
      senderID: currentUserEmail,
      senderEmail: currentUserID,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
    );


    //construct chat room ID for the 2 users
    List<String> ids = [currentUserEmail, receiverID];
    ids.sort();// sorts the id's to make sure the chatroom is the same for both people
    String chatRoomID = ids.join("_");

    //creates particiapnts section in firebase
    final chatRoomRef = _fireStore.collection("chat_rooms").doc(chatRoomID);

    await chatRoomRef.set({
    "participants": ids, // Add participants to the chat room
     }, SetOptions(merge: true)); // Merge to avoid overwriting existing data


    // add new message to database
    await _fireStore
      .collection("chat_rooms")
      .doc(chatRoomID)
      .collection("messages")
      .doc(timestamp.toDate().toIso8601String()) //title of doc of each message is time it was sent
      .set(newMessage.toMap());
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
}