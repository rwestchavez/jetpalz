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
      appBar: MyAppBar(title: widget.chatName),
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
                      return CircularProgressIndicator();
                    }

                    List<Message> messages = snapshot.data!.docs.map((doc) {
                      Map<String, dynamic> data =
                          doc.data() as Map<String, dynamic>;
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
                        return MessageBubble(
                          sender: message.sender,
                          content: message.content,
                          isMe: message.senderId == getCurrentUserId(),
                        );
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
                          sendMessage(widget.chatId, message);
                          _messageController.clear();
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
  final String sender;
  final String content;
  final bool isMe;

  MessageBubble({
    required this.sender,
    required this.content,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              sender,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
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
