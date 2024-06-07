import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  static Future<QuerySnapshot> getUsers(
    int limit, {
    DocumentSnapshot? startAfter,
    String? country,
    String? industry,
    int? people,
    String? month,
    int? weeks,
  }) async {
    // here is where we do the server side filtering. You get ref users based on filter properties.
    CollectionReference venturesRef =
        FirebaseFirestore.instance.collection('ventures');
    Query query = venturesRef.orderBy('created_time').limit(limit);

    if (country != null) {
      query = query.where('country', isEqualTo: country);
    }
    if (industry != null) {
      query = query.where('industry', isEqualTo: industry);
    }
    if (people != null) {
      query = query.where('maxPeople', isEqualTo: people);
    }
    if (month != null) {
      query = query.where('ventureMonth', isEqualTo: month);
    }
    if (weeks != null) {
      query = query.where('estimatedWeeks', isEqualTo: weeks);
    }

    if (startAfter == null) {
      return query.get();
    } else {
      return query.startAfterDocument(startAfter).get();
    }
  }
}
