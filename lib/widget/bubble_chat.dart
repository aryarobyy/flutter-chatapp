import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class BubbleChat extends StatelessWidget {
  final String sender;
  final String reciever;
  const BubbleChat({
    super.key,
    required this.sender,
    required this.reciever,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BubbleSpecialThree(
          text: sender,
          color: Color(0xFF1B97F3),
          tail: false,
          textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16
          ),
        ),
        BubbleSpecialThree(
          text: reciever,
          color: Color(0xFFE8E8EE),
          tail: false,
          isSender: false,
        ),
      ],
    );
  }
}
