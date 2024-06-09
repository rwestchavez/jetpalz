import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ListViewStuff/listview_widget.dart';
import '../ListViewStuff/venture_provider.dart';
import '../app_state.dart';
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
      appBar: MyAppBar(
        title: "Feed",
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
              splashColor: Colors.transparent, // Remove the tap color
              highlightColor: Colors.transparent,
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
              icon: Icon(Icons.airplanemode_active, size: 40)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
                splashColor: Colors.transparent, // Remove the tap color
                highlightColor: Colors.transparent,
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
                icon: const Icon(
                  Icons.filter_alt_rounded,
                  size: 40,
                )),
          ),
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
  Widget build(BuildContext context) {
    return Consumer2<AppState, VentureProvider>(
      builder: (context, appState, ventureProvider, _) {
        return Scaffold(
          body: ListViewWidget(
            appState: appState,
            usersProvider: ventureProvider,
          ),
        );
      },
    );
  }
}
