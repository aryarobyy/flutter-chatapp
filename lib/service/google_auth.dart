import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseServices {
  final auth = FirebaseAuth.instance;
  final googleSignIn = GoogleSignIn();

  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if(googleSignInAccount != null){
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );
        await auth.signInWithCredential(authCredential);
        if (auth.currentUser != null) {
          print("Google Sign-In successful: ${auth.currentUser!.email}");
          return true;
        } else {
          print("Google Sign-In failed: User is null");
        }
      }
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
    return false;
  }

  googleSignOut() async {
    await googleSignIn.signOut();
    auth.signOut();
  }
}