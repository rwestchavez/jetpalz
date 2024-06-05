import 'package:flutter/material.dart';
import 'nav/chat.dart';
import 'nav/feed.dart';
import 'nav/profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Main(),
    );
  }
}

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  int _index = 0;
  final List<Widget> screens = [const Chat(), const Feed(), const Profile()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Feed",
        ),
        centerTitle: true,
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
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat_bubble), label: "Chat"),
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.person), label: "Profile")
        ],
        onDestinationSelected: (value) {
          setState(
            () {
              _index = value;
            },
          );
        },
        selectedIndex: _index,
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
