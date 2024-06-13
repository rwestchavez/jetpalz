import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatProvider with ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? currentUser;
  DocumentReference? userDoc;
  List<QueryDocumentSnapshot> _chatDocuments = [];
  bool _isLoading = true;

  List<QueryDocumentSnapshot> get chatDocuments => _chatDocuments;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _fetchChats();
  }

  void _fetchChats() async {
    currentUser = FirebaseAuth.instance.currentUser;
    userDoc =
        FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

    var query = firestore
        .collection('venture_chats')
        .where('members', arrayContains: userDoc)
        .orderBy('last_message_time', descending: true);

    query.snapshots().listen((snapshot) {
      _chatDocuments = snapshot.docs;
      _isLoading = false;
      notifyListeners();
    });
  }
}
