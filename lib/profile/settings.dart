import 'package:flutter/material.dart';

import '../components/single_line_widget.dart'; // Import the SingleLineWidget

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
            SizedBox(height: 8), // Add some vertical space between widgets
            SingleLineWidget(
              icon: Icons.lock,
              text: 'Change Password',
              onTap: () {
                // Navigate to the screen for changing password
                Navigator.pushNamed(context, '/changePassword');
              },
            ),
          ],
        ),
      ),
    );
  }
}
