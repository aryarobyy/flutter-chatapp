import 'package:chat_app/component/bubble_chat.dart';
import 'package:chat_app/component/person.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("ChatApp"),),
      body: BubbleChat(),
    );
  }
}
