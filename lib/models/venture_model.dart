import 'package:cloud_firestore/cloud_firestore.dart';

class VentureModel {
  final String destination;
  final DocumentReference creator;
  final String industry;
  final String description;
  final List<DocumentReference> members;
  final String startingMonth;
  final int estimatedLength;
  final Timestamp createdTime;
  final int numPeople;

  VentureModel({
    required this.destination,
    required this.creator,
    required this.industry,
    required this.description,
    required this.members,
    required this.startingMonth,
    required this.estimatedLength,
    required this.createdTime,
    required this.numPeople,
  });

  // Factory method to create a VentureModel from a Firestore document
  factory VentureModel.fromDocument(DocumentSnapshot doc) {
    return VentureModel(
      destination: doc['destination'],
      creator: doc['creator'],
      industry: doc['industry'],
      description: doc['description'],
      members: List<DocumentReference>.from(doc['members']),
      startingMonth: doc['starting_month'],
      estimatedLength: doc['estimated_length'],
      createdTime: doc['created_time'],
      numPeople: doc['num_people'],
    );
  }

  // Method to convert a VentureModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'destination': destination,
      'creator': creator,
      'industry': industry,
      'description': description,
      'members': members,
      'starting_month': startingMonth,
      'estimated_length': estimatedLength,
      'created_time': createdTime,
      'num_people': numPeople,
    };
  }
}
