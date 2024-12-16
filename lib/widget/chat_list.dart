import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> users = [
      {
        "uid": "1",
        "name": "Alice",
        "lastOnline": "5 minutes ago",
        "lastMessage": "Hi, how are you?",
        "time": "21:02",
        "profilePic": "assets/images/user1.jpg",
      },
      {
        "uid": "2",
        "name": "Bob",
        "lastOnline": "10 minutes ago",
        "lastMessage": "See you soon!",
        "time": "20:51",
        "profilePic": "assets/images/user2.jpg",
      },
      {
        "uid": "3",
        "name": "Charlie",
        "lastOnline": "30 minutes ago",
        "lastMessage": "Let's catch up later.",
        "time": "20:35",
        "profilePic": "assets/images/user3.jpg",
      },
      {
        "uid": "4",
        "name": "Diana",
        "lastOnline": "1 hour ago",
        "lastMessage": "Call me when free.",
        "time": "19:20",
        "profilePic": "assets/images/user4.jpg",
      },
      {
        "uid": "5",
        "name": "Eve",
        "lastOnline": "2 hours ago",
        "lastMessage": "Got your message!",
        "time": "18:15",
        "profilePic": "assets/images/user5.jpg",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(user["profilePic"]!),
              radius: 28,
            ),
            title: Text(
              user["name"]!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: Text(
              user["lastMessage"] ?? "",
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Text(
              user["time"] ?? "",
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }
}
