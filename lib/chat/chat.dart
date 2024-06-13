import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appbar.dart';
import 'package:provider/provider.dart';
import 'chat_provider.dart';
import 'venture_chatroom_widget.dart';
import 'package:badges/badges.dart' as badges;

import 'request_provider.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: "Venture Chats",
        automaticallyImplyLeading: false,
        actions: [
          Consumer<RequestProvider>(
            builder: (context, requestProvider, child) {
              int requestCount = requestProvider.requests.length;

              // Return IconButton with or without Badge based on requestCount
              if (requestCount > 0) {
                return badges.Badge(
                  badgeStyle: badges.BadgeStyle(padding: EdgeInsets.all(8)),
                  position: badges.BadgePosition.topEnd(top: 0, end: 4),
                  badgeContent: Text(
                    requestCount.toString(),
                    style: TextStyle(color: Colors.white),
                  ),
                  child: IconButton(
                    iconSize: 40,
                    onPressed: () {
                      Navigator.pushNamed(context, '/notifications');
                    },
                    icon: Icon(Icons.notifications),
                  ),
                );
              } else {
                // Return IconButton without Badge
                return IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/notifications');
                  },
                  iconSize: 40,
                  icon: Icon(Icons.notifications),
                );
              }
            },
          ),
          SizedBox(width: 16),
        ],
      ),
      body: VentureChatRoom(),
    );
  }
}

class VentureChatRoom extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    if (chatProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      itemCount: chatProvider.chatDocuments.length,
      itemBuilder: (context, index) {
        final chatDocument = chatProvider.chatDocuments[index];
        final String chatName = chatDocument['name'];
        final List members = chatDocument['members'];
        final String lastMessage = chatDocument['last_message'];
        final Timestamp? lastMessageTime = chatDocument['last_message_time'];
        final DocumentReference? lastMessageSentByRef =
            chatDocument['last_message_sent_by'];

        if (lastMessageSentByRef == null) {
          return VentureChatRoomWidget(
            chatName: chatName,
            lastMessage: lastMessage,
            lastMessageTime: lastMessageTime,
            lastMessageSentBy: null,
            members: members,
            chatId: chatDocument.id,
          );
        }

        return StreamBuilder<DocumentSnapshot>(
          stream: lastMessageSentByRef.snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (userSnapshot.hasError) {
              return Center(child: Text('Error: ${userSnapshot.error}'));
            } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final data = userSnapshot.data!.data() as Map<String, dynamic>;
              final String lastMessageSentBy = data['username'];

              return VentureChatRoomWidget(
                chatName: chatName,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                lastMessageSentBy: lastMessageSentBy,
                members: members,
                chatId: chatDocument.id,
              );
            } else {
              return VentureChatRoomWidget(
                chatName: chatName,
                lastMessage: lastMessage,
                lastMessageTime: lastMessageTime,
                lastMessageSentBy: null,
                members: members,
                chatId: chatDocument.id,
              );
            }
          },
        );
      },
    );
  }
}
