import 'package:chat_app/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String currUser;
  final bool activity;
  final bool group;
  final List<UserModel> members;
  final List<ChatModel> messages;

  late final List<UserModel> _recepients;

  ChatModel({
    required this.chatId,
    required this.currUser,
    required this.messages,
    required this.activity,
    required this.group,

    required this.members,
  })  {
    _recepients = members.where((_i) => _i.userId != currUser).toList();
  }

  List<UserModel> recepients() {
    return _recepients;
  }

  String title() {
    return !group
        ? _recepients.first.name
        : _recepients.map((_user) => _user.name).join(", ");
  }

  String imageURL() {
    return !group
        ? _recepients.first.imageUrl
        : "https://e7.pngegg.com/pngimages/380/670/png-clipart-group-chat-logo-blue-area-text-symbol-metroui-apps-live-messenger-alt-2-blue-text.png";
  }
}