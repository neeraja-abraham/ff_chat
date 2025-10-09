// import 'package:ff_chat/src/pages/chat_screen.dart';
// import 'package:ff_chat/src/pages/chat_screen_up.dart';
// import 'package:ff_chat/src/services/auth_service.dart';
// import 'package:ff_chat/src/services/chat_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// import '../notifications/notification_service.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();

//   @override
//   void initState() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       setupFCM(user.uid);
//     }
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,

//         title: Text('Home'),
//         actions: [IconButton(icon: Icon(Icons.logout), onPressed: logOut)],
//       ),
//       body: _buildUsersList(),
//     );
//   }

//   void logOut() {
//     final AuthService authService = AuthService();
//     authService.signout();
//     removeTokenOnSignOut(authService.getCurrentUser()?.uid ?? '');
//   }

//   Widget _buildUsersList() {
//     return StreamBuilder(
//       stream: _chatService.getUsersStream(),
//       builder: (context, snapshot) {
//         if (snapshot.hasError) {
//           return Text('Something went wrong!');
//         }
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return CircularProgressIndicator();
//         }
//         if (snapshot.hasData) {
//           return ListView(
//             children: snapshot.data!
//                 .map<Widget>((userData) => _buildUserTile(userData, context))
//                 .toList(),
//           );
//         }
//         return SizedBox();
//       },
//     );
//   }

//   Widget _buildUserTile(Map<String, dynamic> userData, BuildContext context) {
//     if (userData['email'] != _authService.getCurrentUser()?.email) {
//       return UserTile(
//         email: userData['email'],
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ChatScreenUp(
//                 receiverId: userData['uid'],
//                 receiverEmail: userData['email'],
//               ),
//             ),
//           );
//         },
//       );
//     } else {
//       return SizedBox();
//     }
//   }
// }

// class UserTile extends StatefulWidget {
//   const UserTile({super.key, required this.email, required this.onTap});

//   final String email;
//   final VoidCallback onTap;

//   @override
//   State<UserTile> createState() => _UserTileState();
// }

// class _UserTileState extends State<UserTile> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.primaryFixedDim,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         margin: EdgeInsets.all(8),
//         padding: const EdgeInsets.all(16.0),
//         child: Row(children: [Icon(Icons.person), Text(widget.email)]),
//       ),
//     );
//   }
// }
