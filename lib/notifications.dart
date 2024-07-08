import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:platform/platform.dart';

Future<void> storeFCMToken() async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Get the FCM token
  String? fcmToken = await messaging.getToken();

  // Get the APNs token for iOS devices
  String? apnsToken = await messaging.getAPNSToken();

  // Detect the device type
  final platform = LocalPlatform();
  String deviceType =
      platform.isIOS ? 'ios' : (platform.isAndroid ? 'android' : 'unknown');

  if (fcmToken != null || apnsToken != null) {
    // Get the current user
    User? user = auth.currentUser;
    if (user != null) {
      // Prepare the data to be updated
      Map<String, dynamic> data = {
        'device_type': deviceType,
        'fcm_token': fcmToken,
        'apns_token': apnsToken
      };

      // Store the tokens and device type in Firestore
      await firestore.collection('users').doc(user.uid).update(data);
    }
  }
}

void handleFCMTokenRefresh() async {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  final userRef = FirebaseFirestore.instance.collection("users").doc(userId);
  final userSnap = userRef.snapshots();

  userSnap.listen((snap) async {
    final token = await FirebaseMessaging.instance.getToken();
    if (snap["fcm_token"] != token) {
      final userRef =
          FirebaseFirestore.instance.collection("users").doc(userId);
      userRef.update({"fcm_token": token});
    }
  });
}
