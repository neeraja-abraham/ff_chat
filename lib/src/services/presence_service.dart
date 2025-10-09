import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PresenceService with WidgetsBindingObserver {
  final user = FirebaseAuth.instance.currentUser!;
  final dbRef = FirebaseDatabase.instance;

  final connectedData = {
    "state": "online",
    "last_changed": ServerValue.timestamp,
  };

  final disConnectedData = {
    "state": "offline",
    "last_changed": ServerValue.timestamp,
  };

  init() {
    WidgetsBinding.instance.addObserver(this);
    setUserPresence();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final statusRef = dbRef.ref("status/${user.uid}");

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      statusRef.set(disConnectedData);
    } else if (state == AppLifecycleState.resumed) {
      statusRef.set(disConnectedData);
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> setUserPresence() async {
    final statusRef = dbRef.ref("status/${user.uid}");
    await statusRef.onDisconnect().set(disConnectedData);
    await statusRef.set(connectedData);
  }

  Future<void> setTyping(String chatId, bool isTyping) async {
    final typingRef = FirebaseDatabase.instance.ref(
      "typing/$chatId/${user.uid}",
    );
    await typingRef.set(isTyping);
  }
}
