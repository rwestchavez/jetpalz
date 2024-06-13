import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_appBar.dart';
import 'package:jet_palz/main.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VentureChat extends StatefulWidget {
  final String chatName;
  final String lastMessage;
  final Timestamp lastMessageTime;
  final String lastMessageSentBy;
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

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          actions: [TextButton(onPressed: () {}, child: Text("Leave"))],
          centerTitle: true,
          title: Column(children: [
            Text(
              widget.chatName,
              style: TextStyle(fontSize: 18),
            ),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('venture_chats')
                  .doc(widget.chatId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }

                var chatData = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> members = chatData['members'] ?? [];

                return Text(
                  '${members.length} members',
                  style: TextStyle(fontSize: 14.0),
                );
              },
            ),
          ])),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('venture_chats')
                      .doc(widget.chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }

                    List<Message> messages = snapshot.data!.docs.map((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      return Message(
                        senderId: data['senderId'] ?? '',
                        sender: data['sender'] ?? '',
                        content: data['content'] ?? '',
                        timestamp: data['timestamp'] ?? 0,
                      );
                    }).toList();

                    return ListView.builder(
                      reverse: true,
                      padding: EdgeInsets.all(16.0),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        Message message = messages[index];
                        return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('users')
                                .doc(message.senderId)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                // Show a loading indicator or placeholder widget
                                return Container();
                              }

                              if (!snapshot.hasData || snapshot.data == null) {
                                // Handle the case where snapshot.data is null
                                return Text('No user data found');
                              }

                              var userData =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              String pfp = userData['photo_url'];

                              return MessageBubble(
                                senderId: message.senderId,
                                sender: message.sender,
                                content: message.content,
                                isMe: message.senderId == getCurrentUserId(),
                                pfp: pfp,
                                messageTime: message.timestamp.toDate(),
                              );
                            });
                      },
                    );
                  },
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30.0),
                ),
                margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 16.0),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (message) {
                          if (message != "") {
                            sendMessage(widget.chatId, message);
                            _messageController.clear();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        String message = _messageController.text;
                        sendMessage(widget.chatId, message);
                        _messageController.clear();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage(String chatId, String message) async {
    var firestore = FirebaseFirestore.instance;
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;
    String currentUserId = currentUser!.uid;
    CollectionReference messageCollection = firestore
        .collection('venture_chats')
        .doc(chatId)
        .collection('messages');
    DocumentReference userRef =
        firestore.collection('users').doc(currentUser.uid);
    var userSnap = await userRef.get();
    var userData = userSnap.data() as Map<String, dynamic>;
    String sender = userData['username'];

    await messageCollection.add({
      'senderId': currentUserId,
      'sender': sender,
      'content': message,
      'timestamp': Timestamp.now(),
    });
  }

  String getCurrentUserId() {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;
    return currentUser!.uid;
  }
}

class MessageBubble extends StatelessWidget {
  final String senderId;
  final String sender;
  final String content;
  final bool isMe;
  final String pfp;
  final DateTime messageTime;

  MessageBubble({
    required this.pfp,
    required this.senderId,
    required this.sender,
    required this.content,
    required this.isMe,
    required this.messageTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(
                      pfp), // Replace pfp with the URL of the profile picture
                  radius: 16.0,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  sender,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
          ],
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(
                    height:
                        4.0), // Add some spacing between content and timestamp
                Text(
                  '${messageTime.hour}:${messageTime.minute}',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 12.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String senderId;
  final String sender;
  final String content;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.sender,
    required this.content,
    required this.timestamp,
  });
}
