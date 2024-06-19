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
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSentBy,
    required this.members,
  }) : super(key: key);

  @override
  _VentureChatState createState() => _VentureChatState();
}

class _VentureChatState extends State<VentureChat> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final int _messageLimit = 10;
  List<DocumentSnapshot> _messages = [];
  DocumentSnapshot? _lastMessageSnapshot;
  bool _isLoading = false;
  bool _hasNext = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if (_hasNext) {
        _loadMoreMessages();
      }
    }
  }

  void _loadMessages() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('venture_chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(_messageLimit);

    query.snapshots().listen((snapshot) {
      setState(() {
        _messages = snapshot.docs;
        _isLoading = false;
        if (snapshot.docs.isEmpty) {
          _hasNext = false;
        } else {
          _lastMessageSnapshot = snapshot.docs.last;
        }
      });
    });
  }

  void _loadMoreMessages() {
    if (_isLoading || !_hasNext) return;
    setState(() {
      _isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('venture_chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .startAfterDocument(_lastMessageSnapshot!)
        .limit(_messageLimit);

    query.get().then((snapshot) {
      setState(() {
        _messages.addAll(snapshot.docs);
        _isLoading = false;
        if (snapshot.docs.length < _messageLimit) {
          _hasNext = false;
        } else {
          _lastMessageSnapshot = snapshot.docs.last;
        }
      });
    });
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    var userId = FirebaseAuth.instance.currentUser!.uid;
    var userRef = firestore.collection("users").doc(userId);
    var userSnap = await userRef.get();

    String pfpUrl = userSnap["photo_url"];
    String username = userSnap['username'];

    await firestore
        .collection('venture_chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'content': _messageController.text.trim(),
      'sentBy': userId,
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
    _scrollToBottom();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
              Text(widget.chatName, style: const TextStyle(fontSize: 20)),
              StreamBuilder<DocumentSnapshot>(
                stream: firestore
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
              child: MessagesList(
                chatId: widget.chatId,
                messages: _messages,
                scrollController: _scrollController,
                isLoading: _isLoading,
                markMessageSeen: markMessageSeen,
              ),
            ),
            SendMessageBar(
              messageController: _messageController,
              onSend: sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void markMessageSeen(String messageId) async {
    var userId = FirebaseAuth.instance.currentUser!.uid;

    var messageRef = firestore
        .collection('venture_chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId);

    messageRef.snapshots().listen((DocumentSnapshot messageSnapshot) async {
      if (messageSnapshot.exists) {
        var data = messageSnapshot.data() as Map<String, dynamic>;
        List<dynamic> seenBy = data['seenBy'] ?? [];

        if (!seenBy.contains(userId)) {
          seenBy.add(userId);
          await messageRef.update({'seenBy': seenBy});
        }
      }
    });
  }
}

class MessagesList extends StatelessWidget {
  final String chatId;
  final List<DocumentSnapshot> messages;
  final ScrollController scrollController;
  final bool isLoading;
  final Function(String) markMessageSeen;

  const MessagesList({
    required this.chatId,
    required this.messages,
    required this.scrollController,
    required this.isLoading,
    required this.markMessageSeen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isLoading)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              var message = messages[index];
              var isSentByMe =
                  message['sentBy'] == FirebaseAuth.instance.currentUser!.uid;

              if (!isSentByMe) {
                markMessageSeen(message.id);
              }

              return MessageBubble(
                content: message['content'],
                timestamp: message['timestamp'],
                isSentByMe: isSentByMe,
                pfpUrl: message['pfpUrl'],
                username: message['senderName'],
              );
            },
          ),
        ),
      ],
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
                          fontSize: 18, // Increased font size
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        content,
                        style: TextStyle(fontSize: 18), // Increased font size
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
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
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
                color: const Color.fromARGB(75, 187, 222, 251),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: InputBorder.none,
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
