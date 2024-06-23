import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_snack_bar.dart';

Future<void> deleteVenture(
    BuildContext context, DocumentReference ventureRef, bool bypass) async {
  DocumentReference? chatRef;

  final querySnapshot = await FirebaseFirestore.instance
      .collection("venture_chats")
      .where("venture", isEqualTo: ventureRef)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    chatRef = querySnapshot.docs.first.reference;
  }

  bool shouldDelete = false;

  if (bypass) {
    shouldDelete = true;
  } else {
    shouldDelete = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content:
                  const Text('Are you sure you want to delete this venture?'),
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
  }
  if (Navigator.of(context).canPop()) {
    Navigator.pop(context);
  }
  ventureRef.set({'deleted': true});


  if (shouldDelete) {
    try {
      final requestsQuerySnapshot = await FirebaseFirestore.instance
          .collection("requests")
          .where("ventureId", isEqualTo: ventureRef.id)
          .get();

      final batch = FirebaseFirestore.instance.batch();

      if (chatRef != null) {
        batch.delete(chatRef);
      }
      batch.delete(ventureRef);
      // If there are any requests, delete them in a batch
      if (requestsQuerySnapshot.docs.isNotEmpty) {
        for (final requestDoc in requestsQuerySnapshot.docs) {
          batch.delete(requestDoc.reference);
        }
        await batch.commit();
      }
      MySnackBar.show(context,
          content: const Text('Venture deleted successfully'));
    } catch (e) {
      // MySnackBar.show(context, content: Text('Failed to delete venture: $e'));
    }
  }
}
