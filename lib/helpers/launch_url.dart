import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url, BuildContext context) async {
  final Uri uri = Uri.parse(url);
  try {
    await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
  } catch (e, stackTrace) {
    MySnackBar.show(context,
        content: Text("Failed to launch URL. Try again later"));
    FirebaseCrashlytics.instance.recordError(
      e,
      stackTrace,
      reason: 'Failed to launch Url $url',
      fatal: true,
    );
  }
}
