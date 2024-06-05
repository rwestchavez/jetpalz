import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/my_venture.dart';
import 'venture_provider.dart';
import 'package:flutter/material.dart';

class ListViewWidget extends StatefulWidget {
  final VentureProvider usersProvider;

  const ListViewWidget({
    required this.usersProvider,
    Key? key,
  }) : super(key: key);

  @override
  _ListViewWidgetState createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(scrollListener);
    widget.usersProvider.fetchNextUsers();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.offset >=
            scrollController.position
                .maxScrollExtent && // you can do /2 to make it faster and seamless
        !scrollController.position.outOfRange) {
      if (widget.usersProvider.hasNext) {
        widget.usersProvider.fetchNextUsers();
      }
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
        //its not a listview builder since you already know the amount of items you are getting and you dont need them to be loaded dynamically.
        controller: scrollController,
        padding: EdgeInsets.all(12),
        children: [
          ...widget
              .usersProvider // const otherNumbers = [0, ...numbers, 4]; // Becomes [0, 1, 2, 3, 4] when numbers = [1,2,3]
              .ventures // creates a list of listtiles from the list of objects.
              .map((venture) {
            return Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("hello there"),
                      Row(
                        children: [
                          Text(
                            '${venture.memberList!.length} / ${venture.maxPeople}',
                          ),
                          Icon(Icons.people_alt),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: 300.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder<DocumentSnapshot>(
                          future: venture.creator!.get(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (snapshot.hasData) {
                              var creatorData = snapshot.data?.data()
                                  as Map<String, dynamic>?;
                              return Text(
                                  creatorData?['display_name'] ?? "error");
                            } else {
                              return Text('Unknown');
                            }
                          },
                        ),
                        Text(venture.industry!),
                      ],
                    ),
                  ),
                  Text(venture.description!),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Leave'),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Month ${venture.startingMonth}'),
                            Text('Length ${venture.estimatedWeeks}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          if (widget.usersProvider.hasNext)
            Center(
              child: GestureDetector(
                onTap: () {}, // widget.usersProvider.fetchNextUsers,
                child: Container(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      );
}
