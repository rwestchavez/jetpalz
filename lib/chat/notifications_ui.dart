import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appbar.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'request_provider.dart';

class NotificationsUI extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Notifications",
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (provider.requests.isEmpty &&
              provider.acceptedRequests.isEmpty &&
              provider.rejectedRequests.isEmpty) {
            return Center(child: Text('No pending requests or notifications'));
          } else {
            return ListView.builder(
              itemCount: provider.requests.length +
                  provider.acceptedRequests.length +
                  provider.rejectedRequests.length,
              itemBuilder: (context, index) {
                if (index < provider.requests.length) {
                  // Display pending requests
                  final request = provider.requests[index];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('ventures')
                        .doc(request.ventureId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Container();
                      } else {
                        var ventureData =
                            snapshot.data!.data() as Map<String, dynamic>;

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              '${request.requester} wants to join your venture!',
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8.0),
                                Text(
                                  'Requested ${timeago.format(request.timestamp)}',
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.grey),
                                ),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon:
                                        Icon(Icons.check, color: Colors.green),
                                    onPressed: () {
                                      provider.respondToRequest(
                                          request, 'accepted');
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      provider.respondToRequest(
                                          request, 'rejected');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                    },
                  );
                } else if (index <
                    provider.requests.length +
                        provider.acceptedRequests.length) {
                  final acceptedRequest = provider
                      .acceptedRequests[index - provider.requests.length];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('requests')
                        .doc(acceptedRequest.requestId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              "",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      } else {
                        var requestData =
                            snapshot.data!.data() as Map<String, dynamic>;

                        return FutureBuilder<String>(
                          future: provider
                              .getCreatorUsername(requestData['creatorId']),
                          builder: (context, usernameSnapshot) {
                            if (usernameSnapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Error: ${usernameSnapshot.error}'));
                            } else {
                              DateTime requestTime =
                                  (requestData['timestamp'] as Timestamp)
                                      .toDate();
                              return GestureDetector(
                                onTap: () {
                                  var currentUserId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  if (!requestData['seenBy']
                                      .contains(currentUserId)) {
                                    FirebaseFirestore.instance
                                        .collection('requests')
                                        .doc(acceptedRequest.requestId)
                                        .update({
                                      'seenBy':
                                          FieldValue.arrayUnion([currentUserId])
                                    });
                                  }
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: ListTile(
                                    title: Text(
                                      '${requestData['requester']} joined ${usernameSnapshot.data}\'s venture!',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Joined ${timeago.format(requestTime)}',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Colors.grey),
                                    ),
                                    trailing: Icon(Icons.check_circle,
                                        color: Colors.green),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                } else {
                  final rejectedRequest = provider.rejectedRequests[index -
                      provider.requests.length -
                      provider.acceptedRequests.length];
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('requests')
                        .doc(rejectedRequest.requestId)
                        .get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            title: Text(
                              "",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        );
                      } else {
                        var requestData =
                            snapshot.data!.data() as Map<String, dynamic>;

                        return FutureBuilder<String>(
                          future: provider
                              .getCreatorUsername(requestData['creatorId']),
                          builder: (context, usernameSnapshot) {
                            if (usernameSnapshot.hasError) {
                              return Center(
                                  child:
                                      Text('Error: ${usernameSnapshot.error}'));
                            } else {
                              DateTime requestTime =
                                  (requestData['timestamp'] as Timestamp)
                                      .toDate();
                              return GestureDetector(
                                onTap: () {
                                  var currentUserId =
                                      FirebaseAuth.instance.currentUser!.uid;
                                  if (!requestData['seenBy']
                                      .contains(currentUserId)) {
                                    FirebaseFirestore.instance
                                        .collection('requests')
                                        .doc(rejectedRequest.requestId)
                                        .update({
                                      'seenBy':
                                          FieldValue.arrayUnion([currentUserId])
                                    });
                                  }
                                },
                                child: Card(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: ListTile(
                                    title: Text(
                                      'You were rejected from ${usernameSnapshot.data}\'s venture.',
                                      style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Rejected ${timeago.format(requestTime)}',
                                      style: TextStyle(
                                          fontSize: 14.0, color: Colors.grey),
                                    ),
                                    trailing:
                                        Icon(Icons.cancel, color: Colors.red),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }
                    },
                  );
                }
              },
            );
          }
        },
      ),
    );
  }
}
