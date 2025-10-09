// import 'package:ff_chat/src/pages/home_screen.dart';
// import 'package:ff_chat/src/pages/login_screen.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           //logged in
//           if (snapshot.hasData) {
//             return const HomeScreen();
//           }
//           //logged out
//           else {
//             return const LoginScreen();
//           }
//         },
//       ),
//     );
//   }
// }
