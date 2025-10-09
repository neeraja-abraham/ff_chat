import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum MessageType { text, image, video, file }

enum MessageStatus { uploading, sent, failed }

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String? text;
  final MessageType type;
  final String? mediaDownloadUrl;
  final List<Map<String, dynamic>> attachments;
  final Timestamp createdAt;
  final Timestamp? editedAt;
  final bool deleted;
  final List<String> readBy;
  final Map<String, dynamic>? metadata;
  final MessageStatus messageStatus;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.text,
    this.type = MessageType.text,
    this.mediaDownloadUrl,
    this.attachments = const [],
    required this.createdAt,
    this.editedAt,
    this.deleted = false,
    this.readBy = const [],
    this.metadata,
    required this.messageStatus,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ChatMessage(
      id: doc.id,
      messageStatus: MessageStatus.values.firstWhere(
        (e) => e.name == (d['messageStatus'] ?? 'sent'),
        orElse: () => MessageStatus.sent,
      ),
      senderId: d['senderId'] as String? ?? '',
      receiverId: d['receiverId'] as String? ?? '',
      text: d['text'] as String?,
      mediaDownloadUrl: d['mediaDownloadUrl'] as String?,
      type: _stringToMessageType(d['type'] as String? ?? 'text'),
      attachments: List<Map<String, dynamic>>.from(d['attachments'] ?? []),
      createdAt: d['createdAt'] as Timestamp? ?? Timestamp.now(),
      editedAt: d['editedAt'] as Timestamp?,
      deleted: d['deleted'] as bool? ?? false,
      readBy: List<String>.from(d['readBy'] ?? []),
      metadata: d['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toDoc() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'messageStatus': _messageStatusToString(messageStatus),
      'text': text,
      'type': _messageTypeToString(type),
      'attachments': attachments,
      'mediaDownloadUrl': mediaDownloadUrl,
      'createdAt': createdAt,
      'editedAt': editedAt,
      'deleted': deleted,
      'readBy': readBy,
      'metadata': metadata,
    }..removeWhere((k, v) => v == null);
  }

  static String _messageTypeToString(MessageType type) {
    debugPrint(':::${type.toString().split('.').last}');
    return type.toString().split('.').last; // "MessageType.text" → "text"
  }

  static String _messageStatusToString(MessageStatus status) {
    debugPrint(':::${status.toString().split('.').last}');
    return status.toString().split('.').last; // "MessageType.text" → "text"
  }

  static MessageType _stringToMessageType(String typeStr) {
    switch (typeStr) {
      case 'image':
        return MessageType.image;
      case 'video':
        return MessageType.video;
      case 'file':
        return MessageType.file;

      default:
        return MessageType.text;
    }
  }
}
