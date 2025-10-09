// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class AuthService {
//   final FirebaseAuth _authService = FirebaseAuth.instance;
//   final FirebaseFirestore _store = FirebaseFirestore.instance;

//   //signin
//   Future<UserCredential?> signInWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       final credential = await _authService.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );

//       //Save it in the cloud store

//       _store.collection("Users").doc(credential.user?.uid).set({
//         'uid': credential.user?.uid,
//         'email': credential.user?.email,
//       });

//       return credential;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'user-not-found') {
//         throw ('No user found for that email.');
//       } else if (e.code == 'wrong-password') {
//         throw ('Wrong password provided for that user.');
//       }
//       return null;
//     }
//   }

//   //signup

//   Future<UserCredential?> signupWithEmailAndPassword(
//     String email,
//     String password,
//   ) async {
//     try {
//       final credential = await FirebaseAuth.instance
//           .createUserWithEmailAndPassword(email: email, password: password);
     
//       //Save user data in Firebase store
//       _store.collection("Users").doc(credential.user?.uid).set({
//         'uid': credential.user?.uid,
//         'email': credential.user?.email,
//       });
//       return credential;
//     } on FirebaseAuthException catch (e) {
//       if (e.code == 'weak-password') {
//         throw ('The password provided is too weak.');
//       } else if (e.code == 'email-already-in-use') {
//         throw ('The account already exists for that email.');
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//     return null;
//   }

//   //signout
//   Future<void> signout() async {
//     return await _authService.signOut();
//   }

//   User? getCurrentUser(){
//     return _authService.currentUser;
//   }
// }
