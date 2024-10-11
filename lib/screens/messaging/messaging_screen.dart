// lib/screens/messaging/messaging_screen.dart
import 'package:flutter/material.dart';
import '../../models/message.dart';
import '../../services/messaging_service.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class MessagingScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;

  MessagingScreen({required this.chatId, required this.receiverId});

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _controller = TextEditingController();
  final MessagingService _messagingService = MessagingService();

  void _sendMessage() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    String content = _controller.text.trim();
    if (content.isNotEmpty && authService.currentUser != null) {
      await _messagingService.sendMessage(
        widget.chatId,
        content,
        authService.currentUser!.uid,
        widget.receiverId,
      );
      _controller.clear();
      // No need to manually fetch messages; StreamBuilder handles it
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _messagingService.getMessages(
                widget.chatId,
                authService.currentUser!.uid,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading messages.'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No messages yet.'));
                } else {
                  List<Message> messages = snapshot.data!;
                  return ListView.builder(
                    reverse: true, // To display latest messages at the bottom
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      bool isMe = message.senderId ==
                          Provider.of<AuthService>(context, listen: false)
                              .currentUser!
                              .uid;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color:
                                isMe ? Colors.blueAccent : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.content,
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}