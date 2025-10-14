import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_chat/src/models/chat_message.dart';
import 'package:ff_chat/src/services/chat_session_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint("Mobile background message: ${message.notification?.title}");
}

Future<void> setupFCM({
  required String currentUserId,
  required String vapidKey,
}) async {
  debugPrint('>>>Setting up FCM');
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final token = await messaging.getToken();
  if (token != null) await saveTokenToFirestore(currentUserId, token);

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await saveTokenToFirestore(currentUserId, newToken);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;
    final incomingChatId = message.data['chatId'];
    final messageStatus = message.data['messageStatus'];

    if (incomingChatId != null &&
        incomingChatId == ChatSessionManager.currentChatId) {
      debugPrint('Skipping notification for open chat: $incomingChatId');
      return;
    }
    if (notification != null && messageStatus == MessageStatus.sent.name) {
      const NotificationDetails androidDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'chat_messages',
          'Chat Messages',
          channelDescription: 'Notification channel for chat messages',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        androidDetails,
      );
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final chatId = message.data['chatId'];
    if (chatId != null) {
      // Navigate to chat screen
    }
  });
}

Future<void> saveTokenToFirestore(String uid, String token) async {
  final tokensRef = FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('fcmTokens');
  await tokensRef.doc(token).set({
    'token': token,
    'createdAt': FieldValue.serverTimestamp(),
    'platform': Platform.operatingSystem,
  });
}
