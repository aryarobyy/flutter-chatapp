import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuth {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final String? userEmail = googleSignInAccount.email;

        final QuerySnapshot querySnapshot = await _fireStore
            .collection('users')
            .where('email', isEqualTo: userEmail)
            .get();

        if (querySnapshot.docs.isEmpty) {
          print("Email not registered in Firestore");
          await googleSignIn.signOut();
          return null;
        }

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        await auth.signInWithCredential(authCredential);

        if (auth.currentUser != null) {
          print("Login success");
          return userEmail;
        } else {
          print("Google Sign-In failed: User is null");
        }
      }
    } on FirebaseAuthException catch (e) {
      print("Error during Google Sign-In: $e");

      if (auth.currentUser != null) {
        try {
          await auth.currentUser?.delete();
          print("User removed from Firebase Authentication");
        } catch (deleteError) {
          print("Error deleting user: $deleteError");
        }
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      return null;
    }
  }

  Future<String> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
        await auth.signInWithCredential(authCredential);

        final User? user = userCredential.user;

        if (user != null) {
          final QuerySnapshot querySnapshot = await _fireStore
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get();

          if (querySnapshot.docs.isNotEmpty) {
            return "Account already exists";
          }

          final Map<String, dynamic> userData = {
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'photoUrl': user.photoURL ?? '',
            'createdAt': FieldValue.serverTimestamp(),
          };

          await _fireStore.collection('users').doc(user.uid).set(userData);
          return "Sign-Up successful";
        } else {
          return "Google Sign-In failed";
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        return "Account exists with a different sign-in method";
      }
      print("FirebaseAuthException: $e");
    } catch (e) {
      print("Error during Google Sign-Up: $e");
    }

    return "Sign-Up failed";
  }


  googleSignOut() async {
    await googleSignIn.signOut();
    auth.signOut();
  }
}