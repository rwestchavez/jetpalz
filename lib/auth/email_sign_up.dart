import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appBar.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';

class EmailSignUp extends StatefulWidget {
  const EmailSignUp({
    Key? key,
    required this.email,
  }) : super(key: key);

  final String email;

  @override
  State<EmailSignUp> createState() => _EmailSignUpWidgetState();
}

class _EmailSignUpWidgetState extends State<EmailSignUp> {
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late FocusNode _passwordFocusNode;
  late FocusNode _confirmPasswordFocusNode;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: widget.email,
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
      // Handle successful sign-up
      print("User signed up: ${userCredential.user!.email}");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Sign-up error: $e";
      print(errorMessage);
      String snackBarMessage;

      switch (e.code) {
        case 'email-already-in-use':
          snackBarMessage = 'Email address is already in use';
          break;
        case 'weak-password':
          snackBarMessage = 'Password is too weak';
          break;
        case 'invalid-email':
          snackBarMessage = 'Invalid email address';
          break;
        case 'too-many-requests':
          snackBarMessage = 'Too many sign-up requests. Try again later.';
          break;
        default:
          snackBarMessage = 'An error occurred. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snackBarMessage)),
      );
    } catch (e) {
      // Handle other errors
      print("Error signing up: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred. Please try again later.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: MyAppBar(title: ""),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter your password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24),
                    MyTextField(
                      hintText: "Password",
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      obscureText: !_passwordVisible,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    MyTextField(
                      hintText: "Confirm Password",
                      controller: _confirmPasswordController,
                      focusNode: _confirmPasswordFocusNode,
                      obscureText: !_confirmPasswordVisible,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    MyButton(
                      child: Text("Create Account",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await _signUp();
                          Navigator.pushReplacementNamed(
                              context, '/onboarding');
                        } // Call the sign-up method
                      },
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
