import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> googleAuth(BuildContext context) async {
  try {
    final _auth = FirebaseAuth.instance;
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    print("User signed in: ${userCredential.user!.email}");

    // Navigate to the next screen or perform any necessary action
    Navigator.pushReplacementNamed(context, '/onboarding');
  } catch (e) {
    print('Google sign in failed: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google sign in failed. Please try again later.')),
    );
  }
}
