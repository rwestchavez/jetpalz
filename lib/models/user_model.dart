import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String username;
  final String photoUrl;
  final String uid;
  final Timestamp createdTime;
  final String profession;
  final List<String> countriesInterest;
  final List<String> professionsInterest;
  final String description;
  final List<DocumentReference> currentVentures;

  UserModel({
    required this.email,
    required this.username,
    required this.photoUrl,
    required this.uid,
    required this.createdTime,
    required this.profession,
    required this.countriesInterest,
    required this.professionsInterest,
    required this.description,
    required this.currentVentures,
  });

  // Factory method to create a UserModel from a Firestore document
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    return UserModel(
      email: doc['email'],
      username: doc['username'],
      photoUrl: doc['photo_url'],
      uid: doc['uid'],
      createdTime: doc['created_time'],
      profession: doc['profession'],
      countriesInterest: List<String>.from(doc['countries_interest']),
      professionsInterest: List<String>.from(doc['professions_interest']),
      description: doc['description'],
      currentVentures: List<DocumentReference>.from(doc['current_ventures']),
    );
  }

  // Method to convert a UserModel to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'profession': profession,
      'countries_interest': countriesInterest,
      'professions_interest': professionsInterest,
      'description': description,
      'current_ventures': currentVentures,
    };
  }
}
