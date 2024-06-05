import 'package:flutter/material.dart';
import '../components/my_appbar.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      appBar: MyAppBar(
        title: "Feed",
        leading: IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: () {},
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 24),
              child: IconButton(
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return const BottomSheeter();
                        });
                  },
                  icon: const Icon(Icons.settings),
                  iconSize: 48,
                  color: const Color.fromRGBO(32, 23, 43, 0.5)))
        ],
      ),
    );
  }
}

class BottomSheeter extends StatelessWidget {
  const BottomSheeter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0), // Adjust radius as needed
          topRight: Radius.circular(25.0),
        )),
        child: const Center(child: Text("Hello there fewfew")));
  }
}
