import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appbar.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_snack_bar.dart';
import '../models/request_model.dart';
import '../models/venture_model.dart';

class MyVenturesListView extends StatefulWidget {
  const MyVenturesListView({Key? key}) : super(key: key);

  @override
  _MyVenturesListViewState createState() => _MyVenturesListViewState();
}

class _MyVenturesListViewState extends State<MyVenturesListView> {
  bool _isLoading = true;
  List<VentureModel> ventures = [];
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _fetchPendingRequests();
  }

  Future<void> cancelJoinRequest(String ventureId) async {
    setState(() {
      _isButtonDisabled = true;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final firestore = FirebaseFirestore.instance;

      final querySnapshot = await firestore
          .collection('requests')
          .where('ventureId', isEqualTo: ventureId)
          .where('requesterId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      MySnackBar.show(context,
          content: Text("You cancelled your request to join the venture"));
    } finally {
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  Stream<QuerySnapshot> checkRequestStatus(String ventureId) {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    return firestore
        .collection('requests')
        .where('ventureId', isEqualTo: ventureId)
        .where('requesterId', isEqualTo: userId)
        .snapshots();
  }

  Color getButtonColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green;
      case 'pending':
        return Colors.yellow;
      default:
        return Colors.blue; // Default color for 'Join' button
    }
  }

  String getButtonText(String status) {
    switch (status) {
      case 'accepted':
        return 'Accepted';
      case 'pending':
        return 'Undo request';
      default:
        return 'Join';
    }
  }

  Future<void> _fetchPendingRequests() async {
    final String userId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('requests')
        .where('requesterId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) async {
      List<JoinRequest> requests =
          snapshot.docs.map((doc) => JoinRequest.fromDocument(doc)).toList();

      List<VentureModel> fetchedVentures = [];
      for (var request in requests) {
        DocumentSnapshot ventureDoc = await FirebaseFirestore.instance
            .collection('ventures')
            .doc(request.ventureId)
            .get();
        fetchedVentures.add(VentureModel.fromDocument(ventureDoc));
      }

      setState(() {
        ventures = fetchedVentures;
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Requests",
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ventures.isEmpty
              ? Center(
                  child: Text(
                    "You haven't requested to join any ventures",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  itemCount: ventures.length,
                  itemBuilder: (context, index) {
                    final venture = ventures[index];
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                              Text("${venture.country}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 30)),
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Text(
                                      '${venture.memberNum} / ${venture.maxPeople}',
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
                                Text(venture.creatorName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20)),
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
                          Text(venture.description ?? ''),
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
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream:
                                          checkRequestStatus(venture.ventureId),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasError) {
                                          return Text(
                                              'Error: ${snapshot.error}');
                                        } else if (snapshot.hasData &&
                                            snapshot.data!.docs.isNotEmpty) {
                                          var requestStatus = snapshot
                                              .data!.docs.first['status'];
                                          return MyButton(
                                            onPressed: _isButtonDisabled
                                                ? () {}
                                                : () {
                                                    if (requestStatus ==
                                                        'pending') {
                                                      cancelJoinRequest(
                                                          venture.ventureId);
                                                    }
                                                  },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .resolveWith<Color>(
                                                (states) => getButtonColor(
                                                    requestStatus),
                                              ),
                                            ),
                                            child: Text(
                                                getButtonText(requestStatus)),
                                          );
                                        } else {
                                          return MyButton(
                                            onPressed: _isButtonDisabled
                                                ? () {}
                                                : () {},
                                            child: Text("Join"),
                                          );
                                        }
                                      },
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
                    );
                  },
                ),
    );
  }
}
