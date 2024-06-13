import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'venture_chatroom_widget.dart';

class VentureChatRoom extends StatefulWidget {
  const VentureChatRoom({Key? key});

  @override
  State<VentureChatRoom> createState() => _VentureChatState();
}

class _VentureChatState extends State<VentureChatRoom> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? currentUser;
  DocumentReference? userDoc;
  late CollectionReference venturesRef;
  late CollectionReference chatsRef;
  late Query query;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);
    venturesRef = FirebaseFirestore.instance.collection('ventures');
    chatsRef = FirebaseFirestore.instance.collection('venture_chats');

    query = FirebaseFirestore.instance
        .collection('venture_chats')
        .where('members', arrayContains: userDoc)
        .orderBy('last_message_time', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Handle the loading state if needed
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle the error state if an error occurred
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final chatDocuments = snapshot.data!.docs;

            return ListView.builder(
              itemCount: chatDocuments.length,
              itemBuilder: (context, index) {
                final chatName = chatDocuments[index]['name'] as String;
                final members = chatDocuments[index]['members'] as List;
                final lastMessage =
                    chatDocuments[index]['last_message'] as String;
                final lastMessageTime =
                    chatDocuments[index]['last_message_time'] as Timestamp;
                final lastMessageSentByRef = chatDocuments[index]
                    ['last_message_sent_by'] as DocumentReference;
                return StreamBuilder<DocumentSnapshot>(
                  stream: lastMessageSentByRef.snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                    if (userSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (userSnapshot.hasError) {
                      return Text('Error: ${userSnapshot.error}');
                    } else if (userSnapshot.hasData) {
                      final data =
                          userSnapshot.data?.data() as Map<String, dynamic>;
                      final lastMessageSentBy = data['username'] as String;

                      return VentureChatRoomWidget(
                        chatName: chatName,
                        lastMessage: lastMessage,
                        lastMessageTime: lastMessageTime,
                        lastMessageSentBy: lastMessageSentBy,
                        members: members,
                        chatId: chatDocuments[index].id,
                      );
                    } else {
                      return Text('No user data available');
                    }
                  },
                );
              },
            ); // Replace YourWidget with the widget you want to return
          } else {
            // Handle the case when there is no data
            return Text('No data available');
          }
        },
      ),
    );
  }
}
