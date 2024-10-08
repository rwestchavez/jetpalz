import 'package:cloud_firestore/cloud_firestore.dart';

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
    final firestore = FirebaseFirestore.instance;

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

    if (startAfter == null) {
      return await query.get();
    } else {
      return await query.startAfterDocument(startAfter).get();
    }
  }
}
