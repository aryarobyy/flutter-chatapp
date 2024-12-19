import 'package:chat_app/model/user_model.dart';
import 'package:chat_app/service/auth/authentication.dart';
import 'package:chat_app/service/navigation_service.dart';
import 'package:chat_app/widget/chat.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  late NavigationService _navigation;
  late GetIt _getIt = GetIt.instance;

  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthMethod().getUserProfile(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Stream error: ${snapshot.error}");
            return const Center(
              child: Text("Unable to load data"),
            );
          }
          print("Snapshot data ${snapshot.data}");
          if (snapshot.hasData && snapshot.data != null) {
            final users = snapshot.data!.docs;
            return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  print("Raw user data: ${users[index].data()}");
                  final userMap = users[index].data() as Map<String, dynamic>;
                  UserModel user = UserModel.fromJSON(userMap);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ChatTile(
                        user: user,
                        onChatTap: () {},
                        onProfileTap:  () {}
                    ),
                  );
                });
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        });
  }
}
