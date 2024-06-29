import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jet_palz/components/my_appbar.dart';
import 'package:jet_palz/helpers/launch_url.dart';
import '../auth/sign_up.dart';
import '../components/my_snack_bar.dart';
import '../components/single_line_widget.dart';
import '../helpers/delete_venture.dart';

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignUp(),
      ),
    );
  }

  Future<void> deleteAccount(BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection("users").doc(userId);
    bool shouldDelete = false;

    shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text(
                  'Are you sure you want to delete your account? \n\nThis action can not be undone and all your data including messages will be deleted.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
    if (shouldDelete) {
      // delete all chat messages

      var chats = await FirebaseFirestore.instance
          .collection('venture_chats')
          .where('members', arrayContains: userRef)
          .orderBy('last_message_time', descending: true)
          .get();

      List<String> chatIds = chats.docs.map((doc) {
        return doc.id;
      }).toList();

      for (String id in chatIds) {
        try {
          var chatSnap =
              await firestore.collection("venture_chats").doc(id).get();
          DocumentReference ventureRef = chatSnap["venture"];
          DocumentSnapshot ventureSnapshot = await ventureRef.get();
          Map<String, dynamic> ventureData =
              ventureSnapshot.data() as Map<String, dynamic>;
          final DocumentReference creatorRef = ventureData['creator'];

          final DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(userId);

          final DocumentReference chatRef =
              FirebaseFirestore.instance.collection('venture_chats').doc(id);
          DocumentSnapshot chatSnapshot = await chatRef.get();
          Map<String, dynamic> chatData =
              chatSnapshot.data() as Map<String, dynamic>;
          final List members = chatData['members'];

          if (creatorRef.id == userId) {
            if (members.length > 1) {
              // Attempt to find a new creator in members list
              DocumentReference? newCreatorRef;
              try {
                newCreatorRef = members.firstWhere((ref) => ref.id != userId);
              } catch (e, stack) {
                // Handle case where no matching element is found
                FirebaseCrashlytics.instance
                    .recordError(e, stack, reason: "leave chat error");
              }

              if (newCreatorRef != null) {
                await ventureRef.update({
                  'creator': newCreatorRef,
                  'member_num': FieldValue.increment(-1),
                });

                await chatRef.update({
                  'members': FieldValue.arrayRemove([userRef]),
                });
              } else {
                deleteVenture(context, ventureRef,
                    true); // Custom function to handle venture deletion
              }
            } else {
              deleteVenture(context, ventureRef,
                  true); // Custom function to handle venture deletion
            }
          } else {
            await chatRef.update({
              'members': FieldValue.arrayRemove([userRef]),
            });
            await ventureRef.update({
              'member_num': FieldValue.increment(-1),
            });
          }

          var requests = await FirebaseFirestore.instance
              .collection("requests")
              .where("requesterId", isEqualTo: userId)
              .where("ventureId", isEqualTo: ventureRef.id)
              .limit(1)
              .get();

          if (requests.docs.isNotEmpty) {
            var requestRef = requests.docs.first.reference;
            requestRef.delete();
          }
        } catch (e, stackTrace) {
          FirebaseCrashlytics.instance
              .recordError(e, stackTrace, reason: "delete venture error");
          MySnackBar.show(context,
              content: const Text("Failed to leave the venture"));
        }

        var messagesSnap = await firestore
            .collection("venture_chats")
            .doc(id)
            .collection("messages")
            .where("senderId", isEqualTo: userRef.id)
            .orderBy('timestamp')
            .get();

        List<DocumentReference> messagesRef = messagesSnap.docs.map((doc) {
          return doc.reference;
        }).toList();
        for (DocumentReference message in messagesRef) {
          message.delete();
        }
      }

      // Leave all chats (by leaving chats you leave ventueres)
      // find all chats they are in. And then leave it. So you would ise a list, and then call leave venture for each one

      // Delete account
    }
    userRef.delete();
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop();
                _logout(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Settings"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SingleLineWidget(
              icon: Icons.email,
              text: 'Change Email',
              onTap: () {
                Navigator.pushNamed(context, '/changeEmail');
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.lock,
              text: 'Change Password',
              onTap: () {
                Navigator.pushNamed(context, '/changePassword');
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.contact_support,
              text: 'Contact us ',
              onTap: () {
                Navigator.pushNamed(context, '/contact');
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.privacy_tip,
              text: 'Privacy Policy',
              onTap: () async {
                launchURL("https://jetpalz.com/privacy", context);
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.toc,
              text: 'Terms and conditions',
              onTap: () async {
                launchURL("https://jetpalz.com/toc", context);
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.exit_to_app,
              text: 'Logout',
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
            const SizedBox(height: 8),
            SingleLineWidget(
              icon: Icons.delete,
              text: 'Delete account',
              onTap: () async {
                await deleteAccount(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
