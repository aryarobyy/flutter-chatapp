import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/widget/text_field.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String recieverId;
  const ChatPage({super.key, required this.recieverId});

  @override
  State<ChatPage> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthMethod _auth = AuthMethod();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void handleSendChat() async {
    if (messageController.text.isNotEmpty) {
      await _chatService.sendChat(widget.recieverId, messageController.text);
      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _auth.getCurrentUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(
              title: _profileUser(context, widget.recieverId),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: _profileUser(context, widget.recieverId),
            ),
            body: const Center(
              child: Text("Error fetching user information"),
            ),
          );
        }

        final currentUserId = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: _profileUser(context, widget.recieverId),
          ),
          body: Column(
            children: [
              Expanded(child: _bubbleChat(context, currentUserId)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: MyTextField(
                        controller: messageController,
                        hintText: "Type a message...",
                        obscureText: false,
                      ),
                    ),
                    IconButton(
                      onPressed: handleSendChat,
                      icon: const Icon(Icons.send),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bubbleChat(BuildContext context, String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getChats(currentUserId, widget.recieverId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }
        if (!snapshot.hasData) {
          return const Center(child: Text("No messages yet"));
        }
        print("Data: ${snapshot}");
        print("Current userId: ${widget.recieverId}");
        final messages = snapshot.data!.docs;

        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isSender = message['senderId'] == currentUserId;

            bool isLatest(List messages, int index) {
              if (index >= messages.length - 1) return true;
              final currentMsg = messages[index].data() as Map<String, dynamic>;
              final nextMsg = messages[index + 1].data() as Map<String, dynamic>;
              return currentMsg['senderId'] != nextMsg['senderId'];
            }

            return BubbleSpecialThree(
              text: message['chat'] ?? "",
              color: isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
              tail: isLatest(messages, index),
              isSender: isSender,
              textStyle: TextStyle(
                color: isSender ? Colors.white : Colors.black,
                fontSize: 16,
              ),
            );
          },
        );
      },
    );
  }

  Widget _profileUser(BuildContext context, String recieverId) {
    final recieverId = widget.recieverId;

    return StreamBuilder(
        stream: _auth.getUserById(recieverId!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading user profile"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No user found"));
          }

          final user = snapshot.data!;
          return Row(
            children: [
              CircleAvatar(
                backgroundImage: user.imageUrl.isNotEmpty
                    ? NetworkImage(user.imageUrl)
                    : AssetImage("assets/images/user1.jpg")
                as ImageProvider,
                radius: 20,
              ),
              SizedBox(width: 20,),
              Text(user.name?? ""),
            ],
          );
        },
    );
  }
}
