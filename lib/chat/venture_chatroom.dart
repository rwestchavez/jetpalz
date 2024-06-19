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

    query = chatsRef
        .where('members', arrayContains: userDoc)
        .orderBy('last_message_time', descending: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venture Chat Room'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final chatDocuments = snapshot.data!.docs;

            return ListView.builder(
              itemCount: chatDocuments.length,
              itemBuilder: (context, index) {
                final String chatName = chatDocuments[index]['name'];
                final List members = chatDocuments[index]['members'];
                final String lastMessage = chatDocuments[index]['last_message'];
                final Timestamp? lastMessageTime =
                    chatDocuments[index]['last_message_time'];
                final DocumentReference? lastMessageSentByRef =
                    chatDocuments[index]['last_message_sent_by'];
                final DocumentReference creatorRef =
                    chatDocuments[index]['creator'];

                return FutureBuilder<DocumentSnapshot>(
                  future: creatorRef.get(),
                  builder: (context, creatorSnapshot) {
                    if (creatorSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (creatorSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${creatorSnapshot.error}'));
                    } else if (creatorSnapshot.hasData &&
                        creatorSnapshot.data!.exists) {
                      final creatorData =
                          creatorSnapshot.data!.data() as Map<String, dynamic>;
                      final String creatorPfp = creatorData['photo_url'];

                      return StreamBuilder<DocumentSnapshot>(
                        stream: lastMessageSentByRef?.snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (userSnapshot.hasError) {
                            return Center(
                                child: Text('Error: ${userSnapshot.error}'));
                          } else if (userSnapshot.hasData &&
                              userSnapshot.data!.exists) {
                            final data = userSnapshot.data!.data()
                                as Map<String, dynamic>;
                            final String lastMessageSentBy = data['username'];

                            return VentureChatRoomWidget(
                              chatName: chatName,
                              lastMessage: lastMessage,
                              lastMessageTime: lastMessageTime,
                              lastMessageSentBy: lastMessageSentBy,
                              members: members,
                              chatId: chatDocuments[index].id,
                              creatorPfp: creatorPfp,
                            );
                          } else {
                            return VentureChatRoomWidget(
                              chatName: chatName,
                              lastMessage: lastMessage,
                              lastMessageTime: lastMessageTime,
                              lastMessageSentBy: null,
                              members: members,
                              chatId: chatDocuments[index].id,
                              creatorPfp: creatorPfp,
                            );
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                );
              },
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}
