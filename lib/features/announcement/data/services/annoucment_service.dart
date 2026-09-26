import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDao {
  final _db = FirebaseFirestore.instance;

  Future<void> addAnnouncement({
    required String apartmentId,
    required String title,
    required String content,
  }) async {
    await _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("announcements")
        .add({
      "title": title,
      "content": content,
      "createdAt": Timestamp.now(),
    });
  }


  Stream<QuerySnapshot> announcementStream(String apartmentId) {
    return _db
        .collection("apartments")
        .doc(apartmentId)
        .collection("announcements")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }


  Future<void> deleteAnnouncement(String apartmentId, String announcementId) async {
    await FirebaseFirestore.instance
        .collection('apartments')
        .doc(apartmentId)
        .collection('announcements')
        .doc(announcementId)
        .delete();
  }
}
