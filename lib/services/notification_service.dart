import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:chat_app/services/auth/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging
      .instance;

  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'chat_channel',
          channelName: 'Chat Notifications',
          channelDescription: 'Notification channel for chat messages',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          playSound: true,
          enableVibration: true,
        ),
      ],
    );

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(message);
    });

    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print("FCM Token: $token");
      await _updateDeviceToken(token);
    }
  }

  static Future<void> _updateDeviceToken(String token) async {
    if (_auth.currentUser != null) {
      await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
        'deviceToken': token,
      });
    }
  }

  static Future<void> _handleMessage(RemoteMessage message) async {
    if (message.notification != null) {
      String? title = message.notification!.title;
      String? body = message.notification!.body;
      String? roomId = message.data['roomId'];

      if (title != null && body != null && roomId != null) {
        await showNotification(
          receiverId: message.data['receiverId'],
          title: title,
          message: body,
          roomId: roomId,
        );
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    final roomId = receivedAction.payload?['roomId'];
    final receiverId = receivedAction.payload?['receiverId'];
    if (roomId != null) {}
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma('vm:entry-point')
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  static Future<void> showNotification({
    required String title,
    required String message,
    required String roomId,
    required String receiverId,
  }) async {
    final currentUserId = await AuthMethod().getCurrentUserId();

    if (receiverId == currentUserId) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime
              .now()
              .millisecondsSinceEpoch
              .remainder(100000),
          channelKey: 'chat_channel',
          title: title,
          body: message,
          payload: {'roomId': roomId},
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Message,
        ),
      );
      print("Notifikasi ditampilkan untuk user: $currentUserId");
    } else {
      print("Notifikasi tidak ditampilkan untuk user: $currentUserId");
    }
  }

}

