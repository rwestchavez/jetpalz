import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';

import '../components/my_appBar.dart';
import '../components/my_snack_bar.dart'; // Import the MySnackBar class

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordWidgetState();
}

class _ChangePasswordWidgetState extends State<ChangePassword> {
  late TextEditingController _emailAddressController;
  late FocusNode _focusNode;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailAddressController = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailAddressController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await FirebaseAuth.instance
            .sendPasswordResetEmail(email: _emailAddressController.text.trim());
        MySnackBar.show(
          context,
          content: const Text('Password reset email sent'),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found with this email address.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'Failed to send password reset email: ${e.message}';
        }
        MySnackBar.show(
          context,
          content: Text(errorMessage),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss the keyboard when tapped outside the text field
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        appBar: MyAppBar(
          title: "Change password",
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'We will send you an email with a link to reset your password. Please enter the email associated with your account below:',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  MyTextField(
                    hintText: "Enter your email",
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailAddressController,
                    focusNode: _focusNode,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null; // Validation passed
                    },
                  ),
                  const SizedBox(height: 16),
                  MyButton(
                    onPressed: _sendPasswordResetEmail,
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
