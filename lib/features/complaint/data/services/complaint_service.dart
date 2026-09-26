import 'package:cloud_firestore/cloud_firestore.dart';

class ComplaintDao {
  // Ana koleksiyon adı 'complaints'
  final CollectionReference _collection = FirebaseFirestore.instance.collection('complaints');

  // 1. Şikayet/Arıza Ekleme
  Future<void> addComplaint({
    required String apartmentId,
    required String title,
    required String content,
    String? photoBase64,
  }) async {
    // Önce şikayeti kaydediyoruz
    await _collection.add({
      'apartmentId': apartmentId,
      'title': title,
      'content': content,
      'photoBase64': photoBase64,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // 🔥 HEMEN ARDINDAN BİLDİRİMİ FIRLATIYORUZ 🔥
    await FirebaseFirestore.instance
        .collection('apartments')
        .doc(apartmentId)
        .collection('notifications')
        .add({
      'title': 'Yeni Talep: $title',
      'message': 'Bina yönetimine yeni bir talep/şikayet iletildi.',
      'type': 'sikayet',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // 2. Şikayetleri Getirme
  Stream<QuerySnapshot> getComplaints(String apartmentId) {
    return _collection
        .where('apartmentId', isEqualTo: apartmentId)
        .snapshots();
  }

  // 3. Şikayet Silme
  Future<void> deleteComplaint(String docId) async {
    await _collection.doc(docId).delete();
  }

  // 4. Durum Güncelleme (Yönetici için)
  Future<void> updateStatus(String docId, String newStatus, String apartmentId) async {
    // Durumu güncelliyoruz
    await _collection.doc(docId).update({
      'status': newStatus,
    });

    // 🔥 DURUM DEĞİŞİNCE DE BİLDİRİM GİTSİN (ŞOV KISMI) 🔥
    String durumMesaji = newStatus == 'resolved' ? 'Çözüldü' : 'İşleme Alındı';
    await FirebaseFirestore.instance
        .collection('apartments')
        .doc(apartmentId)
        .collection('notifications')
        .add({
      'title': 'Talep Güncellemesi',
      'message': 'Bir talebin/şikayetin durumu "$durumMesaji" olarak güncellendi.',
      'type': 'sikayet',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}