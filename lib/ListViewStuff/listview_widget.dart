import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jet_palz/components/my_button.dart';

import '../app_state.dart';
import '../components/my_venture.dart';
import 'venture_provider.dart';
import 'package:flutter/material.dart';

class ListViewWidget extends StatefulWidget {
  final VentureProvider usersProvider;
  final AppState appState;

  const ListViewWidget({
    required this.appState,
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
  Widget build(BuildContext context) {
    print(widget.appState.estimatedWeeks);
    print("Building...");
    return ListView(
      controller: scrollController,
      children: [
        ...widget.usersProvider.ventures
            .map(
              (venture) => Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1, color: Color.fromARGB(255, 214, 214, 214)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${venture.country}",
                            style: TextStyle(
                                fontWeight: FontWeight.w900, fontSize: 30)),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '${venture.memberList!.length} / ${venture.maxPeople}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
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
                                    creatorData?['display_name'] ?? "error",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20));
                              } else {
                                return Text('Unkheeeon');
                              }
                            },
                          ),
                          Row(
                            children: [
                              Text("Profession",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text("${venture.industry}"),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    Text(venture.description!),
                    SizedBox(
                      height: 24,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 150),
                              child: MyButton(
                                onPressed: () {},
                                text: 'Join',
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Month ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${venture.startingMonth}',
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    'Duration ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${venture.estimatedWeeks}',
                                  ),
                                  Text(" Weeks")
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
            .toList(),
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
}
