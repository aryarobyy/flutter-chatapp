import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/pages/update_profile.dart';
import 'package:chat_app/services/auth/auth_gate.dart';
import 'package:chat_app/services/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Profile"),
            IconButton(onPressed: () async {
              await GoogleAuth().googleSignOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthGate(),
                ),
              );
            }, icon: Icon(Icons.logout)
            )
          ],
        ),
      ),
      body: SafeArea(
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            Widget page;
            switch (settings.name) {
              case '/update-profile':
                page = const UpdateProfile();
                break;
              case '/':
              default:
                page = const ProfilePage();
            }
            return MaterialPageRoute(builder: (context) => page);
          },
        ),
      ),
    );
  }
}
