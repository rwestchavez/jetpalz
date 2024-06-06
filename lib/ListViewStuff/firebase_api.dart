import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jet_palz/app_state.dart';

class FirebaseApi {
  static Future<QuerySnapshot> getUsers(
    int limit, {
    DocumentSnapshot? startAfter,
    //   required AppState appState,
  }) async {
    // here is where we do the server side filtering. You get ref users based on filter properties.
    var refUsers = FirebaseFirestore.instance
        .collection('ventures')
        .orderBy('created_time')
        .limit(limit);
    /*
    if (appState.ventureCountry != null) {
      refUsers = refUsers.where('country', isEqualTo: appState.ventureCountry);
    }
    if (appState.ventureIndustry != null) {
      refUsers =
          refUsers.where('industry', isEqualTo: appState.ventureIndustry);
    }
    if (appState.maxPeople != null) {
      refUsers = refUsers.where('max_people', isEqualTo: appState.maxPeople);
    }
    if (appState.ventureMonth != null) {
      refUsers =
          refUsers.where('starting_month', isEqualTo: appState.ventureMonth);
    }
    if (appState.estimatedWeeks != null) {
      refUsers =
          refUsers.where('estimated_weeks', isEqualTo: appState.estimatedWeeks);
    } */
    print(refUsers as Map<String, dynamic>);

    if (startAfter == null) {
      return refUsers.get();
    } else {
      return refUsers.startAfterDocument(startAfter).get();
    }
  }
}
