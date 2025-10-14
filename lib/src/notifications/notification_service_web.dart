import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

Future<void> setupFCM({
  required String currentUserId,
  required String vapidKey,
}) async {
  debugPrint(':::Setting up FCMWeb ');
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken(vapidKey: vapidKey);

  if (token != null) await saveTokenToFirestore(currentUserId, token);

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await saveTokenToFirestore(currentUserId, newToken);
  });

  //Excluded notification when page is in foreground. Uncomment the
  //code below if foreground notifications needed.

  // FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //   if (web.document.hasFocus()) {
  //     final title = message.notification?.title ?? 'New message';
  //     final body = message.notification?.body ?? '';

  //     final permission = await web.Notification.requestPermission().toDart;
  //     if (permission == 'granted') {
  //       web.Notification(title, web.NotificationOptions(body: body));
  //     }
  //   }
  // });

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
    'platform': 'web',
  });
}
