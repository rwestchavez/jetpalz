import 'package:flutter/material.dart';
import '../components/my_appBar.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return const CreateVenture();
                },
              ),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          elevation: 5,
          child: Icon(
            Icons.airplanemode_active,
            color: Theme.of(context).colorScheme.onSecondary,
            size: 40,
          )),
      appBar: MyAppBar(
        title: "Feed",
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return const Filter();
                    });
              },
              icon: const Icon(Icons.filter_alt_outlined)),
        ],
      ),
    );
  }
}

class Filter extends StatelessWidget {
  const Filter({super.key});

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

class CreateVenture extends StatelessWidget {
  const CreateVenture({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0), // Adjust radius as needed
          topRight: Radius.circular(25.0),
        )),
        child: const Center(child: Text("Nope")));
  }
}
