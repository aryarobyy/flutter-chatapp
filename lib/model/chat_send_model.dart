import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  TEXT,
  IMAGE,
  UNKNOWN,
}

class ChatSend {
  final String senderId;
  final MessageType type;
  final String content;
  final DateTime sentTime;

  ChatSend({
    required this.senderId,
    required this.type,
    required this.content,
    required this.sentTime,
  });

  factory ChatSend.fromJson(Map<String, dynamic> _json) {
    MessageType _messageType;
    switch (_json["type"]) {
      case "text":
        _messageType = MessageType.TEXT;
        break;
      case "image":
        _messageType = MessageType.IMAGE;
        break;
      default:
        _messageType = MessageType.UNKNOWN;
    }
    var sentTime = _json["sent_time"];
    DateTime lastActiveDateTime;

    if (sentTime is Timestamp) {
      lastActiveDateTime = sentTime.toDate();
    } else if (sentTime is String) {
      try {
        lastActiveDateTime = DateTime.parse(sentTime);
      } catch (e) {
        print("Invalid date format for send_time: $sentTime");
        lastActiveDateTime = DateTime.now();
      }
    } else {
      lastActiveDateTime = DateTime.now();
    }
    return ChatSend(
        senderId: _json["uid"],
        type: _messageType,
        content: _json["content"],
        sentTime: sentTime,
    );
  }
  Map<String, dynamic> toJson() {
    String _messageType;
    switch (type) {
      case MessageType.TEXT:
        _messageType = "text";
        break;
      case MessageType.IMAGE:
        _messageType = "image";
        break;
      default:
        _messageType = "";
    }
    return {
      "content": content,
      "type": _messageType,
      "sender_id": senderId,
      "sent_time": Timestamp.fromDate(sentTime),
    };
  }
}