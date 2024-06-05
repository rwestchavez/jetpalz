import 'package:cloud_firestore/cloud_firestore.dart';

class VentureModel {
  final String? country;
  final DocumentReference? creator;
  final String? industry;
  final String? description;
  final List<DocumentReference>? memberList;
  final String? startingMonth;
  final int? estimatedWeeks;
  final Timestamp? createdTime;
  final int? maxPeople;

  VentureModel({
    required this.country,
    required this.creator,
    required this.industry,
    required this.description,
    required this.memberList,
    required this.startingMonth,
    required this.estimatedWeeks,
    required this.createdTime,
    required this.maxPeople,
  });

  // Factory method to create a VentureModel from a Firestore document
  factory VentureModel.fromDocument(DocumentSnapshot doc) {
    return VentureModel(
      country: doc['country'],
      creator: doc['creator'],
      industry: doc['industry'],
      description: doc['description'],
      memberList: List<DocumentReference>.from(doc['member_list']),
      startingMonth: doc['starting_month'],
      estimatedWeeks: doc['estimated_weeks'],
      createdTime: doc['created_time'],
      maxPeople: doc['max_people'],
    );
  }

  // Method to convert a VentureModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'creator': creator,
      'industry': industry,
      'description': description,
      'member_list': memberList,
      'starting_month': startingMonth,
      'estimated_weeks': estimatedWeeks,
      'created_time': createdTime,
      'max_people': maxPeople,
    };
  }
}
