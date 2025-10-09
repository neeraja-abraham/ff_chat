import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

Future<void> setupFCM(String uid) async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(alert: true, badge: true, sound: true);

  final token = await messaging.getToken(
    vapidKey:
        'BDjklMFCrOwY92Ra6ykDqxJh8Teca9vyF41hAOnNt82D3KuUNv72cz07Vr-meHLVLGPmpkQwhjZHnnWQhNNVHV8',
  );

  if (token != null) await saveTokenToFirestore(uid, token);

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    await saveTokenToFirestore(uid, newToken);
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    final title = message.notification?.title ?? 'New message';
    final body = message.notification?.body ?? '';

    final permission = await web.Notification.requestPermission().toDart;
    if (permission == 'granted') {
      web.Notification(title, web.NotificationOptions(body: body));
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
    'platform': 'web',
  });
}
