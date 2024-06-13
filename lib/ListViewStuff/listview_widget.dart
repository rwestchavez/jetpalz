import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:jet_palz/components/my_button.dart';
import '../app_state.dart';
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
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (widget.usersProvider.hasNext) {
        widget.usersProvider.fetchNextUsers();
      }
    }
  }

  Future<void> sendJoinRequest(String ventureId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;
    final userSnap = await firestore.collection('users').doc(userId).get();
    final userData = userSnap.data() as Map<String, dynamic>;
    final String requester = userData['username'];

    final venture = firestore.collection('ventures').doc(ventureId);
    final requestRef = firestore.collection('requests').doc();
    final snap = await venture.get();
    final data = snap.data() as Map<String, dynamic>;
    final DocumentReference creator = data["creator"];
    final creatorId = creator.id;

    await requestRef.set({
      'creatorId': creatorId,
      'requestId': requestRef.id,
      'requesterId': userId,
      'requester': requester,
      'ventureId': ventureId,
      'status': 'pending',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.usersProvider.ventures.isEmpty &&
        !widget.usersProvider.hasNext) {
      return Center(
        child: Text(
          'No Ventures found  \n\nTry using a different filter!',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView(
      controller: scrollController,
      children: [
        ...widget.usersProvider.ventures
            .map(
              (venture) => Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                '${venture.memberNum} / ${venture.maxPeople}',
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
                                return Text(creatorData?['username'] ?? "error",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20));
                              } else {
                                return Text('Unknown');
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
                    SizedBox(
                      height: 8,
                    ),
                    Text(venture.description!),
                    SizedBox(
                      height: 12,
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
                                onPressed: () {
                                  sendJoinRequest(
                                      venture.ventureId); // Pass ventureId here
                                },
                                child: Text("Join"),
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
              onTap: () {},
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
