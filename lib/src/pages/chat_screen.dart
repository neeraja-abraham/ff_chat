// import 'dart:async';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:ff_chat/src/models/chat_message.dart';
// import 'package:ff_chat/src/services/auth_service.dart';
// import 'package:ff_chat/src/services/chat_service.dart';
// import 'package:ff_chat/src/services/chat_session_manager.dart';
// import 'package:ff_chat/src/services/media_service.dart';
// import 'package:ff_chat/src/services/presence_service.dart';
// import 'package:ff_chat/src/services/storage_service.dart';
// import 'package:ff_chat/src/widgets/message_bubble.dart';
// import 'package:ff_chat/src/widgets/presence_indicator.dart';
// import 'package:ff_chat/src/widgets/typing_indicator.dart';
// import 'package:ff_chat/src/widgets/user_input_field.dart';
// import 'package:flutter/material.dart';

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({
//     super.key,
//     required this.receiverId,
//     required this.receiverEmail,
//   });

//   final String receiverId;
//   final String receiverEmail;

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();

//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();
//   final MediaService _mediaService = MediaService();
//   final PresenceService _presenceService = PresenceService();
//   final StorageService _storageService = StorageService();

//   String _currentUserId = '';
//   String chatRoomId = '';
//   final FocusNode _focusNode = FocusNode();
//   String? downloadUrl;
//   MessageType _messageType = MessageType.text;

//   @override
//   void initState() {
//     _currentUserId = _authService.getCurrentUser()?.uid ?? '';
//     chatRoomId = _chatService.getChatRoomId(
//       _authService.getCurrentUser()?.uid ?? '',
//       widget.receiverId,
//     );

//     ChatSessionManager.setCurrentChatId(chatRoomId);

//     /// Set presence when entering chat
//     _presenceService.init();

//     /// Listen for typing
//     _messageController.addListener(() {
//       if (_messageController.text.isNotEmpty) {
//         _presenceService.setTyping(chatRoomId, true);
//       } else {
//         _presenceService.setTyping(chatRoomId, false);
//       }
//     });
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         Future.delayed(const Duration(milliseconds: 500), () => _scrollDown());
//       }
//     });
//     super.initState();
//   }

//   final ScrollController _scrollController = ScrollController();
//   void _scrollDown() {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(milliseconds: 200),
//       curve: Curves.fastOutSlowIn,
//     );
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _scrollController.dispose();
//     ChatSessionManager.setCurrentChatId(null);
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.receiverEmail),
//             const SizedBox(width: 6),
//             _buildPresenceIndicator(widget.receiverId),
//           ],
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(child: _buildMessageList()),
//             _buildTypingIndicator(),
//             _buildUserInput(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageList() {
//     String senderId = _authService.getCurrentUser()?.uid ?? '';
//     return StreamBuilder(
//       stream: _chatService.getMessages(senderId, widget.receiverId),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Something went wrong ${snapshot.error}');
//         }

//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }

//         if (snapshot.hasData) {
//           WidgetsBinding.instance.addPostFrameCallback((_) => _scrollDown());

//           for (ChatMessage message in snapshot.data ?? []) {
//             if (!message.readBy.contains(_authService.getCurrentUser()?.uid)) {
//               _chatService.markMessageAsRead(chatRoomId, message.id);
//             }
//           }
//           return ListView(
//             controller: _scrollController,
//             children:
//                 snapshot.data
//                     ?.map((message) => _buildMessageItem(message))
//                     .toList() ??
//                 [],
//           );
//         }
//         return SizedBox();
//       },
//     );
//   }

//   Widget _buildMessageItem(ChatMessage message) {
//     bool isMe = _authService.getCurrentUser()?.uid == message.senderId;
//     return MessageBubble(message: message, isMe: isMe);
//   }

//   void _openAttachmentOptions() {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return SafeArea(
//           child: Wrap(
//             children: [
//               ListTile(
//                 leading: const Icon(Icons.image),
//                 title: const Text("Send Image"),
//                 onTap: () async {
//                   Navigator.pop(context);

//                   PickedMedia? pickedMedia = await _mediaService.pickImage();
//                   if (pickedMedia != null) {
//                     downloadUrl = await _storageService.uploadFileToChat(
//                       media: pickedMedia,
//                       chatId: chatRoomId,
//                       typeFolder: MediaUploadType.image,
//                     );
//                     _messageController.text = downloadUrl ?? '';
//                     _messageType = MessageType.image;
//                     _sendMessage();
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.videocam),
//                 title: const Text("Send Video"),
//                 onTap: () async {
//                   Navigator.pop(context);
//                   //File? file = await _mediaService.pickImage();
//                   PickedMedia? pickedMedia = await _mediaService.pickVideo();
//                   if (pickedMedia != null) {
//                     downloadUrl = await _storageService.uploadFileToChat(
//                       media: pickedMedia,
//                       chatId: chatRoomId,
//                       typeFolder: MediaUploadType.video,
//                     );
//                     _messageController.text = downloadUrl ?? '';
//                     _messageType = MessageType.video;
//                     _sendMessage();
//                   }
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.insert_drive_file),
//                 title: const Text("Send File"),
//                 onTap: () async {
//                   Navigator.pop(context);

//                   PickedMedia? pickedMedia = await _mediaService.pickFile();
//                   if (pickedMedia != null) {
//                     downloadUrl = await _storageService.uploadFileToChat(
//                       media: pickedMedia,
//                       chatId: chatRoomId,
//                       typeFolder: MediaUploadType.file,
//                     );
//                     _messageController.text = downloadUrl ?? '';
//                     _messageType = MessageType.file;
//                     _sendMessage();
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildUserInput() {
//     return UserInputField(
//       onAttachmentTap: _openAttachmentOptions,
//       onSendTap: _sendMessage,
//       messageController: _messageController,
//     );
//   }

//   void _sendMessage() async {
//     final messageId = await _chatService.createMessageId();
//     ChatMessage message;

//     if (downloadUrl != null) {
//       message = ChatMessage(
//         id: messageId,
//         mediaDownloadUrl: downloadUrl,
//         text: downloadUrl,
//         senderId: _currentUserId,
//         receiverId: widget.receiverId,
//         createdAt: Timestamp.now(),
//         type: _messageType,
//         messageStatus: MessageStatus.sent,
//       );
//     } else {
//       message = ChatMessage(
//         id: messageId,
//         text: _messageController.text,
//         receiverId: widget.receiverId,
//         senderId: _currentUserId,
//         createdAt: Timestamp.now(),
//         type: MessageType.text,
//         messageStatus: MessageStatus.sent,
//       );
//     }

//     await _chatService.sendMessage(chatRoomId, message);

//     _messageController.clear();
//   }

//   _buildTypingIndicator() {
//     return TypingIndicator(chatRoomId: chatRoomId);
//   }

//   _buildPresenceIndicator(String receiverId) {
//     return PresenceIndicator(receiverId: receiverId);
//   }
// }
