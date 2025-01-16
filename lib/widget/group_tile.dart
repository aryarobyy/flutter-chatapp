import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:flutter/material.dart';

class GroupTile extends StatelessWidget {
  final RoomModel room;
  final Function onChatTap;
  final Function onProfileTap;

  const GroupTile({
    super.key,
    required this.room,
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
        // subtitle: FutureBuilder<String>(
        //   future: AuthService().getCurrentUserId(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Text(
        //         "Loading...",
        //         style: TextStyle(color: Colors.grey, fontSize: 16),
        //       );
        //     }
        //     if (snapshot.hasError) {
        //       return const Text(
        //         "Error loading user ID",
        //         style: TextStyle(color: Colors.red, fontSize: 16),
        //       );
        //     }
        //     if (!snapshot.hasData) {
        //       return const Text(
        //         "User ID not available",
        //         style: TextStyle(color: Colors.grey, fontSize: 16),
        //       );
        //     }
        //
        //     final currentUserId = snapshot.data!;
        //     return StreamBuilder(
        //       stream: _chatService.streamLatestChat(currentUserId, user.uid),
        //       builder: (context, snapshot) {
        //         if (snapshot.connectionState == ConnectionState.waiting) {
        //           return const Text(
        //             "Loading...",
        //             style: TextStyle(color: Colors.grey, fontSize: 16),
        //           );
        //         }
        //         if (snapshot.hasError) {
        //           return const Text(
        //             "Error loading chat",
        //             style: TextStyle(color: Colors.red, fontSize: 16),
        //           );
        //         }
        //         if (!snapshot.hasData || snapshot.data == null) {
        //           return const Text(
        //             "No message yet ",
        //             style: TextStyle(color: Colors.grey, fontSize: 16),
        //           );
        //         }
        //         print("Latest chat : ${snapshot.data!}");
        //
        //
        //         final latestChat = snapshot.data!.data() as Map<String, dynamic>;
        //         return Text(
        //           latestChat['chat'] ?? "",
        //           style: const TextStyle(
        //             color: Colors.grey,
        //             fontSize: 16,
        //           ),
        //           maxLines: 1,
        //           overflow: TextOverflow.ellipsis,
        //         );
        //       },
        //     );
        //   },
        // ),

        // trailing: Text(
        //   room.lastDayActive(),
        //   style: const TextStyle(
        //     color: Colors.grey,
        //     fontSize: 14,
        //   ),
        // ),
      ),
    );
  }
}
