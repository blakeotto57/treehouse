import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PresenceService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Set user as online
  Future<void> setOnline() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    
    await _firestore.collection('users').doc(user.email!).update({
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
  
  // Set user as offline
  Future<void> setOffline() async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return;
    
    await _firestore.collection('users').doc(user.email!).update({
      'isOnline': false,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
  
  // Get online status stream for a user
  Stream<bool> getUserOnlineStatus(String userEmail) {
    return _firestore
        .collection('users')
        .doc(userEmail)
        .snapshots()
        .map((doc) => doc.data()?['isOnline'] ?? false);
  }
  
  // Get online status for a user (one-time)
  Future<bool> getUserOnlineStatusOnce(String userEmail) async {
    final doc = await _firestore.collection('users').doc(userEmail).get();
    return doc.data()?['isOnline'] ?? false;
  }
}

