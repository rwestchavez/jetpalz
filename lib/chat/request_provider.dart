import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/request_model.dart';

class RequestProvider with ChangeNotifier {
  List<JoinRequest> _requests = [];
  List<JoinRequest> _acceptedRequests = [];
  List<JoinRequest> _rejectedRequests = [];

  bool _isLoading = true;
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  List<JoinRequest> get requests => _requests;
  List<JoinRequest> get acceptedRequests => _acceptedRequests;
  List<JoinRequest> get rejectedRequests => _rejectedRequests;

  bool get isLoading => _isLoading;

  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    try {
      // Request permission and get FCM token
      await _firebaseMessaging.requestPermission();
    } catch (e, stackTrace) {
      // Handle errors
      print('Error initializing notifications: $e');
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }

  Future<String> getCreatorUsername(String creatorId) async {
    try {
      var creatorSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(creatorId)
          .get();
      if (creatorSnapshot.exists) {
        var creatorData = creatorSnapshot.data() as Map<String, dynamic>;
        return creatorData['username'] ?? 'Unknown User';
      } else {
        return 'Unknown User';
      }
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
      return 'Unknown User';
    }
  }

  RequestProvider() {
    _fetchRequests();
    _fetchAcceptedRequests();
    _fetchRejectedRequests();
  }

  Future<void> _fetchRequests() async {
    try {
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
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  Future<void> _fetchAcceptedRequests() async {
    try {
      FirebaseFirestore.instance
          .collection('requests')
          .where('creatorId', isEqualTo: _userId)
          .where('status', isEqualTo: 'accepted')
          .snapshots()
          .listen((snapshot) {
        final filteredRequests = snapshot.docs.where((doc) {
          List<dynamic> seenBy = doc['seenBy'] ?? [];
          return !seenBy.contains(_userId);
        }).toList();

        _acceptedRequests = filteredRequests
            .map((doc) => JoinRequest.fromDocument(doc))
            .toList();

        notifyListeners();
      });
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  Future<void> _fetchRejectedRequests() async {
    try {
      FirebaseFirestore.instance
          .collection('requests')
          .where('requesterId', isEqualTo: _userId)
          .where('status', isEqualTo: 'rejected')
          .snapshots()
          .listen((snapshot) {
        final filteredRequests = snapshot.docs.where((doc) {
          List<dynamic> seenBy = doc['seenBy'] ?? [];
          return !seenBy.contains(_userId);
        }).toList();

        _rejectedRequests = filteredRequests
            .map((doc) => JoinRequest.fromDocument(doc))
            .toList();

        notifyListeners();
      });
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  Future<void> respondToRequest(JoinRequest request, String status) async {
    try {
      var firestore = FirebaseFirestore.instance;

      if (status == 'accepted') {
        var requesterRef =
            firestore.collection("users").doc(request.requesterId);
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
          DocumentReference chatRef =
              firestore.collection("venture_chats").doc();
          Map<String, dynamic> chatData = {
            'name': "${userSnap['username']}'s Venture",
            'members': [userRef, requesterRef],
            'created_time': FieldValue.serverTimestamp(),
            'last_message': "",
            'last_message_time': null,
            'last_message_sent_by': null,
            'venture': ventureRef,
          };
          await chatRef.set(chatData);

          await ventureRef.update({
            'chat': chatRef,
          });
        } else {
          DocumentReference chatRef = ventureData['chat'];
          await chatRef.update({
            'members': FieldValue.arrayUnion([requesterRef]),
          });
        }

        await firestore.collection('requests').doc(request.requestId).update({
          'status': status,
        });
      } else if (status == 'rejected') {
        await firestore.collection('requests').doc(request.requestId).update({
          'status': status,
        });
      }

      _fetchRequests();
      _fetchAcceptedRequests();
      _fetchRejectedRequests();
    } catch (e, stackTrace) {
      _handleError(e, stackTrace);
    }
  }

  void _handleError(dynamic e, StackTrace stackTrace) {
    FirebaseCrashlytics.instance
        .recordError(e, stackTrace, reason: "request provider error");
    _isLoading = false; // Set loading state to false on error
    notifyListeners(); // Notify listeners to update UI
  }
}
