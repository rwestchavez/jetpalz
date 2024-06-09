import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/my_appBar.dart';
import '../components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: AuthScreen()),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': userCredential.user!.email,
        'display_name': '', // Add display name if needed
        'photo_url': '', // Add photo URL if needed
        'created_time': Timestamp.now(), // Add creation time
        'profession': '', // Add profession if needed
        'countries_interest': [], // Add countries interest if needed
        'professions_interest': [], // Add professions interest if needed
        'description': '', // Add description if needed
        'current_ventures': [], // Add current ventures if needed
      });
      print("User signed up: ${userCredential.user!.email}");
    } catch (e) {
      print(e);
    }
  }

  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      print("User signed in: ${userCredential.user!.email}");
    } catch (e) {
      print("error: $e");
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      print("User signed out");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(automaticallyImplyLeading: false, title: "Chat"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Sign In'),
            ),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Sign Out'),
            )
          ],
        ),
      ),
    );
  }
}
