import 'package:ff_chat/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ff_chat/ff_chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ff_chat Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatScreenPub(
        currentUserId: 'user_1',
        receiverId: 'user_2',
        receiverEmail: 'user2@gmail.com',
      ),
    );
  }
}
