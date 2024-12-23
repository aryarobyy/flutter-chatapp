// import 'package:chat_app/service/chat_service.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:chat_bubbles/chat_bubbles.dart';
//
// class BubbleChat extends StatelessWidget {
//   final String receiverId;
//   const BubbleChat({
//     super.key,
//     required this.receiverId,
//   });
//   final ChatService _chatService = ChatService();
//   @override
//   Widget build(BuildContext context, String currentUserId) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: _chatService.getChats(currentUserId, widget.receiverId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError) {
//           return const Center(child: Text("Error loading messages"));
//         }
//         if (!snapshot.hasData) {
//           return const Center(child: Text("No messages yet"));
//         }
//         print("Data: ${snapshot}");
//         print("Current userId: ${widget.receiverId}");
//         final messages = snapshot.data!.docs;
//
//         return ListView.builder(
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             final message = messages[index].data() as Map<String, dynamic>;
//             final isSender = message['senderId'] == currentUserId;
//
//             return BubbleSpecialThree(
//               text: message['chat'] ?? "",
//               color: isSender ? const Color(0xFF1B97F3) : const Color(0xFFE8E8EE),
//               tail: true,
//               isSender: isSender,
//               textStyle: TextStyle(
//                 color: isSender ? Colors.white : Colors.black,
//                 fontSize: 16,
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
