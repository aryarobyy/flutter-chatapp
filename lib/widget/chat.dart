import 'package:chat_app/model/user_model.dart';
import 'package:flutter/material.dart';

class ChatTile extends StatelessWidget {
  final UserModel user;
  final Function onChatTap;
  final Function onProfileTap;

  const ChatTile({
    super.key,
    required this.user,
    required this.onChatTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
            backgroundImage: NetworkImage(user.imageUrl),
          ),
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: Text(
          user.lastDayActive(), // Convert DateTime to String
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
