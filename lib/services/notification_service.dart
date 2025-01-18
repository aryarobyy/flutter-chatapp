import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static StreamSubscription<QuerySnapshot>? _notificationSubscription;
  final AuthService _auth = AuthService();
  static Future<void> initializeNotification() async {
    try {
      await AwesomeNotifications().initialize(
        null,
        [
          NotificationChannel(
            channelKey: 'chat_channel',
            channelName: 'Chat Notifications',
            channelDescription: 'Notification channel for chat messages',
            defaultColor: Colors.blue,
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            playSound: true,
            enableVibration: true,
            enableLights: true,
          ),
        ],
      );

      await AwesomeNotifications().requestPermissionToSendNotifications();

      await listenToNotifications();
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  static Future<void> listenToNotifications() async {
    try {
      final currentUserId = await AuthService().getCurrentUserId();
      if (currentUserId == null) return;

      await _notificationSubscription?.cancel();

      _notificationSubscription = _firestore
          .collection('chat_notifications')
          .where('receiverId', arrayContains: currentUserId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) async {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final notification = change.doc.data() as Map<String, dynamic>;

            if (notification['isRead'] == false) {
              try {
                await AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
                    channelKey: 'chat_channel',
                    title: notification['title'],
                    body: notification['body'],
                    notificationLayout: NotificationLayout.Default,
                    payload: {
                      'roomId': notification['roomId'],
                      'senderId': notification['senderId'],
                    },
                  ),
                );

                await change.doc.reference.update({'isRead': true});
              } catch (e) {
                print("Error showing notification: $e");
              }
            }
          }
        }
      }, onError: (error) {
        print("Error in notification listener: $error");
      });
    } catch (e) {
      print("Error in listenToNotifications: $e");
    }
  }

  static Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      return userDoc.data()?['name'] ?? 'Unknown User';
    } catch (e) {
      print("Error getting user name: $e");
      return 'Unknown User';
    }
  }

  static Future<void> showNotification({
    required List<String> receiverIds,
    required String title,
    required String message,
    required String roomId,
  }) async {
    try {
      final currentUserId = await AuthService().getCurrentUserId();

      final filteredReceivers = receiverIds.where((id) => id != currentUserId).toList();
      if (filteredReceivers.isNotEmpty) {
        await _firestore.collection('chat_notifications').add({
          'title': title,
          'body': message,
          'senderId': currentUserId,
          'receiverId': filteredReceivers,
          'roomId': roomId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      }
    } catch (e) {
      print("Error in showNotification: $e");
    }
  }

  // Call this when logging out or disposing
  static Future<void> dispose() async {
    await _notificationSubscription?.cancel();
  }
}
