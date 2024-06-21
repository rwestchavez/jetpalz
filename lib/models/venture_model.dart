import 'package:cloud_firestore/cloud_firestore.dart';

class VentureModel {
  final String ventureId;

  final String? country;
  final DocumentReference? creator;
  final String creatorName;

  final String? industry;
  final String? description;
  final int memberNum;
  final String? startingMonth;
  final int? estimatedWeeks;
  final Timestamp? createdTime;
  final int? maxPeople;

  VentureModel({
    required this.ventureId,
    required this.country,
    required this.creator,
    required this.creatorName,
    required this.industry,
    required this.description,
    required this.memberNum,
    required this.startingMonth,
    required this.estimatedWeeks,
    required this.createdTime,
    required this.maxPeople,
  });

  // Factory method to create a VentureModel from a Firestore document
  factory VentureModel.fromDocument(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return VentureModel(
      ventureId: doc.id,
      country: data['country'] ?? 'Unknown',
      creator: data['creator'],
      creatorName: data['creator_name'],
      industry: data['industry'] ?? 'Unknown',
      description: data['description'] ?? 'No description',
      memberNum: data['member_num'] ?? 1,
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
      'creator_name': creatorName,
      'industry': industry,
      'description': description,
      'member_num': memberNum,
      'starting_month': startingMonth,
      'estimated_weeks': estimatedWeeks,
      'created_time': createdTime,
      'max_people': maxPeople,
    };
  }
}
