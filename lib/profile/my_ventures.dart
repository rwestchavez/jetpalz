import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jet_palz/components/my_appbar.dart';

class MyVenturesListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "My Ventures",
      ),
      body: FutureBuilder<List<DocumentReference>>(
        future: MyVenturesLogic().getUserVentures(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final List<DocumentReference> userVentures = snapshot.data!;
            if (userVentures.isEmpty) {
              return Center(
                child: Text(
                  'You are not part of any Ventures :(  \n\nCreate or go join one!',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              );
            } else {
              return MyListView(currentVentures: userVentures);
            }
          } else {
            return Center(child: Text('Unknown'));
          }
        },
      ),
    );
  }
}

class MyListView extends StatelessWidget {
  final List<DocumentReference> currentVentures;

  MyListView({required this.currentVentures});

  @override
  Widget build(BuildContext context) => ListView(
        children: currentVentures
            .map(
              (ventureRef) => FutureBuilder<DocumentSnapshot>(
                future: ventureRef.get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final ventureData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    return Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1,
                            color: Color.fromARGB(255, 214, 214, 214)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${ventureData['country']}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 30)),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      '${ventureData['member_num']} / ${ventureData['max_people']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
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
                                  future: ventureData['creator'].get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    } else if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    } else if (snapshot.hasData) {
                                      var creatorData = snapshot.data!.data()
                                          as Map<String, dynamic>?;
                                      return Text(
                                        creatorData?['username'] ?? "error",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20),
                                      );
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
                                      child: Text("${ventureData['industry']}"),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          Text(ventureData['description']),
                          SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(maxWidth: 150),
                                    child: FilledButton(
                                      onPressed: () {},
                                      child: Text("Leave"),
                                      style: FilledButton.styleFrom(
                                          foregroundColor: Theme.of(context)
                                              .colorScheme
                                              .onSecondary,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          )),
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
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                            '${ventureData['starting_month']}'),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Duration ',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                            '${ventureData['estimated_weeks']}'),
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
                    );
                  } else {
                    return Center(child: Text('Unknown'));
                  }
                },
              ),
            )
            .toList(),
      );
}

class MyVenturesLogic {
  Future<List<DocumentReference>> getUserVentures() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        List<DocumentReference> userVentures =
            List<DocumentReference>.from(userDoc['current_ventures']);

        return userVentures;
      } else {
        throw Exception('User not authenticated');
      }
    } catch (error) {
      throw Exception('Error fetching user ventures: $error');
    }
  }
}
