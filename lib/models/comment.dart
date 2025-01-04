import 'dart:convert';

class Comment {
  final String id;
  final String text;
  final String user;
  final DateTime timestamp;
  final String senderProfileImageUrl;
  final List likes;
  final List comments;




  Comment({
    required this.id,
    required this.text,
    required this.user,
    required this.timestamp,
    required this.senderProfileImageUrl,
    required this.likes,
    required this.comments,
  });


  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': text,
      'senderName': user,
      'id': id,
      'senderProfileImageUrl': senderProfileImageUrl,
      'timestamp': timestamp,
      'likes': likes,
      'comments': comments
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] as String,
      user: map['senderName'] as String,
      senderProfileImageUrl: map['senderProfileImageUrl'] as String,
      text: map['message'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      likes: List.from((map['likes'] as List)),
      comments: List.from((map['comments'] as List)),
    );
  }

  String toJson() => json.encode(toMap());

  factory Comment.fromJson(String source) =>
      Comment.fromMap(json.decode(source) as Map<String, dynamic>);

  factory Comment.empty() {
    return Comment(
        id: '',
        user: '',
        senderProfileImageUrl: '',
        text: '',
        timestamp: DateTime.now(),
        likes: [],
        comments: []);
  }
}


