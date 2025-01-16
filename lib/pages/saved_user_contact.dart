import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/pages/group_chat_page.dart';
import 'package:chat_app/pages/home_page.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/widget/button2.dart';
import 'package:chat_app/widget/chat_tile.dart';
import 'package:chat_app/widget/group_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedUserContact extends StatefulWidget {
  const SavedUserContact({super.key});

  @override
  State<SavedUserContact> createState() => _SavedUserContactState();
}

class _SavedUserContactState extends State<SavedUserContact> {
  String? currentUserId;
  final AuthService _auth = AuthService();
  final ChatService _chat = ChatService();
  String? selectedUserId;

  @override
  void initState() {
    super.initState();
    debugPrint('InitState called');
    _initializeRooms();
  }

  void setSelectedUserId(String userId) {
    setState(() {
      selectedUserId = userId;
    });
  }

  Future<void> handleCreateRoom(List<String> userMap) async {
    try {
      final currentUserId = await AuthService().getCurrentUserId();

      List<String> members = [currentUserId, ...userMap];

      String roomId = await ChatService().createRoom(
        member: members,
        isGroup: members.length > 2,
      );
      if (!mounted) return;

      if (members.length > 2) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => GroupChatPage(
                  members: members,
                  roomId: roomId,
              )),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverId: members.first,
              roomId: roomId,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating room: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create room: ${e.toString()}')),
      );
    }
  }

  Future<void> _initializeRooms() async {
    try {
      final id = await _auth.getCurrentUserId();
      setState(() {
        currentUserId = id;
        debugPrint('Updated state with user ID: $id');
      });
    } catch (e) {
      debugPrint('Error in _initializeRooms: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat App"),
      ),
      body: currentUserId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(child: _contactUi(context)),
              ],
            ),
    );
  }

  Widget _contactUi(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _chat.getUserRooms(currentUserId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Failed to load rooms: ${snapshot.error}"),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "You don't have any chat history",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 200,
                  height: 55,
                  child: MyButton2(
                    text: "Add Contact",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(initialTab: 1),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        final rooms = snapshot.data!.docs;

        return ListView.builder(
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final roomData = rooms[index].data() as Map<String, dynamic>;
            final room = RoomModel.fromMap(roomData);
            final members = List<String>.from(roomData['members'] ?? []);
            print("Members: $members");
            final isGroup = members.length > 2;

            final receiverId = isGroup
                ? null
                : members.firstWhere(
                    (id) => id != currentUserId,
                    orElse: () => '',
                  );

            if ((receiverId == null || receiverId.isEmpty) && !isGroup) {
              return const SizedBox.shrink();
            }

            if (isGroup) {
              return GroupTile(
                room: room,
                onChatTap: () async {
                  final List<String> otherMembers =
                      members.where((id) => id != currentUserId).toList();
                  await handleCreateRoom(otherMembers);
                },
                onProfileTap: () async {},
              );
            }

            return StreamBuilder<UserModel>(
              stream: _auth.getUserById(receiverId!),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final user = userSnapshot.data!;
                return ChatTile(
                  user: user,
                  onChatTap: () async {
                    print("ReceiverId: ${[receiverId]}");
                    await handleCreateRoom([receiverId]);
                  },
                  onProfileTap: () {
                    _showUserProfile(context, user);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  //Sementara
  void _showUserProfile(BuildContext context, UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Last active: ${user.lastDayActive()}'),
            if (user.wasRecentlyActive())
              const Text('Status: Recently active',
                  style: TextStyle(color: Colors.green)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
