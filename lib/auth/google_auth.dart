import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../components/my_snack_bar.dart';

Future<void> googleAuth(BuildContext context, bool signUp) async {
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
    if (signUp) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'username': '', // Add display name if needed
        'photo_url': '', // Add photo URL if needed
        'created_time': Timestamp.now(), // Add creation time
        'profession': '', // Add profession if needed
        'countries_interest': [], // Add countries interest if needed
        'professions_interest': [], // Add professions interest if needed
        'description': '', // Add description if needed
      });
      Navigator.pushReplacementNamed(context, '/onboarding');
    } else {
      Navigator.pushReplacementNamed(context, '/feed');
    }
  } catch (e) {
    print('Google sign in failed: $e');
    MySnackBar.show(
      context,
      content: Text('Google sign in failed. Please try again later.'),
    );
  }
}
