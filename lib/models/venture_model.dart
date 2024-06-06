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
  factory VentureModel.fromDocument(Map<String, dynamic> data) {
    return VentureModel(
      country: data['country'] ?? 'Unknown',
      creator: data['creator'],
      industry: data['industry'] ?? 'Unknown',
      description: data['description'] ?? 'No description',
      memberList: data['member_list'] != null
          ? List<DocumentReference>.from(data['member_list'])
          : [],
      startingMonth: data['starting_month'] ?? 'Unknown',
      estimatedWeeks: data['estimated_weeks'] ?? 0,
      createdTime: (data['created_time'] as Timestamp? ?? Timestamp.now()),
      maxPeople: data['max_people'] ?? 0,
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
