import 'package:flutter/material.dart';
import '../components/my_appbar.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      appBar: MyAppBar(
        title: "Chat",
      ),
    );
  }
}
