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
  final MEMBERS_COLLECTION = "members";

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }

    return true;
  }

  Future<String> createRoom({
    required List<String> members,
    String? roomName,
    bool isGroup = false,
  }) async {
    final currentUserId = _auth.currentUser!.uid;

    if (!members.contains(currentUserId)) {
      members.add(currentUserId);
    }

    members.sort();
    String? roomId;

    final roomQuery = await _fireStore
        .collection(ROOM_COLLECTION)
        .where('members', arrayContains: currentUserId)
        .where('roomType', isEqualTo: isGroup ? 'group' : 'private')
        .get();

    for (var doc in roomQuery.docs) {
      final existingMembers = List<String>.from(doc.data()['members']);
      if (_areListsEqual(existingMembers, members)) {
        roomId = doc.id;
        break;
      }
    }

    if (roomId == null) {
      roomId = Uuid().v4();

      await _fireStore.collection(ROOM_COLLECTION).doc(roomId).set({
        'members': members,
        'roomType': isGroup ? 'group' : 'private',
        'roomName': isGroup ? roomName : null,
      }, SetOptions(merge: true));
    }

    return roomId;
  }

  Future<void> sendChat({
    required String message,
    required List<String> members,
    String? roomName,
    bool isGroup = false,
  }) async {
    final currentUserId = _auth.currentUser!.uid;
    final currentEmail = _auth.currentUser!.email!;
    final Timestamp currentTime = Timestamp.now();

    final roomId = await createRoom(
      members: members,
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

  Future<List<String>> findRoomByMember(String memberId) async {
    try {
      final querySnapshot = await _fireStore
          .collection('rooms')
          .where('members', arrayContains: memberId)
          .get();

      List<String> roomIds = [];
      for (var doc in querySnapshot.docs) {
        roomIds.add(doc['roomId']);
      }

      return roomIds;
    } catch (e) {
      print("Error fetching roomIds: $e");
      return [];
    }
  }


  // Future<void> getSpesificRoom(String userId) async{
  //   final _userId = userId.hashCode;
  //   print('User ID: $_userId');
  //   await _fireStore
  //       .collection(ROOM_COLLECTION)
  //       .where('$_userId', isEqualTo: userId)
  //       .collection(CHAT_COLLECTION)
  //       .orderBy('time', descending: false)
  //       .snapshots();
  // }

   Stream<List<DocumentSnapshot>> getRoomsByMember(String uid) {
    debugPrint('[CHAT_SERVICE] Getting rooms for user: $uid');

    return _fireStore
        .collection(ROOM_COLLECTION)
        .snapshots()
        .asyncMap((roomsSnapshot) async {
      debugPrint('[CHAT_SERVICE] Fetched ${roomsSnapshot.docs.length} total rooms');

      List<DocumentSnapshot> userRooms = [];

      for (var roomDoc in roomsSnapshot.docs) {
        final memberDoc = await roomDoc.reference
            .collection('members')
            .doc(uid)
            .get();

        if (memberDoc.exists) {
          debugPrint('[CHAT_SERVICE] User $uid is member of room ${roomDoc.id}');
          userRooms.add(roomDoc);
        }
      }

      debugPrint('[CHAT_SERVICE] Found ${userRooms.length} rooms for user $uid');
      return userRooms;
    });
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
        .map((snapshot) =>
    snapshot.docs.isNotEmpty ? snapshot.docs.first : null);
  }

  Stream<List<Map<String, dynamic>>> getAllRooms() {
    return _fireStore
        .collection(ROOM_COLLECTION)
        .snapshots()
        .map((querySnapshot) =>
          querySnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['roomId'] = doc.id;
            return data;
          }) .toList());
  }

  Stream<List<Map<String, dynamic>>> fetchRoomsAndMembersAsStream() async* {
    try {
      await for (QuerySnapshot roomsSnapshot in _fireStore.collection(ROOM_COLLECTION).snapshots()) {
        List<Map<String, dynamic>> roomsWithMembers = [];

        for (var roomDoc in roomsSnapshot.docs) {
          String roomId = roomDoc.id;
          print("RoomId: $roomId");

          QuerySnapshot membersSnapshot = await _fireStore
              .collection(ROOM_COLLECTION)
              .doc(roomId)
              .collection(MEMBERS_COLLECTION)
              .get();

          List<String> memberIds = membersSnapshot.docs.map((doc) => doc.id).toList();

          roomsWithMembers.add({
            'roomId': roomId,
            'members': memberIds,
          });
        }

        yield roomsWithMembers;
      }
    } catch (e) {
      print('Error fetching rooms and members: $e');
      yield [];
    }
  }



  Stream<List<String>> getAllRoomIds() {
    return _fireStore
        .collection(ROOM_COLLECTION)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs.map((doc) => doc.id).toList());
  }

  Future<void> getUserRoom(String userId) async {
    try {
      QuerySnapshot roomSnapshot = await _fireStore.collection(ROOM_COLLECTION).get();

      for (var roomDoc in roomSnapshot.docs) {
        String roomId = roomDoc.id;

        QuerySnapshot membersSnapshot = await _fireStore
            .collection(ROOM_COLLECTION)
            .doc(roomId)
            .collection(MEMBERS_COLLECTION)
            .where('uid', isEqualTo: userId)
            .get();

        if (membersSnapshot.docs.isNotEmpty) {
          print('User $userId found in room: $roomId');
        } else {
          print('User $userId not found at room: $roomId');
        }
      }
    } catch (e) {
      print('Error checking user in rooms: $e');
    }
  }

}
