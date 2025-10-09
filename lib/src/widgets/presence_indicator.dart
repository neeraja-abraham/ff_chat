import 'package:ff_chat/src/utils/format_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class PresenceIndicator extends StatelessWidget {
  const PresenceIndicator({super.key, required this.receiverId});
  final String receiverId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance.ref("status/$receiverId").onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
          return const SizedBox.shrink();
        }

        final status = (snapshot.data!.snapshot.value as Map)["state"];
        final lastSeen = (snapshot.data!.snapshot.value as Map)["last_changed"];
        if (status == "online") {
          return Text(
            status == "online" ? "● Online" : "",
            style: TextStyle(
              fontSize: 12,
              color: status == "online" ? Colors.green : Colors.red,
            ),
          );
        }
        if (status != "online" && lastSeen != null) {
          return Text(
            'Last seen: ${formatLastSeen(DateTime.fromMillisecondsSinceEpoch(lastSeen))}',
            style: Theme.of(context).textTheme.labelSmall,
          );
        }
        return SizedBox();
      },
    );
  }
}
