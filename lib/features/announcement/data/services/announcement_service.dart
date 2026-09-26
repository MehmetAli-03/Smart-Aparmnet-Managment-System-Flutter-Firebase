import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementDao {
  Future<void> addAnnouncement({
    required String apartmentId,
    required String title,
    required String content,
  }) async {
    // 1. Önce Duyuruyu Koleksiyona Ekliyoruz
    await FirebaseFirestore.instance
        .collection("apartments")
        .doc(apartmentId)
        .collection("announcements")
        .add({
      "title": title,
      "content": content,
      "createdAt": Timestamp.now(),
    });

    // 2. 🔥 HEMEN ARDINDAN BİLDİRİMİ FIRLATIYORUZ 🔥
    await FirebaseFirestore.instance
        .collection('apartments')
        .doc(apartmentId)
        .collection('notifications')
        .add({
      'title': 'Yeni Duyuru: $title',
      'message': 'Yönetim tarafından yeni bir duyuru paylaşıldı.',
      'type': 'duyuru', // Bildirim penceresinde yeşil megafon ikonu çıkacak
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getAnnouncements(String apartmentId) {
    return FirebaseFirestore.instance
        .collection("apartments")
        .doc(apartmentId)
        .collection("announcements")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }
}