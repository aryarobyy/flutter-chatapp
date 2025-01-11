import 'package:chat_app/model/user_model.dart';
import 'package:flutter/material.dart';

class AddUserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTapUser;
  final VoidCallback? onTapAdd;
  final VoidCallback? onTapRemove;
  const AddUserTile({
    required this.user,
    this.onTapUser,
    this.onTapAdd,
    this.onTapRemove,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ListTile(
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: user.imageUrl != null && user.imageUrl.isNotEmpty
              ? NetworkImage(user.imageUrl)
              : AssetImage("assets/images/profile.png") as ImageProvider,
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        trailing: onTapAdd != null? IconButton(
          icon: const Icon(Icons.add_circle_outline),
          color: Colors.green,
          onPressed: onTapAdd,
        ) : IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          color: Colors.green,
          onPressed: onTapRemove,
        )
      ),
    );
  }
}
