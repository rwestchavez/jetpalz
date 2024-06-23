import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_snack_bar.dart';

Future<void> deleteVenture(
    BuildContext context, DocumentReference ventureRef) async {
  DocumentReference? chatRef;

  final querySnapshot = await FirebaseFirestore.instance
      .collection("venture_chats")
      .where("venture", isEqualTo: ventureRef)
      .limit(1)
      .get();

  if (querySnapshot.docs.isNotEmpty) {
    chatRef = querySnapshot.docs.first.reference;
  }

  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this venture?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );

  if (shouldDelete == true) {
    try {
      await ventureRef.delete();
      if (chatRef != null) {
        await chatRef.delete();
      }
      final requestsQuerySnapshot = await FirebaseFirestore.instance
          .collection("requests")
          .where("ventureId", isEqualTo: ventureRef.id)
          .get();

      // If there are any requests, delete them in a batch
      if (requestsQuerySnapshot.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final requestDoc in requestsQuerySnapshot.docs) {
          batch.delete(requestDoc.reference);
        }
        await batch.commit();
      }
      MySnackBar.show(context, content: Text('Venture deleted successfully'));
    } catch (e) {
      MySnackBar.show(context, content: Text('Failed to delete venture: $e'));
    }
  }
}
