import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

final logger = Logger();

const String USER_COLLECTION = "users";

class AuthMethod {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GetIt _getIt = GetIt.instance;

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
      final String uuid = Uuid().v4();

      final userData = {
        'name': name,
        'uid': uuid,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'image': img_url ?? "",
        'last_active': last_active ?? DateTime.now().toUtc().toIso8601String(),
      };

      await _fireStore.collection(USER_COLLECTION).doc(uuid).set(userData);
      final storedData = await _fireStore.collection(USER_COLLECTION).doc(uuid).get();
      res = "success";

      if (storedData.exists) {
        print("Data successfully stored in Firestore: ${storedData.data()}");
      } else {
        print("Data was not found in Firestore after saving.");
      }
    } on FirebaseAuthException catch (e) {
      res = e.message ?? "An unknown FirebaseAuth error occurred.";
      log("Firebase Auth error: $res");
    }
    log("registerUser result: $res");
    return res;
  }


  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = "success";
      } else {
        res = "Please enter all fields";
      }
    return res;
  }

  Stream<QuerySnapshot> getUserProfile() {
    try {
      return FirebaseFirestore.instance.collection('users').snapshots();
    } catch (e) {
      print("Error in getUserProfile: $e");
      rethrow;
    }
  }


    signOut() async{
      await signOut();
    }
}