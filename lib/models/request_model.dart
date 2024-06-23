import 'package:cloud_firestore/cloud_firestore.dart';

class JoinRequest {
  final String requestId;
  final String requesterId;
  final String ventureId;
  final String status;
  final DateTime timestamp;
  final String requester;
  final List<String> seenBy;

  JoinRequest({
    required this.requester,
    required this.requestId,
    required this.requesterId,
    required this.ventureId,
    required this.status,
    required this.timestamp,
    required this.seenBy,
  });

  factory JoinRequest.fromDocument(DocumentSnapshot doc) {
    return JoinRequest(
      requester: doc['requester'],
      requestId: doc['requestId'],
      requesterId: doc['requesterId'],
      ventureId: doc['ventureId'],
      status: doc['status'],
      timestamp: (doc['timestamp'] as Timestamp).toDate(),
      seenBy: List<String>.from(doc['seenBy'] ?? []),
    );
  }
}
