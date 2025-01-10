import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static StreamSubscription<QuerySnapshot>? _notificationSubscription;

  static Future<void> initializeNotification() async {
    try {
      // Initialize local notifications
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

      // Start listening to notifications
      await listenToNotifications();
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  static Future<void> listenToNotifications() async {
    final currentUserId = await AuthMethod().getCurrentUserId();

    // Cancel existing subscription if any
    await _notificationSubscription?.cancel();

    // Listen to new notifications
    _notificationSubscription = _firestore
        .collection('chat_notifications')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final notification = change.doc.data() as Map<String, dynamic>;

          // Show local notification
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

          // Mark notification as read
          await change.doc.reference.update({'isRead': true});
        }
      }
    });
  }

  static Future<void> showNotification({
    required String receiverId,
    required String title,
    required String message,
    required String roomId,
  }) async {
    try {
      final currentUserId = await AuthMethod().getCurrentUserId();
      final senderDoc = await _firestore.collection('users').doc(currentUserId).get();
      final senderName = senderDoc.data()?['name'] ?? 'Unknown';

      if (currentUserId != receiverId) {
        await _firestore.collection('chat_notifications').add({
          'title': "Message from $senderName",
          'body': message,
          'senderId': currentUserId,
          'receiverId': receiverId,
          'roomId': roomId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

        print("Notification data saved for receiver");
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