import 'package:chat_app/pages/profile_page.dart';
import 'package:chat_app/services/google_auth.dart';
import 'package:chat_app/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  late NavigationService _navigation;

  @override
  Widget build(BuildContext context) {
    _navigation = GetIt.instance.get<NavigationService>();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Settings"),
            ElevatedButton(
                onPressed: () async {
                  await FirebaseServices().googleSignOut();
                  _navigation.navigateToRoute('/auth');
                },
                child: Text("Log Out")
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Profile(),
      ),
    );
  }
}
