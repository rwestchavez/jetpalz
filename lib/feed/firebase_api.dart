import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseApi {
  static Future<QuerySnapshot> getVentures(
    int limit, {
    DocumentSnapshot? startAfter,
    String? country,
    String? industry,
    int? people,
    String? month,
    int? weeks,
  }) async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;

    // Step 1: Fetch requests made by the current user
    final QuerySnapshot requestSnapshot = await firestore
        .collection('requests')
        .where('requesterId', isEqualTo: currentUserUid)
        .where('status', isEqualTo: 'accepted') // Only get accepted requests
        .get();

    // Extract the ventureIds of ventures where the user has an accepted request
    List<String> acceptedVentureIds =
        requestSnapshot.docs.map((doc) => doc['ventureId'] as String).toList();

    // Step 2: Query ventures excluding those created by the current user or accepted ventures
    CollectionReference venturesRef = firestore.collection('ventures');
    Query query = venturesRef.orderBy('created_time').limit(limit);
    var docRef = firestore.collection("users").doc(currentUserUid);

    // Add filters based on parameters
    if (country != null) {
      query = query.where('country', isEqualTo: country);
    }
    if (industry != null) {
      query = query.where('industry', isEqualTo: industry);
    }
    if (people != null) {
      query = query.where('max_people', isEqualTo: people);
    }
    if (month != null) {
      query = query.where('starting_month', isEqualTo: month);
    }
    if (weeks != null) {
      query = query.where('estimated_weeks', isEqualTo: weeks);
    }

    // query = query.where(FieldPath.documentId, whereNotIn: acceptedVentureIds);

    // If startAfter is provided, paginate using startAfterDocument
    if (startAfter == null) {
      return query.get();
    }
    return query.startAfterDocument(startAfter).get();
  }
}
