import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String id;
  final String apartmentId;
  final String title;
  final String content;
  final String? photoUrl;
  final DateTime createdAt;

  Complaint({
    required this.id,
    required this.apartmentId,
    required this.title,
    required this.content,
    this.photoUrl,
    required this.createdAt,
  });

  factory Complaint.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Complaint(
      id: doc.id,
      apartmentId: data['apartmentId'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}