import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final Timestamp timestamp;
  final bool isMe;

  Message({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    required this.isMe,
  });

  // Factory constructor to create a Message from Firestore data
  factory Message.fromDocument(DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      isMe: data['senderId'] == currentUserId,
    );
  }

  // Method to convert Message to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp,
    };
  }
}