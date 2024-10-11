   // lib/models/conversation.dart
   import 'package:cloud_firestore/cloud_firestore.dart';

   class Conversation {
     final String chatId;
     final String receiverId;
     final String receiverName;
     final String receiverAvatarUrl;
     final String lastMessage;

     Conversation({
       required this.chatId,
       required this.receiverId,
       required this.receiverName,
       required this.receiverAvatarUrl,
       required this.lastMessage,
     });

     factory Conversation.fromDocument(DocumentSnapshot doc) {
       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
       return Conversation(
         chatId: doc.id,
         receiverId: data['receiverId'] ?? '',
         receiverName: data['receiverName'] ?? '',
         receiverAvatarUrl: data['receiverAvatarUrl'] ?? '',
         lastMessage: data['lastMessage'] ?? '',
       );
     }
   }