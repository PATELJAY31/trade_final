// lib/services/messaging_service.dart
import '../models/message.dart';
import '../models/conversation.dart';
import 'database_service.dart';

class MessagingService {
  final DatabaseService _databaseService = DatabaseService();

  // Generate a unique chat ID between two users
  String getChatId(String userId1, String userId2) {
    return userId1.hashCode <= userId2.hashCode
        ? '$userId1\_$userId2'
        : '$userId2\_$userId1';
  }

  // Send a message
  Future<void> sendMessage(
      String chatId, String content, String senderId, String receiverId) async {
    await _databaseService.sendMessage(chatId, content, senderId, receiverId);
  }

  // Get messages stream
  Stream<List<Message>> getMessages(String chatId, String currentUserId) {
    return _databaseService.getMessages(chatId, currentUserId);
  }

  // Get conversations for a user
  Future<List<Conversation>> getConversations(String userId) async {
    return await _databaseService.getConversations(userId);
  }
}