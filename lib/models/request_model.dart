import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequest {
  final String requestId;
  final String requesterId;
  final String ventureId;
  final String status;
  final DateTime timestamp;

  JoinRequest({
    required this.requestId,
    required this.requesterId,
    required this.ventureId,
    required this.status,
    required this.timestamp,
  });

  factory JoinRequest.fromDocument(DocumentSnapshot doc) {
    return JoinRequest(
      requestId: doc['requestId'],
      requesterId: doc['requesterId'],
      ventureId: doc['ventureId'],
      status: doc['status'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
    );
  }
}
