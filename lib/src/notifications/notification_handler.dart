// import 'package:ff_chat/main.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
// import 'package:flutter/material.dart';
// import 'dart:js_interop';
// import 'package:web/web.dart' as web;

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// // Background handler (must be a top-level function)
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   if (message.notification != null) {
//     final notification = message.notification!;
//     debugPrint("Background message: ${notification.title}");
//   }

//   if (message.data.isNotEmpty) {
//     debugPrint("Data: ${message.data}");
//   }
// }

// Future<void> setupFCMForUser(String uid) async {
//   // initialize and permission request (iOS)
//   FirebaseMessaging messaging = FirebaseMessaging.instance;

//   // Request permission (iOS)
//   NotificationSettings settings = await messaging.requestPermission(
//     alert: true,
//     badge: true,
//     sound: true,
//   );

//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

//   String? token;

//   if (kIsWeb) {
//     token = await messaging.getToken(
//       vapidKey:
//           'BDjklMFCrOwY92Ra6ykDqxJh8Teca9vyF41hAOnNt82D3KuUNv72cz07Vr-meHLVLGPmpkQwhjZHnnWQhNNVHV8',
//     );
//   } else {
//     token = await messaging.getToken();
//   }

//   debugPrint('TOKEN ::: $token');
//   if (token != null) await saveTokenToFirestore(uid, token);

//   // Listen to token refresh
//   FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//     await saveTokenToFirestore(uid, newToken);
//   });

//   // When app is in foreground
//   FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
//     debugPrint('Foreground message: ${message.notification?.title}');

//     final title = message.notification?.title ?? 'New message';
//     final body = message.notification?.body ?? '';

//     // Convert JSPromise to Dart Future

//     if (message.notification != null) {
//       //Configuration for web
//       if (kIsWeb) {
//         final permission = await web.Notification.requestPermission().toDart;

//         if (permission == 'granted') {
//           web.Notification(title, web.NotificationOptions(body: body));
//         } else {
//           debugPrint('🔔 Notification permission not granted');
//         }
//       } else {
//         //Android Notification
//         final notification = message.notification!;
//         final androidDetails = AndroidNotificationDetails(
//           'chat_messages', // channel ID
//           'Chat Messages', // channel name
//           channelDescription: 'Notification channel for chat messages',
//           importance: Importance.max,
//           priority: Priority.high,
//           ticker: 'ticker',
//         );

//         const NotificationDetails platformDetails = NotificationDetails(
//           android: AndroidNotificationDetails(
//             'chat_messages',
//             'Chat Messages',
//             channelDescription: 'Notification channel for chat messages',
//             importance: Importance.max,
//             priority: Priority.high,
//           ),
//         );

//         flutterLocalNotificationsPlugin.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           platformDetails,
//         );
//       }
//     }
//   });

//   // When user taps a notification (from background/terminated)
//   FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     final data = message.data;
//     final chatId = data['chatId'];
//     if (chatId != null) {
//       // navigate to chat screen using your app's navigator
//     }
//   });
// }

// Future<void> saveTokenToFirestore(String uid, String token) async {
//   final tokensRef = FirebaseFirestore.instance
//       .collection('Users')
//       .doc(uid)
//       .collection('fcmTokens');

//   // store token as document id to dedupe easily
//   await tokensRef.doc(token).set({
//     'token': token,
//     'createdAt': FieldValue.serverTimestamp(),
//     'platform': kIsWeb
//         ? 'web'
//         : defaultTargetPlatform.toString().split('.').last, // avoids dart:io,
//   });
// }
