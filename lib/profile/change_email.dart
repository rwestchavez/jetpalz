import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_textField.dart';
import '../components/my_appBar.dart';
import '../components/my_snack_bar.dart'; // Import the MySnackBar class

class ChangeEmail extends StatefulWidget {
  const ChangeEmail({Key? key}) : super(key: key);

  @override
  State<ChangeEmail> createState() => _ChangeEmailWidgetState();
}

class _ChangeEmailWidgetState extends State<ChangeEmail> {
  late TextEditingController _emailAddressController;
  late FocusNode _focusNode;
  final userId = FirebaseAuth.instance.currentUser?.uid;
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

  Future<String> _getCurrentUserEmail() async {
    if (userId != null) {
      final userDataSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDataSnapshot.exists) {
        return userDataSnapshot.data()?['email'] ?? '';
      }
    }
    return '';
  }

  Future<void> _changeEmail() async {
    if (_formKey.currentState?.validate() ?? false) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.verifyBeforeUpdateEmail(_emailAddressController.text);
          MySnackBar.show(
            context,
            content: const Text('Verification sent to your email'),
          );
        } on FirebaseAuthException catch (e) {
          MySnackBar.show(
            context,
            content: Text('Failed to update email: ${e.message}'),
          );
        }
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
          title: "Update email",
        ),
        body: FutureBuilder<String>(
          future: _getCurrentUserEmail(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Email: ${snapshot.data}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        MyTextField(
                          hintText: "Enter your new email",
                          controller: _emailAddressController,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null; // Validation passed
                          },
                        ),
                        const SizedBox(height: 16),
                        MyButton(
                          onPressed: _changeEmail,
                          child: const Text(
                            'Change Email',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
