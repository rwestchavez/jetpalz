import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> storeFCMToken() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Get the FCM token
  String? fcmToken = await messaging.getToken();

  if (fcmToken != null) {
    // Get the current user
    User? user = auth.currentUser;
    if (user != null) {
      // Store the FCM token in Firestore
      await firestore.collection('users').doc(user.uid).update({
        'fcm_token': fcmToken,
      });
    }
  }
}

void handleFCMTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcm_token': newToken,
      });
    }
  });
}
