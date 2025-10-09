import 'package:flutter/material.dart';

class UserInputField extends StatefulWidget {
  const UserInputField({
    super.key,
    required this.onAttachmentTap,
    required this.onSendTap,
    required this.messageController,
  });

  final VoidCallback onAttachmentTap;
  final VoidCallback onSendTap;

  final TextEditingController messageController;

  @override
  State<UserInputField> createState() => _UserInputFieldState();
}

class _UserInputFieldState extends State<UserInputField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      color: Colors.grey[200],
      child: Row(
        children: [
          // '+' button for attachments
          IconButton(
            icon: const Icon(Icons.add, color: Colors.blue),
            onPressed: widget.onAttachmentTap,
          ),

          // Text Field
          Expanded(
            child: TextField(
              controller: widget.messageController,
              decoration: InputDecoration(
                hintText: "Type a message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 0,
                ),
              ),
            ),
          ),

          const SizedBox(width: 6),

          // Send Button
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: widget.onSendTap,
            ),
          ),
        ],
      ),
    );
  }
}
