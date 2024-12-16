import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';

class BubbleChat extends StatelessWidget {
  const BubbleChat({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BubbleSpecialThree(
          text: 'Added iMessage shape bubbles',
          color: Color(0xFF1B97F3),
          tail: false,
          textStyle: TextStyle(
              color: Colors.white,
              fontSize: 16
          ),
        ),
        BubbleSpecialThree(
          text: 'Sure',
          color: Color(0xFFE8E8EE),
          tail: false,
          isSender: false,
        ),
      ],
    );
  }
}
