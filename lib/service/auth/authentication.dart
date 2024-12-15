import 'dart:developer';

import 'package:chat_app/auth/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class AuthMethod {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> registerUser({
    required String email,
    required String name,
    required String password,
  }) async {
    log("Starting registerUser function...");
    String res = "Failed upload user";

    try {
      // Input validation
      if (email.isEmpty || name.isEmpty || password.isEmpty) {
        logger.d("Validation failed: Please enter all fields");
        return "Please enter all fields";
      }

      // Email validation
      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        logger.d("Invalid email format");
        return "Invalid email format";
      }

      // Password strength validation
      if (password.length < 6) {
        logger.d("Password too short");
        return "Password must be at least 6 characters";
      }

      // Attempt user creation
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      logger.d("User successfully created with UID: ${cred.user!.uid}");

      // Save user data to Firestore
      await _fireStore.collection("users").doc(cred.user!.uid).set({
        'name': name,
        'uid': cred.user!.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      logger.d("User data successfully saved to Firestore");
      return "success";

    } on FirebaseAuthException catch (e) {
      // More specific Firebase Auth error handling
      switch (e.code) {
        case 'weak-password':
          res = "The password is too weak.";
          break;
        case 'email-already-in-use':
          res = "The email is already in use.";
          break;
        case 'invalid-email':
          res = "The email address is invalid.";
          break;
        default:
          res = e.message ?? "Authentication error";
      }
      logger.e("Firebase Auth error: $res");
      return res;

    } catch (e) {
      logger.e("Unexpected error: $e");
      return e.toString();
    }
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }


    signOut() async{
      await signOut();
    }
}