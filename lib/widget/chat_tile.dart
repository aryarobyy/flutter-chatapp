import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final String roomId;
  final UserModel user;
  final Function onChatTap;
  final Function onProfileTap;

  const ChatTile({
    super.key,
    required this.roomId,
    required this.user,
    required this.onChatTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final ChatService _chatService = ChatService();
    return GestureDetector(
      onTap: () {
        onChatTap();
      },
      child: ListTile(
        leading: InkWell(
          onTap: () {
            onProfileTap();
          },
          child: CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: user.imageUrl != null && user.imageUrl.isNotEmpty
                ? NetworkImage(user.imageUrl)
                : AssetImage("assets/images/profile.png") as ImageProvider,
          ),
        ),
        title: Text(user.name ,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: roomId == null
                ? const Text(
              "No chat yet",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ) : StreamBuilder(
              stream: _chatService.streamLatestChatById(roomId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "Loading...",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  );
                }
                if (snapshot.hasError) {
                  return const Text(
                    "Error loading chat",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  );
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Text(
                    "No message yet ",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  );
                }

                final latestChat = snapshot.data!.data() as Map<String, dynamic>;
                return Text(
                  latestChat['chat'] ?? "",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                );
              },
            )
        ),
    );
  }
}