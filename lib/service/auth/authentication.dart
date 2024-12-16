import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final logger = Logger();

const String USER_COLLECTION = "users";

class AuthMethod {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthMethod ();

  Future<String> registerUser({
    required String email,
    required String name,
    required String password,
    String? img_url,
    String? last_active,
  }) async {
    log("Starting registerUser function...");
    String res = "Failed upload user";

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      log("User successfully created with UID: ${cred.user!.uid}");

      final userData = {
        'name': name,
        'uid': cred.user!.uid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'image': img_url ?? "",
        'last_active': last_active ?? DateTime.now().toUtc().toIso8601String(),
      };

      print("Saving the following data to Firestore: $userData");

      await _fireStore.collection(USER_COLLECTION).doc(cred.user!.uid).set(userData);

      final storedData = await _fireStore.collection(USER_COLLECTION).doc(cred.user!.uid).get();

      if (storedData.exists) {
        print("Data successfully stored in Firestore: ${storedData.data()}");
      } else {
        print("Data was not found in Firestore after saving.");
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "An unknown FirebaseAuth error occurred.";
      log("Firebase Auth error: $res");
    } catch (e) {
      res = "An unexpected error occurred: $e";
      log("Unexpected error: $e");
    }

    log("registerUser result: $res");
    return res;
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