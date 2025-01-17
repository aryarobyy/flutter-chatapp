import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GroupTile extends StatelessWidget {
  final String roomId;
  final RoomModel room;
  final Function onChatTap;
  final Function onProfileTap;

  const GroupTile({
    super.key,
    required this.roomId,
    required this.room,
    required this.onChatTap,
    required this.onProfileTap,
  });

  String formatLastActive(String lastActive) {
    DateTime dateTime = DateFormat('M/d/yyyy').parse(lastActive);
    final DateFormat formatter = DateFormat('h:mm:ss a z');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    print("RoomId group: $roomId");
    final ChatService _chatService = ChatService();
    CachedNetworkImage(
      imageUrl: room.imageUrl,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );

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
            backgroundImage: room.imageUrl != null && room.imageUrl.isNotEmpty
                ? NetworkImage(room.imageUrl)
                : AssetImage("assets/images/profile.png") as ImageProvider,
          ),
        ),
        title: Text(room.roomName ,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle:
        roomId == null
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
                print("Latest chat : ${snapshot.data!}");


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
        ),
      ),
    );
  }
}
