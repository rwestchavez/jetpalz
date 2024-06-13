import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/request_model.dart';

class RequestProvider with ChangeNotifier {
  List<JoinRequest> _requests = [];
  bool _isLoading = true;
  String _userId = FirebaseAuth.instance.currentUser!.uid;

  List<JoinRequest> get requests => _requests;
  bool get isLoading => _isLoading;

  RequestProvider() {
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    FirebaseFirestore.instance
        .collection('requests')
        .where('creatorId', isEqualTo: _userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _requests =
          snapshot.docs.map((doc) => JoinRequest.fromDocument(doc)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> respondToRequest(JoinRequest request, String status) async {
    var firestore = FirebaseFirestore.instance;

    if (status == 'accepted') {
      var requesterRef = firestore.collection("users").doc(request.requesterId);
      // need to get the user ref, then get the chat reference, and look up that chat and add user refeence to aht chat
      var ventureSnap =
          await firestore.collection("ventures").doc(request.ventureId).get();
      var ventureData = ventureSnap.data() as Map<String, dynamic>;
      DocumentReference ventureRef =
          firestore.collection("ventures").doc(request.ventureId);
      ventureRef.update({
        'member_num': FieldValue.increment(1),
      });
      var userRef = firestore.collection("users").doc(_userId);
      var userSnap = await userRef.get();

      if (ventureData['chat'] == null) {
        DocumentReference chatRef = firestore.collection("venture_chats").doc();
        Map<String, dynamic> chatData = {
          'name': "${userSnap['username']}'s Venture",
          'members': [userRef, requesterRef],
          'created_time': FieldValue.serverTimestamp(),
          'last_message': "",
          'last_message_time': null,
          'last_message_sent_by': null,
        };
        await chatRef.set(chatData);

        // Update the venture document with the new chat reference
        await ventureRef.update({
          'chat': chatRef,
        });
      } else {
        DocumentReference chatRef = ventureData['chat'];
        // Add the user to the existing chat members array
        await chatRef.update({
          'members': FieldValue.arrayUnion([requesterRef]),
        });
      }
      await firestore.collection('requests').doc(request.requestId).update({
        'status': status,
      });
    }
    if (status == 'rejected') {}
    _fetchRequests();
  }
}
