import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/profile/profile.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:chat_app/widget/text_field.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupChatPage extends StatefulWidget {
  final List<String> members;
  final String roomId;

  const GroupChatPage({
    Key? key,
    required this.members,
    required this.roomId,
  }) : super(key: key);

  @override
  State<GroupChatPage> createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> with WidgetsBindingObserver {
  final ChatService _chat = ChatService();
  late final ChatService _chatService;
  final AuthService _auth = AuthService();
  RoomModel? _roomData;
  final TextEditingController messageController = TextEditingController();
  bool isPageVisible = true;
  bool isAppActive = true;
  List<String>? _members;

  late String currentUserId;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    WidgetsBinding.instance.addObserver(this);

    _auth.getCurrentUserId().then((id) {
      setState(() {
        currentUserId = id;
      });
    });

    if (widget.roomId != null) {
      _updateUserChatStatus(true);
      ChatService.enterChatPage(widget.roomId);
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: (ReceivedAction receivedAction) async {
        if (receivedAction.payload != null) {
          String? roomId = receivedAction.payload!['roomId'];
          if (roomId != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    ChatPage(receiverId: _members as String, roomId: roomId),
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    try {
      final roomData = await _chat.getRoomById(widget.roomId);
      if (mounted) {
        setState(() {
          _roomData = roomData;
        });
      }
    } catch (e) {
      debugPrint('Error loading room data: $e');
    }
  }

  Future<void> handleSendChat() async {
    if (messageController.text.isNotEmpty) {
      try {
        final currentUserId = await _auth.getCurrentUserId();

        final List<String> members = [
          if (widget.members is String)
            widget.members as String
          else
            ...widget.members as List<String>,
        ];
        _members = members;

        await _chat.sendChat(
          message: messageController.text,
          member: members,
          roomName: _roomData?.roomName,
        );


          final dataStream = await _auth.getUserById(currentUserId);
          UserModel? userModel;
          String username = 'unknown';

          await for (final data in dataStream) {
            userModel = data;
            break;
          }

          if (userModel != null) {
            username = userModel.name;
          }
          if (widget.members != currentUserId) {
            await NotificationService.showNotification(
              receiverIds: members,
              title: "${_roomData?.roomName ?? 'Group Chat'}",
              message: "$username: ${messageController.text}",
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
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: _buildRoomHeader(context),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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

  Widget _buildRoomHeader(BuildContext context) {
    if (_roomData == null) {
      return const Center(child: Text("No room data available"));
    }
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: _roomData?.imageUrl?.isNotEmpty == true
              ? NetworkImage(_roomData!.imageUrl)
              : const AssetImage("assets/images/profile.png") as ImageProvider,
          radius: 20,
        ),
        const SizedBox(
          width: 20,
        ),
        Text(_roomData?.roomName ?? "Unnamed Room"),
      ],
    );
  }

  Widget _bubbleChat(BuildContext context, String currentUserId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chat.getChatsByRoomId(widget.roomId),
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
          reverse: true,
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
            bool isNewest(int index) => index == 0;

            return Column(
              crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (isLatest(messages, index))
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePage(userId: message['senderId']),
                          ),
                        );
                      },
                      child: _buildChatHeader(context, message['senderId'], isSender),
                    ),
                  ),
                BubbleSpecialThree(
                  text: message['chat'] ?? "",
                  color: isSender
                      ? const Color(0xFF1B97F3)
                      : const Color(0xFFE8E8EE),
                  // Only add the tail if the message is the newest
                  tail: isNewest(index),
                  isSender: isSender,
                  textStyle: TextStyle(
                    color: isSender ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ],
            );
          },
        );

      },
    );
  }

  Widget _buildChatHeader(BuildContext context, String userId,  bool isSender) {
    return StreamBuilder<UserModel>(
      stream: _auth.getUserById(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text("Error loading user: ${snapshot.error}");
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Text("User not found");
        }

        final user = snapshot.data!;
        CachedNetworkImage(
          imageUrl: user.imageUrl,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        );
        return Padding(
          padding: const EdgeInsets.only(left: 20, top: 10, bottom: 10),
          child: Row(
          mainAxisAlignment:
            isSender ?  MainAxisAlignment.end :  MainAxisAlignment.start,
            children: [
              isSender ?
                  Column(
                    children: [
                      CircleAvatar(
                        backgroundImage: user.imageUrl?.isNotEmpty == true
                            ? NetworkImage(user.imageUrl!)
                            : const AssetImage("assets/images/profile.png")
                        as ImageProvider,
                        radius: 12,
                      ),
                    ],
                  ) :
                  CircleAvatar(
                    backgroundImage: user.imageUrl?.isNotEmpty == true
                        ? NetworkImage(user.imageUrl!)
                        : const AssetImage("assets/images/profile.png")
                    as ImageProvider,
                    radius: 12,
                  ),
                  SizedBox(height: 10, width: 4,),
                  Text(
                    user.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
            ]
          ),
        );
      },
    );
  }

}
