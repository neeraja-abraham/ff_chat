// import 'package:ff_chat/src/notifications/notification_handler.dart';
// import 'package:ff_chat/src/pages/signup_screen.dart';
// import 'package:ff_chat/src/services/auth_service.dart';
// import 'package:flutter/material.dart';

// import '../notifications/notification_service.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   void _login() async {
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();

//     try {
//       AuthService authService = AuthService();
//       final user = await authService.signInWithEmailAndPassword(
//         email,
//         password,
//       );

//       if (user != null) {
//         //await setupFCMForUser(user.user?.uid ?? '');
//         await setupFCM(user.user?.uid ?? '');
//       }
//     } catch (e) {
//       debugPrint('Error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 "Login",
//                 style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 40),

//               // Email Field
//               TextField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(
//                   labelText: "Email",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.email),
//                 ),
//                 keyboardType: TextInputType.emailAddress,
//               ),
//               const SizedBox(height: 20),

//               // Password Field
//               TextField(
//                 controller: _passwordController,
//                 decoration: const InputDecoration(
//                   labelText: "Password",
//                   border: OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.lock),
//                 ),
//                 obscureText: true,
//               ),
//               const SizedBox(height: 30),

//               // Login Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _login,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: const Text("Login", style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//               SizedBox(height: 20),

//               InkWell(
//                 onTap: () => Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const SignUpScreen()),
//                 ),
//                 child: Text('Sign up', style: TextStyle(color: Colors.blue)),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
