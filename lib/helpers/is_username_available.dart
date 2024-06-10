import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<bool> isUsernameAvailable(String username) async {
  final lowercaseNewUsername = username.toLowerCase();
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    final DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    var userData = await userDoc.data() as Map<String, dynamic>;
    String oldName = userData['username'];
    if (oldName.toLowerCase() == lowercaseNewUsername) {
      return true;
    }
  }
  final querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();

  // Transform all usernames to lowercase and check for matches
  final usernames = querySnapshot.docs
      .map((doc) =>
          (doc.data() as Map<String, dynamic>)['username'].toLowerCase())
      .toList();
  print(usernames);
  return !usernames.contains(lowercaseNewUsername);
}
