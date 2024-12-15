import 'package:chat_app/service/auth/login_or_register.dart';
import 'package:chat_app/service/google_auth/google_auth.dart';
import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Center(
          child:  ElevatedButton(
              onPressed: () async {
                await FirebaseServices().googleSignOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const LoginOrRegister(),
                  ),
                );
              },
              child: Text("Log Out")
          ),
        ),
      ),
    );
  }
}
