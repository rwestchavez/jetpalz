import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jet_palz/components/my_snack_bar.dart';

Future<void> deleteVenture(
    BuildContext context, DocumentReference ventureRef) async {
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
      MySnackBar.show(context, content: Text('Venture deleted successfully'));
    } catch (e) {
      MySnackBar.show(context, content: Text('Failed to delete venture: $e'));
    }
  }
}
