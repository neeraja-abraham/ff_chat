// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ff_chat/src/services/chat_session_manager.dart'
//     show ChatSessionManager;
// import 'package:flutter/material.dart';

// import 'package:ff_chat/src/models/chat_message.dart';
// import 'package:ff_chat/src/services/auth_service.dart';
// import 'package:ff_chat/src/services/chat_service.dart';
// import 'package:ff_chat/src/services/media_service.dart';
// import 'package:ff_chat/src/services/presence_service.dart';
// import 'package:ff_chat/src/services/storage_service.dart';
// import 'package:ff_chat/src/widgets/message_bubble.dart';
// import 'package:ff_chat/src/widgets/presence_indicator.dart';
// import 'package:ff_chat/src/widgets/typing_indicator.dart';
// import 'package:ff_chat/src/widgets/user_input_field.dart';

// class ChatScreenUp extends StatefulWidget {
//   const ChatScreenUp({
//     super.key,
//     required this.receiverId,
//     required this.receiverEmail,
//   });

//   final String receiverId;
//   final String receiverEmail;

//   @override
//   State<ChatScreenUp> createState() => _ChatScreenUpState();
// }

// class _ChatScreenUpState extends State<ChatScreenUp> {
//   final _messageController = TextEditingController();
//   final _scrollController = ScrollController();
//   final _focusNode = FocusNode();

//   final _chatService = ChatService();
//   final _authService = AuthService();
//   final _mediaService = MediaService();
//   final _presenceService = PresenceService();
//   final _storageService = StorageService();

//   late final String _currentUserId;
//   late final String _chatRoomId;

//   String? _pendingMediaUrl;

//   @override
//   void initState() {
//     super.initState();

//     _currentUserId = _authService.getCurrentUser()?.uid ?? '';
//     _chatRoomId = _chatService.getChatRoomId(_currentUserId, widget.receiverId);

//     ChatSessionManager.setCurrentChatId(_chatRoomId);

//     _presenceService.init();
//     _setupTypingListener();
//     _setupFocusListener();
//   }

//   void _setupTypingListener() {
//     _messageController.addListener(() {
//       final isTyping = _messageController.text.isNotEmpty;
//       _presenceService.setTyping(_chatRoomId, isTyping);
//     });
//   }

//   void _setupFocusListener() {
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         Future.delayed(const Duration(milliseconds: 300), _scrollToBottom);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _scrollController.dispose();
//     _messageController.dispose();
//     ChatSessionManager.setCurrentChatId(null);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: _buildAppBar(context),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(child: _buildMessageList()),
//             TypingIndicator(chatRoomId: _chatRoomId),
//             _buildUserInput(),
//           ],
//         ),
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar(BuildContext context) {
//     return AppBar(
//       backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(widget.receiverEmail),
//           const SizedBox(width: 6),
//           PresenceIndicator(receiverId: widget.receiverId),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageList() {
//     return StreamBuilder<List<ChatMessage>>(
//       stream: _chatService.getMessages(_currentUserId, widget.receiverId),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Center(child: Text('Something went wrong: ${snapshot.error}'));
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         }

//         final messages = snapshot.data ?? [];

//         // Mark unread messages as read
//         for (final msg in messages) {
//           if (!msg.readBy.contains(_currentUserId)) {
//             _chatService.markMessageAsRead(_chatRoomId, msg.id);
//           }
//         }

//         // Scroll to bottom when new messages arrive
//         WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

//         return ListView.builder(
//           controller: _scrollController,
//           itemCount: messages.length,
//           itemBuilder: (context, index) {
//             final message = messages[index];
//             final isMe = message.senderId == _currentUserId;
//             return MessageBubble(message: message, isMe: isMe);
//           },
//         );
//       },
//     );
//   }

//   Widget _buildUserInput() {
//     return UserInputField(
//       onAttachmentTap: _openAttachmentOptions,

//       onSendTap: () {
//         handleSendMessage(
//           messageType: MessageType.text,
//           textMessage: _messageController.text,
//         );
//         _messageController.clear();
//       },
//       messageController: _messageController,
//     );
//   }

