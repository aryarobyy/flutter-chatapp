import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String roomId;
  final String chatId;
  final String senderId;
  final String recieverId;
  final String senderEmail;
  final bool activity;
  final String chat;
  final Timestamp time;


  ChatModel({
    required this.roomId,
    required this.chatId,
    required this.senderId,
    required this.recieverId,
    required this.senderEmail,
    required this.chat,
    required this.activity,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return{
      'roomId': roomId,
      'senderId': senderId,
      'recieverId': recieverId,
      'senderEmail': senderEmail,
      'chat': chat,
      'activity': activity,
      'time': time,
    };
  }
}