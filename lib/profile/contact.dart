import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appbar.dart';

import '../components/single_line_widget.dart';

import '../helpers/launch_url.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  _ContactState createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Get in touch!"),
      body: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.add_circle,
              text: 'Request feature',
              onTap: () {
                launchURL("https://jetpalz.com/feature", context);
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.report,
              text: 'Report issue',
              onTap: () {
                launchURL('https://jetpalz.com/issue', context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
