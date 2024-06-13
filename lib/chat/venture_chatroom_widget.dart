import 'package:cloud_firestore/cloud_firestore.dart';
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
    super.key,
    required this.chatId,
    required this.chatName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSentBy,
    required this.members,
  });

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
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // Set the border color to light grey
            width: 2.0, // Set the border width
          ),
          borderRadius: BorderRadius.circular(
              8.0), // Add rounded corners to the container
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display chatName
                    if (chatName.isNotEmpty) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chatName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              color: Colors
                                  .red, // Placeholder color for unread messages
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '3', // Placeholder for number of unread messages
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                    ],

                    // Display last message
                    if (lastMessage.isNotEmpty) ...[
                      Row(
                        children: [
                          if (lastMessageSentBy != null)
                            Text('$lastMessageSentBy: ')
                          else
                            Text(''),
                          Expanded(
                            child: Text(
                              lastMessage,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (timeAgo.isNotEmpty) ...[
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                timeAgo,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
