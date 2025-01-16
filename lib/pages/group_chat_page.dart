import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/widget/text_field.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GroupChatPage extends StatefulWidget {
  final List<String> members;
  final String roomId;

  const GroupChatPage({
    Key? key,
    required this.members,
    required this.roomId
  }) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final ChatService _chat = ChatService();
  final AuthService _auth = AuthService();
  String? _currUserId;
  String? _roomData;
  final TextEditingController messageController = TextEditingController();
  bool isPageVisible = true;
  bool isAppActive = true;

  @override
  void initState()  {
    super.initState();
    _initializeRooms();
    _initializeNotifications();
    // WidgetsBinding.instance.addObserver(this);
    // _chat = Provider.of<ChatService>(context, listen: false);

    // if (widget.roomId != null) {
    //   _updateUserChatStatus(true);
    //   ChatService.enterChatPage(widget.roomId!);
    //   print("Entered chat page: ${widget.roomId}");
    // }
    // AwesomeNotifications().setListeners(
    //   onActionReceivedMethod: (ReceivedAction receivedAction) async {
    //     if (receivedAction.payload != null) {
    //       String? roomId = receivedAction.payload!['roomId'];
    //       if (roomId != null) {
    //         Navigator.of(context).push(
    //           MaterialPageRoute(
    //             builder: (context) =>
    //                 ChatPage(receiverId: widget.receiverId, roomId: roomId),
    //           ),
    //         );
    //       }
    //     }
    //   },
    // );
  }

  @override
  void dispose() {
    _updateUserChatStatus(false);
    ChatService.leaveChatPage();
    print("Left chat page");
    WidgetsBinding.instance.removeObserver(this as WidgetsBindingObserver);
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

  Future<void> _initializeNotifications() async {
    await NotificationService.initializeNotification();
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

  Future<void> _initializeRooms() async {
    try {
      final id = await _auth.getCurrentUserId();
      setState(() {
        _currUserId = id;
        debugPrint('Updated state with user ID: $id');
      });
      print("Getting roomId 1: ${widget.roomId}");
    } catch (e) {
      debugPrint('Error in _initializeRooms: $e');
    }
  }

  Future<void> handleSendChat() async {
    if (messageController.text.isNotEmpty) {
      try {
        final currentUserId = await _auth.getCurrentUserId();
        final List<String> members = [currentUserId, widget.members as String];

        await _chat.sendChat(
          message: messageController.text,
          member: members,
        );
        print("ReceiverId: ${widget.members}");

        if (widget.members != currentUserId) {
          await NotificationService.showNotification(
            receiverId: members as String,
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
  Widget build(BuildContext context){
    print("RoomId $_roomData");
      return FutureBuilder<String>(
          future: _auth.getCurrentUserId(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(
                  title: _buildRoomHeader(context),
                ),
                body: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Scaffold(
                appBar: AppBar(
                  title: _buildRoomHeader(context),
                ),
                body: const Center(
                  child: Text("Error fetching user information"),
                ),
              );
            }

            final currentUserId = snapshot.data!;

            return Scaffold(
              appBar: AppBar(
                title: _buildRoomHeader(context),
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
          }
        );
  }

  Widget _buildRoomHeader(BuildContext context) {
    return FutureBuilder<RoomModel?>(
        future: _chat.getRoomById(widget.roomId),
        builder:  (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading user profile"));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No user found"));
          }

          final room = snapshot.data!;
          return Row(
            children: [
              CircleAvatar(
                backgroundImage: room.imageUrl.isNotEmpty
                    ? NetworkImage(room.imageUrl)
                    : AssetImage("assets/images/profile.png") as ImageProvider,
                radius: 20,
              ),
              SizedBox(
                width: 20,
              ),
              Text(room.roomName),
            ],
          );
        }
      );
  }

  Widget _bubbleChat(BuildContext context, String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chat.getChats(currentUserId, widget.members),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text("Error loading messages: ${snapshot.error}"),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }
        final messages = snapshot.data!.docs.reversed.toList();

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

            String fullText = message['chat'] ?? "";
            bool isLongText = fullText.length > 255;

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


  Widget _builds(BuildContext context) {
    return Scaffold(
      body: widget.members.isNotEmpty
              ? ListView.builder(
       itemCount: widget.members.where((member) => member != _currUserId).length,
       itemBuilder: (context, index) {
         final filteredMembers =
         widget.members.where((member) => member != _currUserId).toList();
         final member = filteredMembers[index];

         return ListTile(
         leading: CircleAvatar(
         backgroundColor: Colors.blue,
         child: Text(
         member.isNotEmpty ? member[0].toUpperCase() : '?',
             style: const TextStyle(color: Colors.white),
           ),
         ),
         title: Text(member),
         subtitle: const Text('Member ID'),
             );
           },
         )
         : const Center(
         child: Text('No members in the group'),
       ),
    );
  }

  // Widget _profileUser(BuildContext context, String receiverId) {
  //   final receiverId = widget.receiverId;
  //
  //   return StreamBuilder(
  //     stream: _auth.getUserById(receiverId),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (snapshot.hasError) {
  //         return const Center(child: Text("Error loading user profile"));
  //       }
  //       if (!snapshot.hasData) {
  //         return const Center(child: Text("No user found"));
  //       }
  //
  //       final user = snapshot.data!;
  //       return Row(
  //         children: [
  //           CircleAvatar(
  //             backgroundImage: user.imageUrl.isNotEmpty
  //                 ? NetworkImage(user.imageUrl)
  //                 : AssetImage("assets/images/profile.png") as ImageProvider,
  //             radius: 20,
  //           ),
  //           SizedBox(
  //             width: 20,
  //           ),
  //           Text(user.name),
  //         ],
  //       );
  //     },
  //   );
  // }


  // Widget _bubbleChat(BuildContext context, String currentUserId) {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: _chat.getChats(currentUserId, widget.members),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }

  //       if (snapshot.hasError) {
  //         return Center(
  //             child: Text("Error loading messages: ${snapshot.error}"));
  //       }

  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return const Center(child: Text("No messages yet"));
  //       }

  //       final messages = snapshot.data!.docs.reversed.toList();

  //       return ListView.builder(
  //         reverse: true,
  //         itemCount: messages.length,
  //         itemBuilder: (context, index) {
  //           final message = messages[index].data() as Map<String, dynamic>;
  //           final isSender = message['senderId'] == currentUserId;

  //           bool isLatest(List messages, int index) {
  //             if (index >= messages.length - 1) return true;
  //             final currentMsg = messages[index].data() as Map<String, dynamic>;
  //             final nextMsg =
  //                 messages[index + 1].data() as Map<String, dynamic>;
  //             return currentMsg['senderId'] != nextMsg['senderId'];
  //           }

  //           String fullText = message['chat'] ?? "";
  //           bool isLongText = fullText.length > 255;

  //           return BubbleSpecialThree(
  //             text: message['chat'] ?? "",
  //             color:
  //                 isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
  //             tail: isLatest(messages, index),
  //             isSender: isSender,
  //             textStyle: TextStyle(
  //               color: isSender ? Colors.white : Colors.black,
  //               fontSize: 16,
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}
