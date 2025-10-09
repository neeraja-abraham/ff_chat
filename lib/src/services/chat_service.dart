import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ff_chat/src/models/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatService {
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  final String currentUserId;

  ChatService({required this.currentUserId});

  //Fetch Users
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _store.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  //send message

  Future<String> sendMessage(String chatRoomId, ChatMessage message) async {
    final messageDoc = await _store
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .add(message.toDoc());

    return messageDoc.id;
  }

  Future<String> createMessageId() async => Uuid().v4();

  //get messages

  Stream<List<ChatMessage>> getMessages(String senderId, String receiverId) {
    String chatRoomId = getChatRoomId(senderId, receiverId);

    return _store
        .collection("chat_rooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("createdAt", descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((d) => ChatMessage.fromDoc(d)).toList());
  }

  Future<void> markMessageAsRead(String chatId, String messageId) async {
    // final uid = AuthService().getCurrentUser()?.uid;

    //if (uid == null) return;

    final msgRef = _store
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId);

    try {
      final docSnapshot = await msgRef.get();
      if (docSnapshot.exists) {
        // Document exists, update it
        await msgRef.update({
          'readBy': FieldValue.arrayUnion([currentUserId]),
        });
      }
    } catch (e) {
      debugPrint(":::Error updating document: $e");
    }
  }

  String getChatRoomId(String senderId, String receiverId) {
    List<String> ids = [senderId, receiverId];
    ids.sort();
    return ids.join('_');
  }

  Future<void> updateMessageMediaUrl({
    required String chatId,
    required String messageId,
    required String downloadUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({
          'mediaDownloadUrl': downloadUrl,
          'text': downloadUrl,
          'messageStatus': MessageStatus.sent.name,
        });
  }

  Future<void> updateMessageStatus(
    String chatId,
    String messageId,
    MessageStatus status,
  ) async {
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'messageStatus': status.name});
  }
}
