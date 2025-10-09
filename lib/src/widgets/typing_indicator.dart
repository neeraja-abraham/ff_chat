import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    super.key,
    required this.chatRoomId,
    required this.currentUserId,
  });

  final String chatRoomId;
  final String currentUserId;
  // User? user = AuthService().getCurrentUser();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("typing/$chatRoomId").onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const SizedBox.shrink();
        }

        final typingData = snapshot.data!.snapshot.value as Map;

        typingData.remove(currentUserId); // exclude self

        if (typingData.containsValue(true)) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Typing...", style: TextStyle(color: Colors.grey)),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
