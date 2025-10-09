import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ff_chat/src/models/chat_message.dart';
import 'package:ff_chat/src/widgets/file_message_bubble.dart';
import 'package:ff_chat/src/widgets/video_message_bubble.dart';
import 'package:ff_chat/src/utils/format_utils.dart';

import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  const MessageBubble({required this.message, required this.isMe, super.key});

  @override
  Widget build(BuildContext context) {
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isMe ? Theme.of(context).primaryColor : Colors.grey.shade200;
    final textColor = isMe ? Colors.white : Colors.black87;

    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          margin: EdgeInsets.only(
            top: 4,
            bottom: 4,
            left: isMe ? 48 : 8,
            right: isMe ? 8 : 48,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _buildMessageContent(message, textColor, context),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
               formatTimestamp(message.createdAt.toDate()),
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              SizedBox(width: 6),
              if (isMe)
                Icon(
                  Icons.done_all,
                  size: 12,
                  color: message.readBy.contains(message.receiverId)
                      ? Colors.blue
                      : Colors.grey,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageContent(
    ChatMessage message,
    Color textColor,
    BuildContext context,
  ) {
    final height = MediaQuery.of(context).size.height * .25;
    final width = MediaQuery.of(context).size.width * .8;
    switch (message.type) {
      case MessageType.text:
        return Text(message.text ?? '', style: TextStyle(color: textColor));

      case MessageType.image:
        switch (message.messageStatus) {
          case MessageStatus.uploading:
            return LinearProgressIndicator();
          case MessageStatus.sent:
            return CachedNetworkImage(
              height: height,
              width: width,
              imageUrl: message.mediaDownloadUrl ?? '',
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.broken_image),
            );
          case MessageStatus.failed:
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.file(File(message.mediaDownloadUrl ?? '')),
                const Icon(Icons.error, color: Colors.red, size: 40),
              ],
            );
        }

      case MessageType.video:
        switch (message.messageStatus) {
          case MessageStatus.uploading:
            return LinearProgressIndicator();
          case MessageStatus.sent:
            return VideoMessageBubble(url: message.mediaDownloadUrl ?? '');
          case MessageStatus.failed:
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.file(File(message.mediaDownloadUrl ?? '')),
                const Icon(Icons.error, color: Colors.red, size: 40),
              ],
            );
        }

      case MessageType.file:
        switch (message.messageStatus) {
          case MessageStatus.uploading:
            return LinearProgressIndicator();
          case MessageStatus.sent:
            final fileName = Uri.parse(
              message.text ?? '',
            ).pathSegments.last.split('?').first;
            final safeFileName = fileName.contains('/')
                ? fileName.split('/').last
                : fileName;
            return FileMessageBubble(
              url: message.mediaDownloadUrl ?? '',
              fileName: safeFileName,
            );
          case MessageStatus.failed:
            return Stack(
              alignment: Alignment.center,
              children: [
                Image.file(File(message.mediaDownloadUrl ?? '')),
                const Icon(Icons.error, color: Colors.red, size: 40),
              ],
            );
        }
    }
  }
  
  
}
