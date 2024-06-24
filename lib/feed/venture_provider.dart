import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../app_state.dart';
import '../models/venture_model.dart';
import 'firebase_api.dart';

class VentureProvider extends ChangeNotifier {
  final _venturesSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  int documentLimit = 5;
  bool _hasNext = true;
  bool _isFetchingVentures = false;

  String get errorMessage => _errorMessage;
  bool get hasNext => _hasNext;
  List<VentureModel> get ventures => _venturesSnapshot.map((snap) {
        final doc = snap.data() as Map<String, dynamic>;
        return VentureModel(
          ventureId: snap.id,
          country: doc['country'] ?? 'Unknown',
          creator: doc['creator'],
          creatorName: doc['creator_name'],
          industry: doc['industry'] ?? 'Unknown',
          description: doc['description'] ?? 'No description',
          memberNum: doc['member_num'] ?? 0,
          startingMonth: doc['starting_month'] ?? 'Unknown',
          estimatedWeeks: doc['estimated_weeks'] ?? 0,
          createdTime: (doc['created_time'] as Timestamp? ?? Timestamp.now()),
          maxPeople: doc['max_people'] ?? 0,
        );
      }).toList();

  Future<void> fetchNextUsers({bool reset = false}) async {
    if (_isFetchingVentures) {
      return;
    }

    _errorMessage = '';
    _isFetchingVentures = true;

    if (reset) {
      _venturesSnapshot.clear();
      _hasNext = true;
      notifyListeners();
    }

    try {
      final appState = AppState();
      final snap = await FirebaseApi.getVentures(
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

      if (snap.docs.length < documentLimit) {
        _hasNext = false;
      }
      notifyListeners();
    } catch (error, stackTrace) {
      _errorMessage = error.toString();
      notifyListeners();

      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: 'Failed to fetch ventures',
      );
    }

    _isFetchingVentures = false;
  }
}
