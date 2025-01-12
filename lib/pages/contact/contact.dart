import 'package:chat_app/component/snackbar.dart';
import 'package:chat_app/model/room_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widget/alert.dart';
import 'package:chat_app/widget/button2.dart';
import 'package:chat_app/widget/text_field_2.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/component/search_bar.dart';
import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/pages/chat_page.dart';
import 'package:chat_app/services/chat_service.dart';
import 'package:chat_app/widget/user_tile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localstorage/localstorage.dart';
import 'dart:convert';

part 'search_contact.dart';
part 'add_group.dart';

class Contact extends StatelessWidget {
  const Contact({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Navigator(
          onGenerateRoute: (RouteSettings settings) {
            Widget page;
            switch (settings.name) {
              case '/group':
                page = AddGroup();
                break;
              case '/':
              default:
                page = SearchContact();
            }
            return MaterialPageRoute(builder: (context) => page);
          },
        ),
      ),
    );
  }
}
