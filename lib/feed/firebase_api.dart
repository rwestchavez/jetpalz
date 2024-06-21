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

    final QuerySnapshot requestSnapshot = await firestore
        .collection('requests')
        .where('requesterId', isEqualTo: currentUserUid)
        .where('status', isEqualTo: 'accepted') // Only get accepted requests
        .get();

    CollectionReference venturesRef = firestore.collection('ventures');
    Query query = venturesRef.orderBy('created_time').limit(limit);

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
