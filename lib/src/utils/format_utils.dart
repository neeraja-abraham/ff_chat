  import 'package:intl/intl.dart';

String formatLastSeen(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24 && now.day == timestamp.day) {
      // Same day
      return "Today at ${DateFormat('h:mm a').format(timestamp)}";
    } else if (difference.inHours < 48 && now.day - timestamp.day == 1) {
      // Yesterday
      return "Yesterday at ${DateFormat('h:mm a').format(timestamp)}";
    } else if (now.year == timestamp.year) {
      // Same year
      return DateFormat(
        'MMM d, h:mm a',
      ).format(timestamp); // e.g., Sep 22, 4:30 PM
    } else {
      // Older (different year)
      return DateFormat(
        'MMM d, yyyy, h:mm a',
      ).format(timestamp); // e.g., Sep 22, 2024, 4:30 PM
    }
  }

  String formatTimestamp(DateTime dateTime) {
  final localTime = dateTime.toLocal();
  final now = DateTime.now();

  final isToday = localTime.year == now.year &&
      localTime.month == now.month &&
      localTime.day == now.day;

  if (isToday) {
    // e.g., "11:45 AM"
    return DateFormat.jm().format(localTime);
  } else {
    // e.g., "Oct 5, 11:45 AM"
    return DateFormat('MMM d, h:mm a').format(localTime);
  }
}
