import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'venture_chat.dart';

class VentureChatRoomWidget extends StatelessWidget {
  final String chatName;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final String lastMessageSentBy;
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
    final DateTime lastMessageTimes = lastMessageTime.toDate();
    final Duration difference = DateTime.now().difference(lastMessageTimes);

    String timeAgo = '';
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
          padding: EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 12.0, 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 12.0, 0.0),
                              child: Text(
                                chatName,
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(
                                0.0, 0.0, 8.0, 0.0),
                            child: Container(
                              width: 20.0,
                              height: 20.0,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 0, 0),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  width: 0.0,
                                ),
                              ),
                              child: Align(
                                alignment: AlignmentDirectional.center,
                                child: Text(
                                    // write here the number of unread messages
                                    '3',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            '$lastMessageSentBy: ', // the name of the user who messaged last
                          ),
                          Text(
                            lastMessage,
                            textAlign: TextAlign.start,
                          ),
                          Expanded(
                            child: Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: Text(
                                timeAgo,
                                textAlign: TextAlign.start,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
