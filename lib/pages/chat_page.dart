import 'package:chat_app/model/chat_model.dart';
import 'package:chat_app/service/auth/authentication.dart';
import 'package:chat_app/service/chat_service.dart';
import 'package:chat_app/widget/bubble_chat.dart';
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

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
  }

  Future<void> _initializeCurrentUser() async {
    try {
      currentUserId = await _auth.getCurrentUserId();
      setState(() {});
    } catch (e) {
      debugPrint("Error fetching current user ID: $e");
    }
  }

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
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Chat"),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
      ),
      body: Column(
        children: [
          Expanded(child: _bubbleChat(context)),
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
  }

  Widget _bubbleChat(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chatService.getChats(currentUserId!, widget.recieverId),
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

        final messages = snapshot.data!.docs;

        // return ListView(
        //   children: snapshot.data!.docs.map((doc) => _buildChatIem(doc)).toList(),
        // );
        return ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isSender = message['senderId'] == currentUserId;

            return BubbleSpecialThree(
              text: message['chats'],
              color: isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
              tail: true,
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

  Widget _buildChatIem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final isSender = data['senderId'] == currentUserId;

    return BubbleSpecialThree(
      text: data['chat'],
      color: isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
      tail: true,
      isSender: isSender,
      textStyle: TextStyle(
        color: isSender ? Colors.white : Colors.black,
        fontSize: 16,
      ),
    );
  }

}
