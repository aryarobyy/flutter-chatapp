import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static Future<void> initializeNotification() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        final currentUserId = await AuthMethod().getCurrentUserId();
        await _firestore.collection('users').doc(currentUserId).update({
          'fcmToken': token,
        });
        print("FCM Token saved: $token");
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) async {
        final currentUserId = await AuthMethod().getCurrentUserId();
        await _firestore.collection('users').doc(currentUserId).update({
          'fcmToken': newToken,
        });
      });

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

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Received foreground message: ${message.notification?.title}");

        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            channelKey: 'chat_channel',
            title: message.notification?.title ?? '',
            body: message.notification?.body ?? '',
            category: NotificationCategory.Message,
            notificationLayout: NotificationLayout.Messaging,
            payload: message.data.map((key, value) => MapEntry(key, value.toString())),
          ),
        );
      });


      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          print("App opened from terminated state with message: ${message.notification?.title}");
        }
      });

      await AwesomeNotifications().requestPermissionToSendNotifications();
    } catch (e) {
      print("Error initializing notifications: $e");
    }
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
      final receiverDoc = await _firestore.collection('users').doc(receiverId).get();

      final senderName = senderDoc.data()?['name'] ?? 'Unknown';
      final receiverToken = receiverDoc.data()?['fcmToken'];

      if (currentUserId != receiverId && receiverToken != null) {
        print("Sending notification to receiver token: $receiverToken");

        await _firestore.collection('chat_notifications').add({
          'receiverToken': receiverToken,
          'title': "Message from $senderName",
          'body': message,
          'senderId': currentUserId,
          'receiverId': receiverId,
          'roomId': roomId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false
        });

        print("Notification data saved for receiver");
      } else {
        print("Skip sending notification - currentUser: $currentUserId, receiverId: $receiverId");
      }
    } catch (e) {
      print("Error in showNotification: $e");
    }
  }
}