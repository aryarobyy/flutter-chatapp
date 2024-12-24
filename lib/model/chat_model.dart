import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String roomId;
  final String chatId;
  final String senderId;
  final String receiverId;
  final String senderEmail;
  final bool activity;
  final String chat;
  final Timestamp time;

  ChatModel({
    required this.roomId,
    required this.chatId,
    required this.senderId,
    this.receiverId = '',
    required this.senderEmail,
    required this.chat,
    required this.activity,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'chatId': chatId,
      'senderId': senderId,
      'receiverId': receiverId,
      'senderEmail': senderEmail,
      'chat': chat,
      'activity': activity,
      'time': time,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      roomId: map['roomId'] ?? '',
      chatId: map['chatId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      senderEmail: map['senderEmail'] ?? '',
      chat: map['chat'] ?? '',
      activity: map['activity'] ?? false,
      time: map['time'] ?? Timestamp.now(),
    );
  }
}
