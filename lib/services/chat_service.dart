import 'package:chat_app/model/chat_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService extends ChangeNotifier {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final userId = AuthService().getCurrentUserId();
  final ROOM_COLLECTION = "rooms";
  final CHAT_COLLECTION = "chats";

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  Future<String> createRoom({
    required List<String> member,
    String? roomName,
    bool isGroup = false,
    String? imageUrl
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    if (!member.contains(currentUserId)) {
      member.add(currentUserId);
    }

    member.sort();
    String? roomId;

    final roomQuery = await _fireStore
        .collection(ROOM_COLLECTION)
        .where('members', arrayContains: currentUserId)
        .where('roomType', isEqualTo: isGroup ? 'group' : 'private')
        .where('image', isEqualTo: imageUrl)
        .get();

    for (var doc in roomQuery.docs) {
      final existingMembers = List<String>.from(doc.data()['members']);
      if (_areListsEqual(existingMembers, member)) {
        roomId = doc.id;
        break;
      }
    }

    if (roomId == null) {
      roomId = Uuid().v4();

      await _fireStore.collection(ROOM_COLLECTION).doc(roomId).set({
        'members': member,
        'roomType': isGroup ? 'group' : 'private',
        'roomName': isGroup ? roomName : null,
      }, SetOptions(merge: true));
    }

    return roomId;
  }

  static bool isOnChatPage = false;
  static String currentChatRoomId = '';

  static void enterChatPage(String roomId) {
    isOnChatPage = true;
    currentChatRoomId = roomId;
    print('Entered chat page: $isOnChatPage, Room: $currentChatRoomId');
  }

  static void leaveChatPage() {
    isOnChatPage = false;
    currentChatRoomId = '';
    print('Left chat page: $isOnChatPage');
  }

  Future<void> sendChat({
    required String message,
    required List<String> member,
    String? roomName,
    bool isGroup = false,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final currentEmail = _auth.currentUser!.email!;
    final Timestamp currentTime = Timestamp.now();

    final roomId = await createRoom(
      member: member,
      roomName: roomName,
      isGroup: isGroup,
    );

    final String chatId = Uuid().v4();

    ChatModel newChat = ChatModel(
      roomId: roomId,
      chatId: chatId,
      senderId: currentUserId,
      receiverId: "",
      senderEmail: currentEmail,
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

  Stream<QuerySnapshot> getChats(String userId1, String userId2) async* {
    final roomQuery = await _fireStore
        .collection(ROOM_COLLECTION)
        .where('members', arrayContains: userId1)
        .get();

    String? roomId;

    for (var doc in roomQuery.docs) {
      final members = List<String>.from(doc.data()['members']);
      if (members.contains(userId2)) {
        roomId = doc.id;
        break;
      }
    }

    if (roomId == null) {
      throw Exception('Room ID not found for the provided users.');
    }

    yield* _fireStore
        .collection(ROOM_COLLECTION)
        .doc(roomId)
        .collection(CHAT_COLLECTION)
        .orderBy('time', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getUserRoom(String userId) {
    return _fireStore
        .collection(ROOM_COLLECTION)
        .where('members', arrayContains: userId)
        .snapshots();
  }

  Future<Map<String, dynamic>> getRoomById(String roomId) async {
    final docSnapshot =
        await _fireStore.collection(ROOM_COLLECTION).doc(roomId).get();

    if (docSnapshot.exists) {
      return docSnapshot.data() as Map<String, dynamic>;
    } else {
      return {};
    }
  }

  Stream<DocumentSnapshot?> streamLatestChat(String userId1, String userId2) {
    return _fireStore
        .collection(ROOM_COLLECTION)
        .where('members', arrayContains: userId1)
        .where('members', isEqualTo: [userId1, userId2])
        .snapshots()
        .asyncMap((roomSnapshot) async {
          if (roomSnapshot.docs.isEmpty) return null;

          final roomDoc = roomSnapshot.docs.first;
          final latestChatSnapshot = await roomDoc.reference
              .collection(CHAT_COLLECTION)
              .orderBy('time', descending: true)
              .limit(1)
              .get();

          return latestChatSnapshot.docs.isNotEmpty
              ? latestChatSnapshot.docs.first
              : null;
        });
  }

  Stream<DocumentSnapshot?> streamLatestChatById(String roomId) {
    return _fireStore
        .collection(ROOM_COLLECTION)
        .doc(roomId)
        .snapshots()
        .asyncMap((roomSnapshot) async {
      if (!roomSnapshot.exists) return null;

      final latestChatSnapshot = await roomSnapshot.reference
          .collection(CHAT_COLLECTION)
          .orderBy('time', descending: true)
          .limit(1)
          .get();

      return latestChatSnapshot.docs.isNotEmpty
          ? latestChatSnapshot.docs.first
          : null;
    });
  }
}
