import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/sign_up.dart';
import '../components/single_line_widget.dart'; // Import the SingleLineWidget

class Settings extends StatelessWidget {
  const Settings({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignUp(),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _logout(context); // Call the logout function
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleLineWidget(
              icon: Icons.email,
              text: 'Change Email',
              onTap: () {
                // Navigate to the screen for changing email
                Navigator.pushNamed(context, '/changeEmail');
              },
            ),
            const SizedBox(
                height: 8), // Add some vertical space between widgets
            SingleLineWidget(
              icon: Icons.lock,
              text: 'Change Password',
              onTap: () {
                // Navigate to the screen for changing password
                Navigator.pushNamed(context, '/changePassword');
              },
            ),
            const SizedBox(
                height: 8), // Add some vertical space between widgets
            SingleLineWidget(
              icon: Icons.exit_to_app,
              text: 'Logout',
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
