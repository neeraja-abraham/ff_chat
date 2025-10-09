// notification_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

export 'notification_service_stub.dart'
    if (dart.library.html) 'notification_service_web.dart'
    if (dart.library.io) 'notification_service_mobile.dart';

Future<void> removeTokenOnSignOut(String uid) async {
  final token = await FirebaseMessaging.instance.getToken();
  if (token == null) return;

  await FirebaseFirestore.instance
      .collection('Users')
      .doc(uid)
      .collection('fcmTokens')
      .doc(token)
      .delete();
}