//   void _scrollToBottom() {
//     if (!_scrollController.hasClients) return;
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.easeOut,
//     );
//   }

//   void _openAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) => SafeArea(
//         child: Wrap(
//           children: [
//             _attachmentTile(
//               icon: Icons.image,
//               label: "Send Image",
//               pickAction: () =>
//                   pickAndSendMedia(MediaUploadType.image, MessageType.image),
//             ),
//             _attachmentTile(
//               icon: Icons.videocam,
//               label: "Send Video",
//               pickAction: () =>
//                   pickAndSendMedia(MediaUploadType.video, MessageType.video),
//             ),
//             _attachmentTile(
//               icon: Icons.insert_drive_file,
//               label: "Send File",
//               pickAction: () =>
//                   pickAndSendMedia(MediaUploadType.file, MessageType.file),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   ListTile _attachmentTile({
//     required IconData icon,
//     required String label,
//     required Future<void> Function() pickAction,
//   }) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(label),
//       onTap: () async {
//         Navigator.pop(context);
//         await pickAction();
//       },
//     );
//   }

//   Future<void> pickAndSendMedia(
//     MediaUploadType uploadType,
//     MessageType msgType,
//   ) async {
//     PickedMedia? media;
//     switch (uploadType) {
//       case MediaUploadType.image:
//         media = await _mediaService.pickImage();
//         break;
//       case MediaUploadType.video:
//         media = await _mediaService.pickVideo();
//         break;
//       case MediaUploadType.file:
//         media = await _mediaService.pickFile();
//         break;
//     }

//     final messageId = await handleSendMessage(messageType: msgType);
//     try {
//       if (media != null) {
//         final url = await _storageService.uploadFileToChat(
//           media: media,
//           chatId: _chatRoomId,
//           typeFolder: uploadType,
//         );

//         if (url != null) {
//           _pendingMediaUrl = url;
//           await _chatService.updateMessageMediaUrl(
//             chatId: _chatRoomId,
//             messageId: messageId,
//             downloadUrl: url,
//           );
//         }
//       }
//     } catch (e) {
//       await _chatService.updateMessageStatus(
//         _chatRoomId,
//         messageId,
//         MessageStatus.failed,
//       );
//     }
//   }

//   Future<String> handleSendMessage({
//     required MessageType messageType,
//     String? mediaUrl,
//     String? textMessage,
//   }) async {
//     late ChatMessage message;
//     switch (messageType) {
//       case MessageType.text:
//         if (textMessage?.isNotEmpty == true) {
//           message = ChatMessage(
//             id: '',
//             senderId: _currentUserId,
//             receiverId: widget.receiverId,
//             createdAt: Timestamp.now(),
//             text: textMessage,
//             mediaDownloadUrl: _pendingMediaUrl,
//             type: MessageType.text,
//             messageStatus: MessageStatus.sent,
//           );
//         }
//       case MessageType.image:
//         message = ChatMessage(
//           id: '',
//           senderId: _currentUserId,
//           receiverId: widget.receiverId,
//           createdAt: Timestamp.now(),
//           text: '[[Image]]',
//           mediaDownloadUrl: _pendingMediaUrl,
//           type: MessageType.image,
//           messageStatus: MessageStatus.uploading,
//         );
//       case MessageType.video:
//         message = ChatMessage(
//           id: '',
//           senderId: _currentUserId,
//           receiverId: widget.receiverId,
//           createdAt: Timestamp.now(),
//           text: '[[Video]]',
//           mediaDownloadUrl: _pendingMediaUrl,
//           type: MessageType.video,
//           messageStatus: MessageStatus.uploading,
//         );
//       case MessageType.file:
//         message = ChatMessage(
//           id: '',
//           senderId: _currentUserId,
//           receiverId: widget.receiverId,
//           createdAt: Timestamp.now(),
//           text: '[[File]]',
//           mediaDownloadUrl: _pendingMediaUrl,
//           type: MessageType.file,
//           messageStatus: MessageStatus.uploading,
//         );
//     }

//     String messageId = await _chatService.sendMessage(_chatRoomId, message);
//     return messageId;
//   }
// }
