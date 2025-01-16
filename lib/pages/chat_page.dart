import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/widget/text_field.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  final String roomId;
  const ChatPage({
    super.key,
    required this.receiverId,
    required this.roomId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
  final TextEditingController messageController = TextEditingController();
  late final ChatService _chat;
  final AuthService _auth = AuthService();
  final FlutterSecureStorage FStorage = FlutterSecureStorage();
  bool isPageVisible = true;
  bool isAppActive = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chat = Provider.of<ChatService>(context, listen: false);
    _initializeNotifications();

    if (widget.roomId != null) {
      _updateUserChatStatus(true);
      ChatService.enterChatPage(widget.roomId!);
    }
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        if (receivedAction.payload != null) {
          String? roomId = receivedAction.payload!['roomId'];
          if (roomId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChatPage(receiverId: widget.receiverId, roomId: roomId),
              ),
            );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _updateUserChatStatus(false);
    ChatService.leaveChatPage();
    print("Left chat page");
    WidgetsBinding.instance.removeObserver(this);
    messageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      isAppActive = state == AppLifecycleState.resumed;
      isPageVisible = isAppActive && mounted;
    });
  }

  Future<void> _updateUserChatStatus(bool isOnChatPage) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .update({
      'isOnChatPage': isOnChatPage,
      'currentChatRoom': isOnChatPage ? widget.roomId : null,
    });
  }

  Future<void> _initializeNotifications() async {
    await NotificationService.initializeNotification();
  }

  Future<void> handleSendChat() async {
    if (messageController.text.isNotEmpty) {
      try {
        final currentUserId = await _auth.getCurrentUserId();
        final List<String> members = [currentUserId, widget.receiverId];

        await _chat.sendChat(
          message: messageController.text,
          member: members,
        );

        if (widget.receiverId != currentUserId) {
          await NotificationService.showNotification(
            receiverIds: members,
            title: "New Message",
            message: messageController.text,
            roomId: widget.roomId ?? '',
          );
        }

        messageController.clear();
      } catch (e) {
        print("Error in handleSendChat: $e");
      }
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
              title: _profileUser(context, widget.receiverId),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: _profileUser(context, widget.receiverId),
            ),
            body: const Center(
              child: Text("Error fetching user information"),
            ),
          );
        }

        final currentUserId = snapshot.data!;

        return Scaffold(
          appBar: AppBar(
            title: _profileUser(context, widget.receiverId),
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
                        maxLine: 3,
                        minLine: 1,
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
    print("RoomId ${widget.roomId}");
    return StreamBuilder<QuerySnapshot>(
      stream: _chat.getChatsByRoomId(widget.roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
              child: Text("Error loading messages: ${snapshot.error}")
          );
        }


        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }
        final messages = snapshot.data!.docs.reversed.toList();

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index].data() as Map<String, dynamic>;
            final isSender = message['senderId'] == currentUserId;

            bool isLatest(List messages, int index) {
              if (index >= messages.length - 1) return true;
              final currentMsg = messages[index].data() as Map<String, dynamic>;
              final nextMsg =
                  messages[index + 1].data() as Map<String, dynamic>;
              return currentMsg['senderId'] != nextMsg['senderId'];
            }

            String fullText = message['chat'] ?? "";
            bool isLongText = fullText.length > 255;

            return BubbleSpecialThree(
              text: message['chat'] ?? "",
              color:
                  isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
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

  Widget _profileUser(BuildContext context, String receiverId) {
    final receiverId = widget.receiverId;

    return StreamBuilder(
      stream: _auth.getUserById(receiverId),
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
                  : AssetImage("assets/images/profile.png") as ImageProvider,
              radius: 20,
            ),
            SizedBox(
              width: 20,
            ),
            Text(user.name),
          ],
        );
      },
    );
  }
}
