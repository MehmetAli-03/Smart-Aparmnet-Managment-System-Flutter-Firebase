import 'package:cloud_firestore/cloud_firestore.dart';

class Poll {
  final String id;
  final String apartmentId;
  final String question;
  final String optionA;
  final String optionB;
  final String optionC;
  final int voteA;
  final int voteB;
  final int voteC;
  final List<String> votedUsers;
  final DateTime endDate;
  final bool isActive;

  Poll({
    required this.id,
    required this.apartmentId,
    required this.question,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.voteA,
    required this.voteB,
    required this.voteC,
    required this.votedUsers,
    required this.endDate,
    required this.isActive,
  });

  factory Poll.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Poll(
      id: doc.id,
      apartmentId: data['apartmentId'] ?? '',
      question: data['question'] ?? '',
      optionA: data['optionA'] ?? '',
      optionB: data['optionB'] ?? '',
      optionC: data['optionC'] ?? '',
      voteA: data['voteA'] ?? 0,
      voteB: data['voteB'] ?? 0,
      voteC: data['voteC'] ?? 0,
      votedUsers: List<String>.from(data['votedUsers'] ?? []),
      endDate: (data['endDate'] as Timestamp).toDate(),
      isActive: data['isActive'] ?? false,
    );
  }


  int get totalVotes => voteA + voteB + voteC;
}