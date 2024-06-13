import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jet_palz/app_state.dart';
import 'package:jet_palz/models/venture_model.dart';
import '../app_state.dart';
import "venture_provider.dart";
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'firebase_api.dart';

// this is meant to get ventures, not users

class VentureProvider extends ChangeNotifier {
  // final AppState appState = AppState();
  final _venturesSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  int documentLimit = 5;
  bool _hasNext = true;
  bool _isFetchingVentures = false; // Initialize AppState instance

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List<VentureModel> get ventures => _venturesSnapshot.map((snap) {
        // converts List of snapshots
        final doc = snap.data() as Map<String, dynamic>;

        return VentureModel(
          ventureId: snap.id,
          // Init a new object for each snapshot document
          country: doc['country'] ?? 'Unknown',
          creator: doc['creator'],
          industry: doc['industry'] ?? 'Unknown',
          description: doc['description'] ?? 'No description',
          memberNum: doc['member_num'] ?? 0,
          startingMonth: doc['starting_month'] ?? 'Unknown',
          estimatedWeeks: doc['estimated_weeks'] ?? 0,
          createdTime: (doc['created_time'] as Timestamp? ?? Timestamp.now()),
          maxPeople: doc['max_people'] ?? 0,
        );
      }).toList();

  Future fetchNextUsers({bool reset = false}) async {
    if (_isFetchingVentures)
      return; // quits early if already fetching users. Return stops function

    _errorMessage = '';
    _isFetchingVentures = true;

    if (reset) {
      _venturesSnapshot.clear();
      _hasNext = true;
      notifyListeners();
    }

    try {
      final appState = AppState();
      final snap = await FirebaseApi.getUsers(
        //appState: appState,
        // get users still just gets even if its first page or next page
        documentLimit,
        startAfter:
            _venturesSnapshot.isNotEmpty ? _venturesSnapshot.last : null,
        country: appState.ventureCountry,
        industry: appState.ventureIndustry,
        people: appState.maxPeople,
        month: appState.ventureMonth,
        weeks: appState.estimatedWeeks,
      );
      _venturesSnapshot.addAll(snap.docs);

      // this is where the client side filtering will happen. You edit the user snapshot here

      if (snap.docs.length < documentLimit)
        _hasNext =
            false; // so if it fetches 3 documents since there are 3 documents at the end, then it will know it has run out, this happens after the fetch
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingVentures = false;
  }
}
