import 'package:chat_app/model/chat_model.dart';
import 'package:chat_app/services/auth/authentication.dart';
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
    final roomId = currentUserId.hashCode <= recieverId.hashCode
        ? '$currentUserId-$recieverId'
        : '$recieverId-$currentUserId';
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
    final roomId = userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';

    return _fireStore
        .collection(ROOM_COLLECTION)
        .doc(roomId)
        .collection(CHAT_COLLECTION)
        .orderBy('time', descending: false)
        .snapshots();
  }


  Stream<DocumentSnapshot?> streamLatestChat(String userId1, String userId2) {
    final roomId = userId1.hashCode <= userId2.hashCode
        ? '$userId1-$userId2'
        : '$userId2-$userId1';

    return _fireStore
        .collection(ROOM_COLLECTION)
        .doc(roomId)
        .collection(CHAT_COLLECTION)
        .orderBy('time', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) => snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

}
