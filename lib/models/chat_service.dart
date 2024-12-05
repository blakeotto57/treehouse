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

  //send messages
  Future<void> sendMessage(String receiverID, message) async {
    // get current user info
    final String currentUserID = _firebaseAuth.currentUser!.uid;
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
    List<String> ids = [currentUserID, receiverID];
    ids.sort();// sorts the id's to make sure the chatroom is the same for both people
    String chatRoomID = ids.join("_");

    // add new message to database
    await _fireStore
    .collection("chat_rooms")
    .doc(chatRoomID)
    .collection("messages")
    .add(newMessage.toMap());
  }


  //get message
  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    //construct a chatroom ID for both users
    List<String> ids = [userId, otherUserId];
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