import 'package:chat_app/widget/person.dart';
import 'package:flutter/material.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Contact")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Person(),
            Person(),
            Person()
          ],
        ),
      ),
    );
  }
}
