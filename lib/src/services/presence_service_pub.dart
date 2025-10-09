// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PresenceServicePub with WidgetsBindingObserver {
  final String userId;
  PresenceServicePub({required this.userId});
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
    final statusRef = dbRef.ref("status/${userId}");

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      statusRef.set(disConnectedData);
    } else if (state == AppLifecycleState.resumed) {
      statusRef.set(connectedData);
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<void> setUserPresence() async {
    final statusRef = dbRef.ref("status/$userId");
    await statusRef.onDisconnect().set(disConnectedData);
    await statusRef.set(connectedData);
  }

  Future<void> setTyping(String chatId, bool isTyping) async {
    final typingRef = FirebaseDatabase.instance.ref("typing/$chatId/$userId");
    await typingRef.set(isTyping);
  }
}
