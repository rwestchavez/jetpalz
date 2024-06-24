import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_button.dart';
import 'package:jet_palz/components/my_snack_bar.dart';
import 'package:jet_palz/helpers/delete_venture.dart';
import 'package:jet_palz/helpers/edit_venture.dart';
import '../app_state.dart';
import '../profile/profile_view.dart';
import 'venture_provider.dart';

class ListViewWidget extends StatefulWidget {
  final VentureProvider usersProvider;
  final AppState appState;

  const ListViewWidget({
    required this.appState,
    required this.usersProvider,
    super.key,
  });

  @override
  _ListViewWidgetState createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  final scrollController = ScrollController();
  bool _isButtonDisabled = false;

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
    setState(() {
      _isButtonDisabled = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(userId);
      final userSnap = await userRef.get();
      final userData = userSnap.data() as Map<String, dynamic>;
      final ventureRef = firestore.collection('ventures').doc(ventureId);

      final requestRef = firestore.collection("requests").doc();

      final requestQuery = await firestore
          .collection('requests')
          .where("ventureId", isEqualTo: ventureId)
          .get();

      final snap = await ventureRef.get();
      if (snap['creator'] == userRef) {
        MySnackBar.show(context,
            content: const Text("You can't join your own venture!"));
        return;
      }
      for (QueryDocumentSnapshot doc in requestQuery.docs) {
        // Check the status field of the document
        if (doc['status'] == 'accepted' && doc['creatorId'] != userId) {
          return;
        }
      }
      final ventureSnap = await ventureRef.get();
      if (ventureSnap['member_num'] >= ventureSnap['max_people']) {
        MySnackBar.show(context, content: const Text("This venture is full"));
        return;
      }
      final data = snap.data() as Map<String, dynamic>;
      final DocumentReference creator = data["creator"];
      final creatorId = creator.id;
      final String requester = userData['username'];

      await requestRef.set({
        'creatorId': creatorId,
        'requestId': requestRef.id,
        'requesterId': userId,
        'requester': requester,
        'ventureId': ventureId,
        'status': 'pending',
        'timestamp': FieldValue.serverTimestamp(),
        'seenBy': [],
      });

      MySnackBar.show(context,
          content: const Text("You sent a request to join the venture"));
    } catch (error, stackTrace) {
      // Handle error and report to Firebase Crashlytics
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to send join request',
      );
      // Show error message to user
      MySnackBar.show(context,
          content: const Text('Failed to send join request'));
    } finally {
      setState(() {
        _isButtonDisabled = false;
      });
    }
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
          content:
              const Text("You cancelled your request to join the venture"));
    } catch (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to cancel join request',
      );

      // Show error message to user
      MySnackBar.show(context,
          content: Text('Failed to cancel join request: $error'));
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

  @override
  Widget build(BuildContext context) {
    if (widget.usersProvider.ventures.isEmpty &&
        !widget.usersProvider.hasNext) {
      return const Center(
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
        ...widget.usersProvider.ventures.map((venture) {
          final userId = FirebaseAuth.instance.currentUser!.uid;
          final isCreator = venture.creator!.id == userId;

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(
                  width: 1, color: const Color.fromARGB(255, 214, 214, 214)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${venture.country}",
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 30)),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${venture.memberNum} / ${venture.maxPeople}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20),
                          ),
                        ),
                        const Icon(Icons.people_alt),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProfileView(
                                        userId: venture.creator!.id)));
                          },
                          child: Text(
                            venture.creatorName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                        ),
                        if (isCreator)
                          PopupMenuButton<String>(
                            onSelected: (value) async {
                              var firestore = FirebaseFirestore.instance;
                              final ventureId = venture.ventureId;
                              final ventureRef = firestore
                                  .collection("ventures")
                                  .doc(ventureId);
                              if (value == 'edit') {
                                final ventureSnap = await ventureRef.get();
                                final ventureData =
                                    ventureSnap.data() as Map<String, dynamic>;
                                showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return FractionallySizedBox(
                                          heightFactor:
                                              0.5, // Adjust this factor to control the height
                                          child: EditVenture(
                                              ventureRef: ventureRef,
                                              ventureData: ventureData));
                                    });
                              } else if (value == 'delete') {
                                deleteVenture(context, ventureRef, false);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("Profession",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text("${venture.industry}"),
                        )
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(venture.description!),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: StreamBuilder<QuerySnapshot>(
                            stream: checkRequestStatus(venture.ventureId),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else if (snapshot.hasData &&
                                  snapshot.data!.docs.isNotEmpty) {
                                var requestStatus =
                                    snapshot.data!.docs.first['status'];
                                return MyButton(
                                  onPressed: _isButtonDisabled
                                      ? () {}
                                      : () {
                                          if (requestStatus == 'pending') {
                                            cancelJoinRequest(
                                                venture.ventureId);
                                          } else {
                                            sendJoinRequest(venture.ventureId);
                                          }
                                        },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStateProperty.resolveWith<Color>(
                                      (states) => getButtonColor(requestStatus),
                                    ),
                                  ),
                                  child: Text(getButtonText(requestStatus)),
                                );
                              } else {
                                return MyButton(
                                  onPressed: _isButtonDisabled
                                      ? () {}
                                      : () {
                                          sendJoinRequest(venture.ventureId);
                                        },
                                  child: const Text("Join"),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
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
                              const Text(
                                'Duration ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${venture.estimatedWeeks}',
                              ),
                              const Text(" Weeks")
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
        }).toList(),
        if (widget.usersProvider.hasNext)
          Center(
            child: GestureDetector(
              onTap: () {},
              child: const SizedBox(
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
