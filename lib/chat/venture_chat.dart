import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_snack_bar.dart';
import 'package:jet_palz/helpers/delete_venture.dart';
import 'package:jet_palz/helpers/edit_venture.dart';
import 'package:jet_palz/profile/profile_view.dart';

class VentureChat extends StatefulWidget {
  final String chatName;
  final String lastMessage;
  final Timestamp? lastMessageTime;
  final String? lastMessageSentBy;
  final List<dynamic> members;
  final String chatId;
  final DocumentReference? ventureRef;

  const VentureChat({
    super.key,
    required this.ventureRef,
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
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  final int _messageLimit = 10;
  List<DocumentSnapshot> _messages = [];
  DocumentSnapshot? _lastMessageSnapshot;
  bool _isLoading = false;
  bool _hasNext = true;
  int _memberCount = 0;

  StreamSubscription<DocumentSnapshot>? _ventureRefSubscription;

  @override
  void initState() {
    super.initState();
    _ventureRefSubscription = widget.ventureRef?.snapshots().listen((event) {
      if (event.exists) {
        var data = event.data() as Map<String, dynamic>?;
        if (data != null &&
            data['deleted'] == true &&
            widget.members[0].id != FirebaseAuth.instance.currentUser!.uid) {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          MySnackBar.show(context,
              content: const Text("This venture has been deleted"));
        }
      }
    });
    _loadMessages();
    _fetchMemberCount();

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

  void _fetchMemberCount() async {
    DocumentSnapshot chatDoc =
        await firestore.collection('venture_chats').doc(widget.chatId).get();
    List<dynamic> members = chatDoc['members'] ?? [];
    setState(() {
      _memberCount = members.length;
    });
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
      'senderId': userId,
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

  Future<void> _showVentureInfo() async {
    DocumentSnapshot ventureSnapshot = await widget.ventureRef!.get();
    Map<String, dynamic> ventureData =
        ventureSnapshot.data() as Map<String, dynamic>;
    final DocumentReference creatorRef = ventureData['creator'];
    final DocumentSnapshot creatorSnap = await creatorRef.get();
    final creatorData = creatorSnap.data() as Map<String, dynamic>;
    final DocumentReference chatRef = ventureData['chat'];
    final chatSnap = await chatRef.get();

    // Fetch member data
    List<Widget> memberAvatars = [];
    for (var memberRef in chatSnap['members']) {
      DocumentSnapshot memberSnap = await memberRef.get();
      var memberData = memberSnap.data() as Map<String, dynamic>;
      memberAvatars.add(
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileView(userId: memberRef.id),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              backgroundColor: Colors.transparent,
              radius: 20,
              backgroundImage: NetworkImage(memberData['photo_url']),
            ),
          ),
        ),
      );
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            widget.chatName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Row of member profile pictures
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: memberAvatars),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Country: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          ventureData['country'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Leader: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          creatorData['username'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profession: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          ventureData['industry'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Starting Month: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          ventureData['starting_month'].toString(),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Estimated Weeks: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          ventureData['estimated_weeks'].toString(),
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          ventureData['description'],
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close',
                  style: TextStyle(color: Theme.of(context).primaryColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLeaveConfirmation() async {
    bool confirmLeave = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Chat'),
          content: const Text('Are you sure you want to leave this chat?'),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  child: Text('Yes',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                ),
                TextButton(
                  child: Text('No',
                      style: TextStyle(color: Theme.of(context).primaryColor)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirmLeave) {
      _leaveChat();
    }
  }

  void _leaveChat() async {
    try {
      var userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot ventureSnapshot = await widget.ventureRef!.get();
      Map<String, dynamic> ventureData =
          ventureSnapshot.data() as Map<String, dynamic>;
      final DocumentReference creatorRef = ventureData['creator'];

      final DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      final DocumentReference chatRef = FirebaseFirestore.instance
          .collection('venture_chats')
          .doc(widget.chatId);
      DocumentSnapshot chatSnapshot = await chatRef.get();
      Map<String, dynamic> chatData =
          chatSnapshot.data() as Map<String, dynamic>;
      final List members = chatData['members'];

      if (creatorRef.id == userId) {
        if (members.length > 1) {
          DocumentReference newCreatorRef =
              members.firstWhere((ref) => ref.id != userId);
          await widget.ventureRef!.update({
            'creator': newCreatorRef,
            'member_num': FieldValue.increment(-1)
          });
          await chatRef.update({
            'members': FieldValue.arrayRemove([userRef]),
          });
        } else {
          await widget.ventureRef!.delete();
          await chatRef.delete();
        }
      } else {
        await chatRef.update({
          'members': FieldValue.arrayRemove([userRef]),
        });
        await widget.ventureRef!
            .update({'member_num': FieldValue.increment(-1)});
      }
      var requests = await FirebaseFirestore.instance
          .collection("requests")
          .where("requesterId", isEqualTo: userId)
          .where("ventureId", isEqualTo: widget.ventureRef!.id)
          .limit(1)
          .get();
      var requestRef = requests.docs.first.reference;
      requestRef.delete();

      Navigator.of(context).pop();
      MySnackBar.show(context,
          content: const Text("You have left the venture"));
    } catch (e) {
      MySnackBar.show(context, content: Text("Error $e"));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _ventureRefSubscription?.cancel(); // Cancel subscription on dispose

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
              Text(
                '$_memberCount members',
                style: const TextStyle(fontSize: 14.0),
              ),
            ],
          ),
          actions: [
            FutureBuilder(
              future: widget.ventureRef!.get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final ventureData =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    onSelected: (value) {
                      if (value == 'leave') {
                        _showLeaveConfirmation();
                      } else if (value == 'info') {
                        _showVentureInfo();
                      } else if (value == 'edit') {
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return FractionallySizedBox(
                                  heightFactor:
                                      0.5, // Adjust this factor to control the height
                                  child: EditVenture(
                                      ventureRef: widget.ventureRef!,
                                      ventureData: ventureData));
                            });
                      } else if (value == 'delete') {
                        deleteVenture(context, widget.ventureRef!, false);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      List<PopupMenuEntry<String>> menuItems = [
                        const PopupMenuItem<String>(
                          value: 'info',
                          child: ListTile(
                            leading: Icon(Icons.info),
                            title: Text('Info'),
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'leave',
                          child: ListTile(
                            leading: Icon(Icons.exit_to_app),
                            title: Text('Leave'),
                          ),
                        ),
                      ];

                      // Check if the current user is the creator of the venture
                      if (ventureData['creator'].id ==
                          FirebaseAuth.instance.currentUser!.uid) {
                        menuItems.insert(
                          1,
                          const PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                            ),
                          ),
                        );
                        menuItems.insert(
                          2,
                          const PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Delete'),
                            ),
                          ),
                        );
                      }

                      return menuItems;
                    },
                  );
                } else {
                  return Container();
                }
              },
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

  // Implement methods _leaveChat and _showChatInfo as needed

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
    super.key,
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
          const Padding(
            padding: EdgeInsets.all(8.0),
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
                senderId: message['senderId'],
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
  final String senderId;

  const MessageBubble(
      {super.key,
      required this.content,
      required this.timestamp,
      required this.isSentByMe,
      required this.pfpUrl,
      required this.username,
      required this.senderId});

  @override
  Widget build(BuildContext context) {
    var alignment =
        isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    var backgroundColor = isSentByMe ? Colors.blue[200] : Colors.grey[300];
    var bubbleAlignment =
        isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start;
    var radius = const BorderRadius.all(Radius.circular(12));

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
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ProfileView(userId: senderId)));
                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    radius: 20,
                    backgroundImage: NetworkImage(pfpUrl),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: radius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18, // Increased font size
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        content,
                        style: const TextStyle(
                            fontSize: 18), // Increased font size
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(timestamp),
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (isSentByMe) ...[
                CircleAvatar(
                  backgroundColor: Colors.transparent,
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
    super.key,
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
                  decoration: const InputDecoration(
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
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            color: Theme.of(context).primaryColor,
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}
