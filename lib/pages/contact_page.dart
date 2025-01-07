import 'package:chat_app/component/search_bar.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/widget/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  final TextEditingController _searchController = TextEditingController();
  final AuthMethod _auth = AuthMethod();
  String _searchQuery = '';
  bool isSearching = false;
  String? _currentUserId;

  final FStorage = FlutterSecureStorage();
  LocalStorage? localStorage;
  bool isStorageInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeStorage();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    try {
      final userId = await _auth.getCurrentUserId();
      setState(() {
        _currentUserId = userId;
      });
    } catch (e) {
      print('Error getting current user ID: $e');
    }
  }

  Future<void> _initializeStorage() async {
    try {
      final storage = LocalStorage('chat_app');
      final isReady = await storage.ready;
      if (isReady) {
        setState(() {
          localStorage = storage;
          isStorageInitialized = true;
        });
      } else {
        print("Failed to initialize LocalStorage");
      }
    } catch (e) {
      print("Error initializing storage: $e");
    }
  }


  void _onPressed() async {
    try {
      final userStream = _auth.getUserById(_currentUserId as String);
      final userData = await userStream.first;
      final _currentEmail = userData.email;

      if (_searchController.text.toLowerCase() == _currentEmail){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You cannot chat with yourself')),
        );
        return;
      }
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        isSearching = true;
      });
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  Future<void> handleCreateRoom(Map<String, dynamic> userMap) async {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not initialized')),
      );
      return;
    }
    try {
      final currentUserId = await _auth.getCurrentUserId();

      List<String> members = [currentUserId, userMap['uid']];

      String roomId = await ChatService().createRoom(
        member: members,
        isGroup: false,
      );
      if (!mounted) return;

      if (!isStorageInitialized) {
        print("LocalStorage not initialized");
        return;
      }

      final List<dynamic> existingRooms = jsonDecode(localStorage!.getItem(_currentUserId as String) ?? '[]');
      if (!existingRooms.contains(roomId)) {
        existingRooms.add(roomId);
        localStorage!.setItem(_currentUserId as String, jsonEncode(existingRooms));
      }
      print("Stored rooms: $existingRooms");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ChatPage(
                receiverId: userMap['uid'],
                roomId: roomId,
              ),
        ),
      );
    } catch (e) {
      print('Error creating room: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create chat room: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ChatApp"),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(8.0),
            padding: const EdgeInsets.all(2.0),
            child: MySearchBar(
              controller: _searchController,
              hintText: "Search for users by email...",
              onPressed: _onPressed,
              onSubmitted: (value) {
                _searchController.text = value;
                _onPressed();
              },
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {
                          localStorage!.deleteItem(_currentUserId as String);
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Icon(Icons.clear, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text(
                              "Clear history",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: _buildTile(context),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _builHistory() {
    if (!isStorageInitialized || localStorage == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final storedRooms = jsonDecode(localStorage!.getItem(_currentUserId as String) ?? '[]') as List<dynamic>;
    print("Stored rooms: $storedRooms");

    if (storedRooms.isEmpty) {
      return const Center(child: Text("No chat history"));
    }

    return ListView.builder(
      itemCount: storedRooms.length,
      itemBuilder: (context, index) {
        final roomId = storedRooms[index];

        return FutureBuilder<Map<String, dynamic>>(
          future: ChatService().getRoomById(roomId),
          builder: (context, roomSnapshot) {
            if (!roomSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            final room = roomSnapshot.data!;
            final members = room['members'] ?? [];
            final receiverId = members.firstWhere(
                  (id) => id != _currentUserId,
              orElse: () => null,
            );

            if (receiverId == null) return const SizedBox.shrink();

            return FutureBuilder<UserModel?>(
              future: _auth.getUserById(receiverId).first,
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }

                if (userSnapshot.hasError || !userSnapshot.hasData) {
                  return const SizedBox.shrink();
                }

                final user = userSnapshot.data!;
                return UserTile(
                  user: user,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          receiverId: receiverId,
                          roomId: roomId,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTile(BuildContext context) {
    if (_searchQuery.isEmpty) {
      return _builHistory();
    }

    return StreamBuilder<UserModel?>(
      stream: _auth.getUserByEmail(_searchQuery.toLowerCase()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text("Error loading user profile."));
        }
        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text("No user found."));
        }

        return UserTile(
          user: user,
          onTap: () => handleCreateRoom({'uid': user.uid}),
        );
      },
    );
  }
}