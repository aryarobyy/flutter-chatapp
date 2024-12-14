import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthMethod {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
      String res = "some error Occured";
      try {
        if(email.isNotEmpty || password.isNotEmpty){
          await _auth.signInWithEmailAndPassword(
              email: email,
              password: password
          );
          res = "Success";
        } else {
          res = "Please enter all fields";
        }
      } catch (e) {
        return e.toString();
      }
      return res;
    }

    signOut() async{
      await signOut();
    }
}