import 'package:cloud_firestore/cloud_firestore.dart';

class PollDao {
  final _db = FirebaseFirestore.instance;

  /// ADMIN → OYLAMA OLUŞTUR
  Future<void> createPoll({
    required String apartmentId,
    required String question,
    required String optionA,
    required String optionB,
    required String optionC,
    required DateTime endDate,
  }) async {
    // 1. Oylamayı Kaydet
    await _db.collection("polls").add({
      "apartmentId": apartmentId,
      "question": question,
      "optionA": optionA,
      "optionB": optionB,
      "optionC": optionC,
      "voteA": 0,
      "voteB": 0,
      "voteC": 0,
      "votedUsers": [],
      "endDate": Timestamp.fromDate(endDate),
      "isActive": true,
      "createdAt": Timestamp.now(),
    });

    await _db
        .collection('apartments')
        .doc(apartmentId)
        .collection('notifications')
        .add({
      'title': 'Yeni Oylama: $question',
      'message': 'Yönetim tarafından yeni bir oylama başlatıldı. Lütfen oyunuzu kullanın.',
      'type': 'oylama',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// ADMIN → OYLAMAYI SONLANDIR
  Future<void> closePoll(String pollId) {
    return _db.collection("polls").doc(pollId).update({
      "isActive": false,
    });
  }

  /// SAKİN → OY VER
  Future<void> vote({
    required String pollId,
    required String userId,
    required String option, // A B C
  }) async {
    final ref = _db.collection("polls").doc(pollId);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data()!;

      if (!data['isActive']) return;
      if ((data['votedUsers'] as List).contains(userId)) return;

      final update = <String, dynamic>{
        "votedUsers": FieldValue.arrayUnion([userId]),
      };

      if (option == "A") update["voteA"] = FieldValue.increment(1);
      if (option == "B") update["voteB"] = FieldValue.increment(1);
      if (option == "C") update["voteC"] = FieldValue.increment(1);

      tx.update(ref, update);
    });
  }

  /// OYLAMALARI ÇEK
  Stream<QuerySnapshot> getPolls(String apartmentId) {
    return _db
        .collection("polls")
        .where("apartmentId", isEqualTo: apartmentId)
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Future<void> deletePoll(String apartmentId, String pollId) async {
    await _db.collection('polls').doc(pollId).delete();
  }
}