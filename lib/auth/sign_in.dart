import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';
import '../components/my_snack_bar.dart';
import 'google_auth.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  _SignInWidgetState createState() => _SignInWidgetState();
}

class _SignInWidgetState extends State<SignIn> {
  late FocusNode emailAddressFocusNode;
  late FocusNode passwordFocusNode;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // Loading state variable

  @override
  void initState() {
    super.initState();
    emailAddressFocusNode = FocusNode();
    passwordFocusNode = FocusNode();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailAddressFocusNode.dispose();
    passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigate to the next screen or perform any necessary action
      Navigator.pushReplacementNamed(context, '/feed');
    } on FirebaseAuthException catch (e) {
      String snackBarMessage;

      switch (e.code) {
        case 'invalid-email':
          snackBarMessage = 'Invalid email address';
          break;
        case 'user-not-found':
          snackBarMessage = 'No user found with this email address';
          break;
        case 'wrong-password':
          snackBarMessage = 'Invalid password';
          break;
        case 'too-many-requests':
          snackBarMessage = 'Too many unsuccessful attempts. Try again later.';
          break;
        default:
          snackBarMessage = 'An error occurred. Please try again later.';
      }

      MySnackBar.show(
        context,
        content: Text(snackBarMessage),
      );
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance
          .recordError(e, stackTrace, reason: "Sign in error");

      MySnackBar.show(
        context,
        content: const Text("An error occurred. Please try again later."),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard by unfocusing any focused text fields
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      width: double.infinity, // Adjust width as needed
                      height: 200,
                      fit: BoxFit.contain, // Adjust image fit
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 32.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Text(
                      'Sign in to pick up where you left off',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    MyTextField(
                      hintText: "Email",
                      focusNode: emailAddressFocusNode,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    MyTextField(
                      hintText: "Password",
                      focusNode: passwordFocusNode,
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    MyButton(
                      onPressed: _isLoading
                          ? () {}
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                await _signIn();
                              }
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Sign in',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/forgotPassword');
                          },
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4.0),
                    Container(
                      width: double.infinity,
                      child: Stack(
                        alignment: AlignmentDirectional.center,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 2.0,
                            color: Colors.grey[300], // Or your desired color
                          ),
                          Container(
                            width: 70.0,
                            height: 32.0,
                            color: Colors.white, // Or your desired color
                            alignment: Alignment.center,
                            child: const Text(
                              'OR',
                              style: TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 16.0),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading
                            ? () {}
                            : () async {
                                await googleAuth(context, false);
                              },
                        icon: const FaIcon(
                          FontAwesomeIcons.google,
                          size: 20.0,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 44.0),
                          side: const BorderSide(color: Colors.grey, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        label: const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ButtonStyle(
                            textStyle: WidgetStateProperty.all<TextStyle>(
                              const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          child: const Text('Sign Up here'),
                        ),
                      ],
                    ),
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
