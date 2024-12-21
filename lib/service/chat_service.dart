import 'package:chat_app/model/chat_model.dart';
import 'package:chat_app/service/auth/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final userId = AuthMethod().getCurrentUserId();
  final ROOM_COLLECTION = "rooms";
  final CHAT_COLLECTION = "chats";

  Future<void> sendChat(
    String recieverId,
    message,
  ) async {
    final currentUserId = _auth.currentUser!.uid;
    ;
    final currentEmail = _auth.currentUser!.email;
    final Timestamp currentTime = Timestamp.now();

    final uuid = Uuid().v4();
    final roomId = uuid;
    final chatId = uuid;

    ChatModel newChat = ChatModel(
      roomId: roomId,
      chatId: chatId,
      senderId: currentUserId,
      recieverId: recieverId,
      senderEmail: currentEmail!,
      chat: message,
      activity: true,
      time: currentTime,
    );

    await _fireStore
        .collection(ROOM_COLLECTION)
        .doc(roomId)
        .collection(CHAT_COLLECTION)
        .add(newChat.toMap());
   }

   Stream<QuerySnapshot> getChats(String userId1, userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    String roomId = ids.join('_');

    return _fireStore
        .collection(ROOM_COLLECTION)
        .doc(roomId)
        .collection(CHAT_COLLECTION)
        .orderBy('time', descending: false)
        .snapshots();
  }
}
