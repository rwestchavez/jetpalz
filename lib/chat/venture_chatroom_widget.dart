import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'venture_chat.dart';

class VentureChatRoomWidget extends StatelessWidget {
  final String chatName;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final String? lastMessageSentBy;
  final List members;
  final String chatId;

  const VentureChatRoomWidget({
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSentBy,
    required this.members,
  }) : super(key: key);

  Stream<int> getUnreadMessagesCountStream(String chatId, String userId) {
    var firestore = FirebaseFirestore.instance;
    var chatRef = firestore.collection('venture_chats').doc(chatId);
    var userRef = firestore.collection('users').doc(userId);

    return userRef.snapshots().asyncMap((userSnap) async {
      var userData = userSnap.data() as Map<String, dynamic>?;
      var lastReadTimestamp = userData?['lastRead']?[chatId] as Timestamp?;

      var messagesQuery = chatRef.collection('messages').where(
            'timestamp',
            isGreaterThan: lastReadTimestamp ?? Timestamp(0, 0),
          );

      var messagesSnap = await messagesQuery.get();
      var unreadMessages = messagesSnap.docs
          .where((doc) => !doc.data()['seenBy'].contains(userId))
          .toList();

      return unreadMessages.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    String timeAgo = '';
    if (lastMessageTime != null) {
      final DateTime lastMessageTimes = lastMessageTime!.toDate();
      final Duration difference = DateTime.now().difference(lastMessageTimes);

      if (difference.inDays > 0) {
        timeAgo =
            '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
      } else if (difference.inHours > 0) {
        timeAgo =
            '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      } else if (difference.inMinutes > 0) {
        timeAgo =
            '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
      } else {
        timeAgo = 'Just now';
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VentureChat(
              chatName: chatName,
              lastMessage: lastMessage,
              lastMessageTime: lastMessageTime,
              lastMessageSentBy: lastMessageSentBy,
              members: members,
              chatId: chatId,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[300]!,
              width: 1.0,
            ),
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chat Name
                Text(
                  chatName,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.0),
                // Last Message
                Text(
                  lastMessage.isNotEmpty
                      ? '${lastMessageSentBy ?? ''}: $lastMessage'
                      : 'No messages yet',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.0),
                // Time Ago
                Text(
                  timeAgo,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: StreamBuilder<int>(
                stream:
                    getUnreadMessagesCountStream(chatId, getCurrentUserId()),
                builder: (context, snapshot) {
                  int unreadCount = snapshot.data ?? 0;
                  return unreadCount > 0
                      ? Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                            ),
                          ),
                        )
                      : SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getCurrentUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;
    return currentUser!.uid;
  }
}
