import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ListViewStuff/listview_widget.dart';
import '../ListViewStuff/venture_provider.dart';
import '../components/my_appBar.dart';
import '../components/my_button.dart';
import '../constants.dart';
import '../BottomSheets/create_venture.dart';
import '../BottomSheets/filter_venture.dart';

class Feed extends StatelessWidget {
  const Feed({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VentureFeed(),
      floatingActionButton: FloatingActionButton(
          onPressed: () => showModalBottomSheet(
                isScrollControlled: true,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                      heightFactor:
                          0.5, // Adjust this factor to control the height
                      child: CreateVenture());
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
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return FractionallySizedBox(
                        heightFactor:
                            0.5, // Adjust this factor to control the height
                        child: FilterVenture());
                  },
                );
              },
              icon: const Icon(Icons.filter_alt_outlined)),
        ],
      ),
    );
  }
}

class VentureFeed extends StatefulWidget {
  const VentureFeed({Key? key}) : super(key: key);

  @override
  _Page2State createState() => _Page2State();
}

class _Page2State extends State<VentureFeed> {
  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (context) => VentureProvider(),
        child: Scaffold(
          body: Consumer<VentureProvider>(
            builder: (context, usersProvider, _) => ListViewWidget(
              usersProvider: usersProvider,
            ),
          ),
        ),
      );
}
