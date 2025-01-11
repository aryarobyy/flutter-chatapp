import 'package:chat_app/pages/auth/auth.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/services/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/services/images_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/widget/button2.dart';
import 'package:provider/provider.dart';
import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/widget/text_field_2.dart';

part 'profile_page.dart';
part 'update_profile.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

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
                  builder: (context) => Auth(),
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
