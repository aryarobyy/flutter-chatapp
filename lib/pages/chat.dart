import 'package:chat_app/widget/bubble_chat.dart';
import 'package:chat_app/widget/chat_list.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {

  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Container(
        padding: EdgeInsets.all(20),
          child: Text("Halo"),
      )
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            BubbleChat()
          ],
        ),
      ),
    );
  }
}
