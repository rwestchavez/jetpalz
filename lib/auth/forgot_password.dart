import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appBar.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';

import '../components/my_snack_bar.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPassword> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _emailAddressTextController;
  late FocusNode _emailAddressFocusNode;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailAddressTextController = TextEditingController();
    _emailAddressFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailAddressTextController.dispose();
    _emailAddressFocusNode.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      MySnackBar.show(context, content: Text("Password reset email sent!"));
    } catch (error) {
      print('Password reset failed: $error');
      MySnackBar.show(context,
          content:
              Text("Failed to send password reset email. Please try again."));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        appBar: MyAppBar(
          title: "",
        ),
        body: Form(
          key: _formKey,
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(
                maxWidth: 570.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                    child: Text(
                      'We will send you an email with a link to reset your password, please enter the email associated with your account below.',
                      style: TextStyle(
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 0.0),
                    child: Container(
                      width: double.infinity,
                      child: MyTextField(
                        hintText: "Enter your email",
                        controller: _emailAddressTextController,
                        focusNode: _emailAddressFocusNode,
                        autofillHints: [AutofillHints.email],
                        obscureText: false,
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
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
                      child: MyButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate())
                            await _resetPassword(
                                _emailAddressTextController.text);
                          ;
                          // Call your reset password function here
                        },
                        child: Text('Send Link'),
                      ),
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
