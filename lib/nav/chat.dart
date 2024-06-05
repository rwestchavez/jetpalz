import 'package:flutter/material.dart';
import '../components/my_appBar.dart';
import '../components/my_button.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: MyButton(
        onPressed: () {},
        text: "Hello",
      )),
      appBar: MyAppBar(
        title: "Chat",
      ),
    );
  }
}
