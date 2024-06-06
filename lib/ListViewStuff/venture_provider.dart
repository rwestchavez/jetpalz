import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jet_palz/models/venture_model.dart';
import "venture_provider.dart";
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'firebase_api.dart';
import 'package:jet_palz/app_state.dart';

// this is meant to get ventures, not users

class VentureProvider extends ChangeNotifier {
  final _venturesSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  int documentLimit = 5;
  bool _hasNext = true;
  bool _isFetchingVentures = false;

  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  final _appState = AppState();

  /* VentureProvider() {
    listenToAppStateChanges(); // Call the listener setup in the constructor
  } */

  List<VentureModel> get ventures => _venturesSnapshot.map((snap) {
        // converts List of snapshots
        final doc = snap.data() as Map<String, dynamic>;

        return VentureModel(
          // Init a new object for each snapshot document
          country: doc['country'] ?? 'Unknown',
          creator: doc['creator'],
          industry: doc['industry'] ?? 'Unknown',
          description: doc['description'] ?? 'No description',
          memberList: doc['member_list'] != null
              ? List<DocumentReference>.from(doc['member_list'])
              : [],
          startingMonth: doc['starting_month'] ?? 'Unknown',
          estimatedWeeks: doc['estimated_weeks'] ?? 0,
          createdTime: (doc['created_time'] as Timestamp? ?? Timestamp.now()),
          maxPeople: doc['max_people'] ?? 0,
        );
      }).toList();

  /* Define the filteredVentures getter to return filtered list of ventures
  List<VentureModel> get filteredVentures {
    return ventures.where((venture) {
      // Check if venture matches appState criteria
      return (_appState.ventureCountries.isEmpty ||
              _appState.ventureCountries.contains(venture.country)) &&
          (_appState.ventureIndustries.isEmpty ||
              _appState.ventureIndustries.contains(venture.industry)) &&
          (_appState.maxPeople == null ||
              venture.maxPeople == _appState.maxPeople) &&
          (_appState.ventureMonth == null ||
              venture.startingMonth == _appState.ventureMonth) &&
          (_appState.estimatedWeeks == null ||
              venture.estimatedWeeks == _appState.estimatedWeeks);
    }).toList();
  } */
  List<VentureModel> get filteredVentures {
    // Logic to filter ventures based on app state
    return ventures.where((venture) {
      return true;
    }).toList();
  }

  Future<void> fetchNextUsers() async {
    if (_isFetchingVentures) return;

    _errorMessage = '';
    _isFetchingVentures = true;

    try {
      Query filteredQuery = FirebaseFirestore.instance.collection('ventures');

      // Apply filters based on app state
      if (_appState.ventureCountries.isNotEmpty) {
        filteredQuery =
            filteredQuery.where('country', whereIn: _appState.ventureCountries);
      }
      if (_appState.ventureIndustries.isNotEmpty) {
        filteredQuery = filteredQuery.where('industry',
            whereIn: _appState.ventureIndustries);
      }
      if (_appState.maxPeople != null) {
        filteredQuery =
            filteredQuery.where('max_people', isEqualTo: _appState.maxPeople);
      }
      if (_appState.ventureMonth != null) {
        filteredQuery = filteredQuery.where('starting_month',
            isEqualTo: _appState.ventureMonth);
      }
      if (_appState.estimatedWeeks != null) {
        filteredQuery = filteredQuery.where('estimated_weeks',
            isEqualTo: _appState.estimatedWeeks);
      }

      // Execute the query
      final filteredSnapshots = await filteredQuery.get();
      final filteredVentures = filteredSnapshots.docs
          .map((doc) =>
              VentureModel.fromDocument(doc.data()! as Map<String, dynamic>))
          .toList();

      // Update hasNext based on fetched documents
      _hasNext = filteredVentures.length == documentLimit;

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingVentures = false;
  }

  /*void listenToAppStateChanges() {
    _appState.addListener(() {
      updateFilteredVentures();
    });
  }

  void updateFilteredVentures() {
    // Clear existing ventures before fetching new ones
    _venturesSnapshot.clear();
    fetchNextUsers(); // Fetch new ventures based on updated filters
  } */
/*
  Future fetchNextUsers() async {
    if (_isFetchingVentures)
      return; // quits early if already fetching users. Return stops function

    _errorMessage = '';
    _isFetchingVentures = true;

    try {
      final snap = await FirebaseApi.getUsers(
        // get users still just gets even if its first page or next page
        documentLimit,
        startAfter:
            _venturesSnapshot.isNotEmpty ? _venturesSnapshot.last : null,
      );
      final filteredVentures = snap.docs.where((doc) {
        final venture = doc.data() as Map<String, dynamic>;
        print("Appstate countries = ${_appState.ventureCountries}");
        return (_appState.ventureCountries.isEmpty ||
                _appState.ventureCountries.contains(venture['country'])) &&
            (_appState.ventureIndustries.isEmpty ||
                _appState.ventureIndustries.contains(venture['industry'])) &&
            (_appState.maxPeople == null ||
                venture['max_people'] == _appState.maxPeople) &&
            (_appState.ventureMonth == null ||
                venture['starting_month'] == _appState.ventureMonth) &&
            (_appState.estimatedWeeks == null ||
                venture['estimated_weeks'] == _appState.estimatedWeeks);
      }).toList();
      _venturesSnapshot.addAll(filteredVentures);
      _hasNext = filteredVentures.length ==
          documentLimit; // Update hasNext based on fetched documents
      print(" filered ventures $filteredVentures");
      print("Filtered list is $_venturesSnapshot");
      // Update filteredVentures based on the new data
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
    print(_isFetchingVentures);
    _isFetchingVentures = false;
    print(_isFetchingVentures);

    /* void listenToAppStateChanges() {
      _appState.addListener(() {
        updateFilteredVentures();
      }); 
    } */
  }*/
}
