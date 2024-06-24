import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
    try {
      currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("Current user is null");
      }

      userDoc =
          FirebaseFirestore.instance.collection('users').doc(currentUser!.uid);

      var query = FirebaseFirestore.instance
          .collection('venture_chats')
          .where('members', arrayContains: userDoc)
          .orderBy('last_message_time', descending: true);

      query.snapshots().listen((snapshot) {
        _chatDocuments = snapshot.docs;
        _isLoading = false;
        notifyListeners();
      });
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  void _handleError(dynamic e, StackTrace stackTrace) {
    FirebaseCrashlytics.instance.recordError(e, stackTrace, reason: "chat provider error");
    _isLoading = false; // Set loading state to false on error
    notifyListeners(); // Notify listeners to update UI
  }
}
