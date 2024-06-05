import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseApi {
  static Future<QuerySnapshot> getUsers(
    int limit, {
    DocumentSnapshot? startAfter,
  }) async {
    // here is where we do the server side filtering. You get ref users based on filter properties.
    final refUsers = FirebaseFirestore.instance
        .collection('ventures')
        .orderBy('created_time')
        .limit(limit);

    if (startAfter == null) {
      return refUsers.get();
    } else {
      return refUsers.startAfterDocument(startAfter).get();
    }
  }
}
