import 'package:chat_app/service/auth/login_or_register.dart';
import 'package:chat_app/service/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/service/navigation_service.dart';
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
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Center(
          child:  ElevatedButton(
              onPressed: () async {
                await FirebaseServices().googleSignOut();
                _navigation.navigateToRoute('/auth');
              },
              child: Text("Log Out")
          ),
        ),
      ),
    );
  }
}
