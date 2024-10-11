// lib/screens/messaging/conversations_screen.dart
import 'package:flutter/material.dart';
import '../../models/conversation.dart';
import '../../services/messaging_service.dart';
import 'messaging_screen.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class ConversationsScreen extends StatefulWidget {
  @override
  _ConversationsScreenState createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  final MessagingService _messagingService = MessagingService();
  List<Conversation> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  void _fetchConversations() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      List<Conversation> conversations =
          await _messagingService.getConversations(authService.currentUser!.uid);
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load conversations.';
        _isLoading = false;
      });
      print('ConversationsScreen: Error fetching conversations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _conversations.isEmpty
                  ? Center(child: Text('No conversations yet.'))
                  : ListView.builder(
                      itemCount: _conversations.length,
                      itemBuilder: (context, index) {
                        final conversation = _conversations[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: conversation.receiverAvatarUrl.isNotEmpty
                                ? NetworkImage(conversation.receiverAvatarUrl)
                                : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                            backgroundColor: Colors.grey[300],
                          ),
                          title: Text(conversation.receiverName),
                          subtitle: Text(conversation.lastMessage),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MessagingScreen(
                                  chatId: conversation.chatId,
                                  receiverId: conversation.receiverId,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}