import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/widget/chat_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SavedUserContact extends StatefulWidget {
  const SavedUserContact({super.key});

  @override
  State<SavedUserContact> createState() => _SavedUserContactState();
}

class _SavedUserContactState extends State<SavedUserContact> {
  static const String _tag = "SAVED_CONTACTS";
  String? currentUserId;
  final AuthMethod _auth = AuthMethod();
  final ChatService _chat = ChatService();
  String? selectedUserId;

  @override
  void initState() {
    super.initState();
    debugPrint('[$_tag] InitState called');
    _initializeRooms();
  }

  void setSelectedUserId(String userId) {
    setState(() {
      selectedUserId = userId;
    });
  }
  Future<void> handleCreateRoom(Map<String, dynamic> userMap) async {
    try {
      final currentUserId = await AuthMethod().getCurrentUserId();

      List<String> member = [currentUserId, userMap['uid']];

      String roomId = await ChatService().createRoom(
        member: member,
        isGroup: false,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatPage(
            receiverId: userMap['uid'],
            roomId: roomId,
          ),
        ),
      );
    } catch (e) {
      print('Error creating room: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to show message: ${e.toString()}')),
      );
    }
  }


  Future<void> _initializeRooms() async {
    try {
      final id = await _auth.getCurrentUserId();
      setState(() {
        currentUserId = id;
        debugPrint('[$_tag] Updated state with user ID: $id');
      });
    } catch (e, stack) {
      debugPrint('[$_tag] Error in _initializeRooms: $e');
      debugPrint('[$_tag] Stack trace: $stack');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    Stream<QuerySnapshot> allRoom = _chat.getUserRoom(currentUserId!);
    print("All room: $allRoom");

    return StreamBuilder<QuerySnapshot>(
      stream: allRoom,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error loading messages"));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No messages yet"));
        }

        final rooms = snapshot.data!.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();

        debugPrint('[$_tag] Fetched rooms: $rooms');

        final List<Map<String, dynamic>> roomLists = rooms.map((room) {
          final members = room["members"] as List<dynamic>;
          final receiverId = members.firstWhere(
                (id) => id != currentUserId,
            orElse: () => null,
          );
          print("ReceiverId for room: $receiverId");
          return {
            "receiverId": receiverId,
            ...room,
          };
        }).toList();

        print("Processed Roomlist: $roomLists");

        return ListView.builder(
          itemCount: roomLists.length,
          itemBuilder: (context, index) {
            final room = roomLists[index];
            final receiverId = room['receiverId'];

            return StreamBuilder<UserModel>(
              stream: _auth.getUserById(receiverId),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const Center(child: Text("Error loading user data"));
                }

                final user = userSnapshot.data!;

                return ChatTile(
                  user: user,
                  onChatTap: () async {
                    final userMap = {
                      'uid': user.uid,
                    };
                    await handleCreateRoom(userMap);
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