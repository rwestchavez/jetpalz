import 'package:flutter/material.dart';
import '../components/my_appBar.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      appBar: MyAppBar(title: "Profile"),
    );
  }
}
