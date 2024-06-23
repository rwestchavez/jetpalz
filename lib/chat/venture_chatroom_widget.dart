import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/constants.dart';
import 'venture_chat.dart';

class VentureChatRoomWidget extends StatelessWidget {
  final String chatName;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final String? lastMessageSentBy;
  final List members;
  final String chatId;
  final String? creatorPfp;
  final DocumentReference ventureRef;

  const VentureChatRoomWidget({
    Key? key,
    required this.ventureRef,
    required this.chatId,
    required this.chatName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSentBy,
    required this.members,
    required this.creatorPfp,
  }) : super(key: key);

  Stream<int> fetchUnreadMessagesCount(String chatId, String userId) {
    var messagesQuery = FirebaseFirestore.instance
        .collection('venture_chats')
        .doc(chatId)
        .collection('messages');

    return messagesQuery.snapshots().map((QuerySnapshot snapshot) {
      List<DocumentSnapshot> documents = snapshot.docs;

      var unreadMessages = documents.where((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return !data['seenBy'].contains(userId);
      }).toList();

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

    return StreamBuilder<int>(
      stream: fetchUnreadMessagesCount(chatId, getCurrentUserId()),
      builder: (context, snapshot) {
        int unreadCount = snapshot.data ?? 0;
        bool hasUnreadMessages = unreadCount > 0;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VentureChat(
                  ventureRef: ventureRef,
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
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.transparent,
                  backgroundImage: creatorPfp == null
                      ? const NetworkImage(DefaultPfp)
                      : NetworkImage(creatorPfp!),
                  radius: 30.0, // Increased avatar size
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chatName,
                        style: TextStyle(
                          fontSize: 16.0, // Increased font size
                          fontWeight: FontWeight.bold,
                          color: hasUnreadMessages ? Colors.black : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        lastMessage.isNotEmpty
                            ? '${lastMessageSentBy ?? ''}: $lastMessage'
                            : 'No messages yet',
                        style: TextStyle(
                          fontSize: 14.0, // Increased font size
                          color: hasUnreadMessages ? Colors.black : Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        timeAgo,
                        style: TextStyle(
                          fontSize: 12.0, // Increased font size
                          color: hasUnreadMessages ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasUnreadMessages)
                  Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getCurrentUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;
    return currentUser!.uid;
  }
}
