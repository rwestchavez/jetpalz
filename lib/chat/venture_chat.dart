import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VentureChat extends StatefulWidget {
  final String chatName;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final String? lastMessageSentBy;
  final List<dynamic> members;
  final String chatId;

  const VentureChat({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSentBy,
    required this.members,
  });

  @override
  _VentureChatState createState() => _VentureChatState();
}

class _VentureChatState extends State<VentureChat> {
  final TextEditingController _messageController = TextEditingController();
  var firestore = FirebaseFirestore.instance;

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var userRef = firestore.collection("users").doc(userId);
    var userSnap = await userRef.get();

    String pfpUrl = userSnap["photo_url"];
    String username = userSnap['username'];

    firestore
        .collection('venture_chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'content': _messageController.text.trim(),
      'sentBy': FirebaseAuth.instance.currentUser!.uid,
      'timestamp': Timestamp.now(),
      'pfpUrl': pfpUrl,
      'senderName': username,
      'seenBy': [userId],
    });
    await firestore.collection('venture_chats').doc(widget.chatId).update({
      'last_message': _messageController.text.trim(),
      'last_message_time': Timestamp.now(),
      'last_message_sent_by': userRef,
    });
    _messageController.clear();
  }

  void markMessageSeen(String messageId) async {
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var userRef = firestore.collection("users").doc(userId);

    // Update seenBy array in the message document
    var messageRef = firestore
        .collection('venture_chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId);

    // Get current seenBy array
    var messageSnap = await messageRef.get();
    List<dynamic> seenBy = messageSnap.get('seenBy');

    // Add user reference if not already present
    if (!seenBy.contains(userId)) {
      seenBy.add(userId);
      await messageRef.update({'seenBy': seenBy});
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              Text(widget.chatName, style: const TextStyle(fontSize: 18)),
              FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('venture_chats')
                    .doc(widget.chatId)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  }

                  var chatData = snapshot.data!.data() as Map<String, dynamic>;
                  List<dynamic> members = chatData['members'] ?? [];

                  return Text(
                    '${members.length} members',
                    style: const TextStyle(fontSize: 14.0),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: const Text("Leave"),
            ),
          ],
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child:
                  MessagesList(chatId: widget.chatId, check: markMessageSeen),
            ),
            SendMessageBar(
              messageController: _messageController,
              onSend: () => sendMessage(),
            ),
          ],
        ),
      ),
    );
  }
}

class MessagesList extends StatelessWidget {
  final String chatId;
  final Function(String) check;

  const MessagesList({required this.chatId, required this.check});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('venture_chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var messages = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            var message = messages[index];
            var isSentByMe =
                message['sentBy'] == FirebaseAuth.instance.currentUser!.uid;

            if (!isSentByMe) {
              check(message.id);
            }

            return MessageBubble(
              content: message['content'],
              timestamp: message['timestamp'],
              isSentByMe: isSentByMe,
              pfpUrl: message['pfpUrl'],
              username: message['senderName'],
            );
          },
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String content;
  final Timestamp timestamp;
  final bool isSentByMe;
  final String pfpUrl;
  final String username;

  const MessageBubble({
    required this.content,
    required this.timestamp,
    required this.isSentByMe,
    required this.pfpUrl,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    var alignment =
        isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    var backgroundColor = isSentByMe ? Colors.blue[200] : Colors.grey[300];
    var bubbleAlignment =
        isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    var radius = BorderRadius.all(Radius.circular(12));

    /* var radius = isSentByMe
        ? BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          )
        : BorderRadius.only(
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          );*/

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisAlignment: bubbleAlignment,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isSentByMe) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(pfpUrl),
                ),
                SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: radius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        content,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatTimestamp(timestamp),
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              if (isSentByMe) ...[
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(pfpUrl),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    var date = timestamp.toDate();
    String hour = date.hour.toString().padLeft(2, '0'); // Ensures 2-digit hour
    String minute =
        date.minute.toString().padLeft(2, '0'); // Ensures 2-digit minute
    return '$hour:$minute';
  }
}

class SendMessageBar extends StatelessWidget {
  final TextEditingController messageController;
  final void Function() onSend;

  const SendMessageBar({
    required this.messageController,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    75, 187, 222, 251), // Adjust the color here
                borderRadius:
                    BorderRadius.circular(20.0), // Adjust the border radius
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none, // No border for the TextField
                  ),
                  onSubmitted: (_) {
                    onSend();
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
