import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

void handleFCMTokenRefresh() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'fcm_token': newToken,
        'apns_token': await FirebaseMessaging.instance.getAPNSToken(),
      });
    }
  });
}
