import 'package:cloud_firestore/cloud_firestore.dart';

class ApartmentDao {
  final _ref = FirebaseFirestore.instance.collection("apartments");

  Future<DocumentReference> createApartment({
    required String name,
    required int totalFlat,
    required String iban,
    required String adminCode,
    required String residentCode,
  }) {
    return _ref.add({
      "name": name,
      "totalFlat": totalFlat,
      "iban": iban,
      "adminCode": adminCode,
      "residentCode": residentCode,
      "createdAt": Timestamp.now(),
    });
  }

  Future<DocumentSnapshot> getApartment(String apartmentId) {
    return _ref.doc(apartmentId).get();
  }

  /// 🔥 ADMIN + RESIDENT KODUNU KONTROL EDER
  Future<QuerySnapshot> findByCode(String code) async {
    // Admin kodu kontrol
    final adminSnap =
    await _ref.where("adminCode", isEqualTo: code).get();

    if (adminSnap.docs.isNotEmpty) {
      return adminSnap;
    }

    // Resident kodu kontrol
    final residentSnap =
    await _ref.where("residentCode", isEqualTo: code).get();

    return residentSnap;
  }

  Future<void> updateIban(String apartmentId, String iban) {
    return _ref.doc(apartmentId).update({
      "iban": iban,
      "updatedAt": FieldValue.serverTimestamp(),
    });
  }
}
