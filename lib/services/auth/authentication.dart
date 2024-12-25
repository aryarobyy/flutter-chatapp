import 'dart:developer';
import 'package:chat_app/model/user_model.dart';
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

  bool isValidEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  Future<String> registerUser({
    required String email,
    required String name,
    required String password,
    String? img_url,
    String? last_active,
  }) async {
    log("Starting registerUser function...");
    String res = "Failed upload user";
    if (email.isEmpty || password.isEmpty) {
      return "Email or password is empty";
    }

    if (!isValidEmail(email.trim())) {
      return "Invalid email format";
    }
    try {
      final querySnapshot = await _fireStore
          .collection(USER_COLLECTION)
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        res = "Email already exists";
        log("Email check: Email already exists in Firestore.");
        return res;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final String uuid = Uuid().v4();

      final userData = {
        'name': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'image': img_url ?? "",
        'last_active': last_active ?? DateTime.now().toUtc().toIso8601String(),
        'uid': userCredential.user!.uid,
      };

      await _fireStore.collection(USER_COLLECTION).doc(uuid).set(userData);
      final storedData = await _fireStore.collection(USER_COLLECTION).doc(uuid).get();
      res = "success";

      if (storedData.exists) {
        logger.i("Data successfully stored in Firestore: ${storedData.data()}");
      } else {
        logger.w("Data was not found in Firestore after saving.");
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          res = "The password provided is too weak";
          break;
        case 'email-already-in-use':
          res = "The email address is already in use";
          break;
        case 'invalid-email':
          res = "The email address is invalid";
          break;
        default:
          res = e.message ?? "An unknown FirebaseAuth error occurred.";
      }
      log("Firebase Auth error: $res");
    } catch (e) {
      res = "An error occurred: $e";
      log(res);
    }

    log("registerUser result: $res");
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return "Email or password is empty";
    }

    if (!isValidEmail(email.trim())) {
      return "Invalid email format";
    }

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        return "Failed to retrieve user information.";
      }

      final querySnapshot = await _fireStore
          .collection('users')
          .where('email', isEqualTo: email.trim())
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;

        await _fireStore.collection('users').doc(userDoc.id).update({
          'lastLogin': DateTime.now().toIso8601String(),
          'isActive': true,
        });

        return "success";
      } else {
        // Buat dokumen Firestore baru untuk pengguna
        await _fireStore.collection('users').add({
          'email': email.trim(),
          'createdAt': DateTime.now().toIso8601String(),
        });
        return "User profile not found; new profile created.";
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return "No user found with this email.";
        case 'wrong-password':
          return "Incorrect password.";
        case 'invalid-email':
          return "Invalid email format.";
        case 'too-many-requests':
          return "Too many failed login attempts. Please try again later.";
        default:
          return e.message ?? "An unknown error occurred.";
      }
    } catch (e) {
      log("Login error: $e");
      return "An error occurred: $e";
    }
  }

  Future<String> getCurrentUserId() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception("No user is currently logged in");
      }

      return user.uid;
    } catch (e) {
      log("Error in getCurrentUserId: $e");
      rethrow;
    }
  }

  Stream<UserModel> getUserById(String uid) {
    print("Fetching user with UID: $uid");
    return _fireStore
        .collection(USER_COLLECTION)
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromJSON(snapshot.docs.first.data());
      } else {
        throw Exception('User not found');
      }
    });
  }

  Stream<UserModel> getUserexceptCurrent(){
    final _currUser = _auth.currentUser!.uid;
    return _fireStore
        .collection(USER_COLLECTION)
        .where('uid', isNotEqualTo: _currUser)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromJSON(snapshot.docs.first.data());
      } else {
        throw Exception('User not found');
      }
    });
  }

  Stream<String> getCurrentUserIdStream() {
    return _auth.authStateChanges().map((user) => user?.uid ?? "");
  }

  Stream<UserModel> getUserByName(String name) {
    return _fireStore
        .collection(USER_COLLECTION)
        .where('name', isEqualTo: name)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromJSON(snapshot.docs.first.data());
      } else {
        throw Exception('User not found');
      }
    });
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
